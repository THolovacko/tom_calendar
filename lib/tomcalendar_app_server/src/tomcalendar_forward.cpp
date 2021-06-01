#include <time.h>
#include <chrono>
#include <thread>
#include <iostream>
#include "tomcalendar_app_server.h"

// @remeber: memcache and app-server size are limited by UDP (65,535 bytes)

/* helpful for debugging
  printf("Content-type: text/html\n\n");
  printf( R"html(%s)html", message_body.data());
  return 0;
*/

/* get environment variables (not needed but leaving for reference) */
// std::string env_region(getenv("AWS_REGION"));


int main(int argc, char* argv[]) {
  /* decide app server port */
  srand(time(NULL));
  uint64_t hardware_thread_count = std::thread::hardware_concurrency();
  uint64_t port_range_size = (SERVER_PORT_MAX - SERVER_PORT_MIN) + 1;
  hardware_thread_count = (hardware_thread_count <= port_range_size) ? hardware_thread_count : port_range_size;
  uint64_t microseconds_since_epoch = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
  uint64_t server_id = microseconds_since_epoch % hardware_thread_count;
  uint64_t server_port = SERVER_PORT_MIN + server_id;
  tom_socket client_socket(SERVER_IP_ADDRESS, server_port, false);

  /* get message body */
  std::string message_body;
  std::string message_line;
  while (std::getline(std::cin, message_line)) {
    message_body += message_line += "\n";
  }

  /* forward request */
  std::string signature = std::to_string(microseconds_since_epoch);
  message_body += "signature";
  message_body += signature;
  client_socket.message_server(message_body);

  /* return app-server response */
  std::string server_response = client_socket.listen_for_server_response();
  std::string server_signature;

  if ( server_response.length() > (signature.length() + 1) ) {  // length must be greater than length of "signature:" for it to not be empty string
    server_signature = std::string(server_response.substr(0, signature.length()));
  } else {
    printf("Content-type: text/plain\nStatus: 500 Internal Server Error\n\n");
    return 0;
  }

  if ( server_signature.compare(signature) == 0 ) { // server returns "signature:value" (because added ':' we don't length - 1)
    printf("%s", server_response.substr(signature.length() + 1).data());
    return 0;
  } else {
    printf("Content-type: text/plain\nStatus: 500 Internal Server Error\n\n");
    return 0;
  }
}
