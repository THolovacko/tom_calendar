#include <thread>
#include <vector>
#include <queue>
#include <condition_variable>
#include <chrono>
#include "tom_memcache.h"

// @remember: do I need to increase OS default socket buffer size?
// @current: refactor worker thread to use a blocking queue or maybe wait using a condition variable to lower cpu usage while no work
//        https://rules.sonarsource.com/cpp/RSPEC-5404
//        https://en.cppreference.com/w/cpp/thread/condition_variable/wait

tom_socket server_socket(SERVER_IP_ADDRESS, SERVER_PORT, true);
bool is_server_running = true;
std::vector<std::thread*> thread_pool;
std::vector<std::queue<tom_socket::client_message>*> thread_queues;

void worker_thread(const std::size_t pool_index) {
  while(is_server_running) {
    if (!thread_queues[pool_index]->empty()) {
      tom_socket::client_message current_client_data = thread_queues[pool_index]->front();
      server_socket.respond_to_client("OK", current_client_data.address, current_client_data.address_length);
      thread_queues[pool_index]->pop();

      //printf("index: %d ---%s---",(int)pool_index,current_client_data.message.data());
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

  // initalize thread pool and thread queues 
  for (std::size_t i=0; i < thread_count; ++i) {
    thread_pool.push_back(new std::thread(worker_thread, i));
    thread_queues.push_back(new std::queue<tom_socket::client_message>());
  }
  std::size_t current_thread_index = 0;

  while(true) {
    tom_socket::client_message client_data = server_socket.listen_for_client_message();

    if (client_data.message == "STOP") {
      server_socket.respond_to_client("OK", client_data.address, client_data.address_length);
      is_server_running = false;
      for (std::size_t i=0; i < thread_count; ++i) {
        thread_pool[i]->join();
      }
      return 0;
    }

    thread_queues[current_thread_index]->push(client_data);
    current_thread_index = (current_thread_index + 1) % thread_count;
  }

  return 0;
}
