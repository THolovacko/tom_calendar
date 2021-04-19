#include "tom_memcache.h"

int main(int argc, char* argv[]) {
  if (argc != 2) {
    printf("tom_memache_get key\n");
    return 0;
  }

  tom_socket client_socket(SERVER_IP_ADDRESS, SERVER_PORT, false);

  client_socket.message_server("get " + std::string(argv[1]));
  std::string server_response = client_socket.listen_for_server_response();

  printf("recieved server response: %s\n", server_response.data());

  return 0;
}
