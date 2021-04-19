#include "tom_memcache.h"

// @remember: do I need to increase OS default socket buffer size?
// @remember: do I need to multithread more?

int main() {
  tom_socket server_socket(SERVER_IP_ADDRESS, SERVER_PORT, true);

  while(true) {
    std::string client_message = server_socket.listen_for_client_message();
    printf("recieved client message : %s\n", client_message.data());

    server_socket.respond_to_client("OK");

    if (client_message == "STOP") {
      return 0;
    }
  }

  return 0;
}
