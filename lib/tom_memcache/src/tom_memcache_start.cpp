#include <thread>
#include <vector>
#include <queue>
#include <condition_variable>
#include <chrono>
#include <unordered_map>
#include "tom_memcache.h"

// @remember: do I need to increase OS default socket buffer size?
// @remember: clients will need to verify recieved message isn't coming from late result for other client

tom_socket server_socket(SERVER_IP_ADDRESS, SERVER_PORT, true);
bool is_server_running = true;
std::vector<std::thread*> thread_pool;
std::vector<std::queue<tom_socket::client_message>*> thread_queues;
std::vector<std::mutex*> thread_mutexes;
std::vector<std::condition_variable*> thread_condition_variables;
std::vector<bool> thread_flags;
std::unordered_map<std::string, std::string>* tom_cache;

void worker_thread(const std::size_t pool_index) {
  while(is_server_running) {
    if (!thread_queues[pool_index]->empty()) {
      tom_socket::client_message current_client_data = thread_queues[pool_index]->front();

      switch(current_client_data.message[0]) {  // decide if get or set
        case 'g'  :
          server_socket.respond_to_client( (*tom_cache)[ current_client_data.message.substr(4) ], current_client_data.address, current_client_data.address_length);  // 4 is the length of "get "
          break;
        case 's'  :
          std::size_t delimiter_position = current_client_data.message.find("%*=tom-cache-delim=*08071992%");
          (*tom_cache)[current_client_data.message.substr(4, delimiter_position - 4)] = current_client_data.message.substr(delimiter_position + 29); // 4 is length of "set " and 29 is length of delimiter
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

  tom_cache = new std::unordered_map<std::string, std::string>();

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
