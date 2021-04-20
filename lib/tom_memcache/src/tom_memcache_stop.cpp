#include "tom_memcache.h" 

int main(int argc, char* argv[]) {
  tom_socket client_socket(SERVER_IP_ADDRESS, SERVER_PORT, false);

  client_socket.message_server("STOP");
  std::string server_response = client_socket.listen_for_server_response();

  if (server_response == "OK") {
    printf("tom_memcache stop successful\n");
  } else {
    printf("tom_memcache stop failed\n");
  }

  return 0;
}
