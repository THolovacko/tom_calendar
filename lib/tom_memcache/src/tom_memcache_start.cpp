#include <thread>
#include <vector>
#include <queue>
#include <condition_variable>
#include <chrono>
#include <atomic>
#include <cstdlib>
#include <functional>
#include <memory>
#include "tom_memcache.h"

// @remember: do I need to increase OS default socket buffer size?
// @remember: clients will need to verify recieved message isn't coming from late result for other client
// @remember: need to review bucket reserve count and memory percentage allocated for cache
// @current: implemement custom concurrent hash map cache thing


struct tom_timed_map {
  struct entry {
    std::string key;
    std::string value;
    std::chrono::time_point<std::chrono::system_clock> expiration_time;

    entry() { expiration_time = std::chrono::system_clock::now(); }
    entry(const std::string& p_key, const std::string& p_value, std::size_t expiration_delay_seconds) : key(p_key), value(p_value), expiration_time(std::chrono::system_clock::now() + std::chrono::seconds(expiration_delay_seconds) ) {}
  };

  typedef std::shared_ptr<entry> bucket;


  const std::size_t bucket_count;
  bucket* const buckets;
  
  tom_timed_map(const std::size_t p_bucket_count) : bucket_count(p_bucket_count), buckets(new bucket[p_bucket_count]) {}
  
  void set(const std::string& set_key, const std::string& set_value, const std::size_t expiration_seconds) {
    size_t bucket_index = std::hash<std::string>{}(set_key) % bucket_count;
    std::atomic_store( &(buckets[bucket_index]), std::make_shared<entry>(set_key,set_value,expiration_seconds) );
  }

  const std::string search(const std::string& search_key) const {
    size_t bucket_index = std::hash<std::string>{}(search_key) % bucket_count;

    std::shared_ptr<entry> search_result;
    search_result = std::atomic_load( &(buckets[bucket_index]) );

    if ( (search_result->expiration_time <= std::chrono::system_clock::now()) ) {
      return "";
    } else {
      if (search_result->key.compare(search_key) != 0) {
        return "";
      } else {
        return search_result->value;
      }
    }
  }

  ~tom_timed_map() {
   delete[] buckets;
  }
};

tom_socket server_socket(SERVER_IP_ADDRESS, SERVER_PORT, true);
bool is_server_running = true;
std::vector<std::thread*> thread_pool;
std::vector<std::queue<tom_socket::client_message>*> thread_queues;
std::vector<std::mutex*> thread_mutexes;
std::vector<std::condition_variable*> thread_condition_variables;
std::vector<bool> thread_flags; // @remember: make atomic variable?
tom_timed_map* tom_cache;
const long int max_ram_bytes = sysconf(_SC_PHYS_PAGES) * sysconf(_SC_PAGESIZE);
const long int max_cache_ram_bytes = max_ram_bytes / 3;

void worker_thread(const std::size_t pool_index) {
  while(is_server_running) {
    if (!thread_queues[pool_index]->empty()) {
      tom_socket::client_message current_client_data = thread_queues[pool_index]->front();

      switch(current_client_data.message[0]) {  // decide if get or set
        case 'i'  :
          server_socket.respond_to_client( "bucket count: " + std::to_string(tom_cache->bucket_count), current_client_data.address, current_client_data.address_length);
          break;
        case 'g'  :
          // @current: check timestamp and return empty string if expired
          server_socket.respond_to_client( tom_cache->search(current_client_data.message.substr(4)), current_client_data.address, current_client_data.address_length);  // 4 is the length of "get "
          break;
        case 's'  :
          std::size_t delimiter_position = current_client_data.message.find("%*=tom-cache-delim=*08071992%");
          tom_cache->set(current_client_data.message.substr(4, delimiter_position - 4), current_client_data.message.substr(delimiter_position + 29), 10); // 4 is length of "set " and 29 is length of delimiter

          // @current: manually track memory with atomic long int (std::atomic)
          // @current: check memory threshold and remove stuff


          break;
      }

      thread_queues[pool_index]->pop();
    } else {
      std::unique_lock<std::mutex> lock(*(thread_mutexes[pool_index]));
      thread_condition_variables[pool_index]->wait(lock, [&]{return thread_flags[pool_index];});
      thread_flags[pool_index] = false;
      lock.unlock();
      thread_condition_variables[pool_index]->notify_one();
    }
  }
}



int main() {
  // decide thread count
  const std::size_t hardware_thread_count = std::thread::hardware_concurrency();
  std::size_t thread_count = 1;
  if ( (hardware_thread_count / 4) > 1) {
    thread_count = hardware_thread_count / 4;
  }

  /*
  const long int assumed_bucket_size_bytes = 5000000;  // 5K bucket size
  const long int ram_divisor = 4;  // assume should use max 25% of total memory
  const long int max_ram_bytes = sysconf(_SC_PHYS_PAGES) * sysconf(_SC_PAGESIZE);
  const long int bucket_count = (max_ram_bytes / ram_divisor) / assumed_bucket_size_bytes;
  */

  tom_cache = new tom_timed_map(100000);

  // initalize thread pool and thread queues 
  for (std::size_t i=0; i < thread_count; ++i) {
    thread_queues.push_back(new std::queue<tom_socket::client_message>());
    thread_mutexes.push_back(new std::mutex());
    thread_condition_variables.push_back(new std::condition_variable());
    thread_flags.push_back(false);
    thread_pool.push_back(new std::thread(worker_thread, i));
  }
  std::size_t current_thread_index = 0;

  while(true) {
    tom_socket::client_message client_data = server_socket.listen_for_client_message();

    if (client_data.message == "STOP") {
      is_server_running = false;
      for (std::size_t i=0; i < thread_count; ++i) {
        thread_flags[i] = true;
        thread_condition_variables[i]->notify_one();
        thread_pool[i]->join();
      }
      server_socket.respond_to_client("OK", client_data.address, client_data.address_length);
      return 0;
    }

    thread_queues[current_thread_index]->push(client_data);
    thread_flags[current_thread_index] = true;
    thread_condition_variables[current_thread_index]->notify_one();

    current_thread_index = (current_thread_index + 1) % thread_count;
  }

  return 0;
}
