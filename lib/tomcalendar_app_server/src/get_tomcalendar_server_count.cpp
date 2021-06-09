#include <iostream>
#include <thread>
#include "tomcalendar_app_server.h"

int main(int argc, char* argv[]) {
  uint64_t hardware_thread_count = std::thread::hardware_concurrency();
  uint64_t port_range_size = (SERVER_PORT_MAX - SERVER_PORT_MIN) + 1;
  hardware_thread_count = (hardware_thread_count <= port_range_size) ? hardware_thread_count : port_range_size;
  printf("%s", std::to_string(hardware_thread_count).data());
}
