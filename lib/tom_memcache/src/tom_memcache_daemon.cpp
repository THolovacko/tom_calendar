#include "tom_memcache.h" 

int main() {
  tom_socket server_socket(SERVER_IP_ADDRESS, SERVER_PORT, true);

  std::string client_message = server_socket.listen_for_client_message();
  printf("recieved client message : %s\n", client_message.data());

  server_socket.respond_to_client("OK");

  return 0;
}
