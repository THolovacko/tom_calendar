#include "tom_memcache.h" 
  
int main() {
  tom_socket client_socket(SERVER_IP_ADDRESS, SERVER_PORT, false);

  client_socket.message_server("testinggg");
  std::string server_response = client_socket.listen_for_server_response();

  printf("recieved server response: %s\n", server_response.data());

  return 0;
}
