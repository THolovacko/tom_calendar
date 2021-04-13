#include "tom_memcache.h" 

// @current: set message from parsed command line params
  
int main(int argc, char* argv[]) {
  if (argc != 3) {
    printf("tom_memache_set key value\n");
    return 0;
  }

  tom_socket client_socket(SERVER_IP_ADDRESS, SERVER_PORT, false);

  client_socket.message_server("set " + std::string(argv[1]) + " " + std::string(argv[2]));
  std::string server_response = client_socket.listen_for_server_response();

  printf("recieved server response: %s\n", server_response.data());

  return 0;
}
