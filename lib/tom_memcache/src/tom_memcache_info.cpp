#include "tom_memcache.h" 

int main(int argc, char* argv[]) {
  tom_socket client_socket(SERVER_IP_ADDRESS, SERVER_PORT, false);

  client_socket.message_server("info");
  std::string server_response = client_socket.listen_for_server_response();

  printf("%s\n", server_response.data());

  return 0;
}
