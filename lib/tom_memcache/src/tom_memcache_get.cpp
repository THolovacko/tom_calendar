#include "tom_memcache.h"

int main(int argc, char* argv[]) {
  if (argc != 2) {
    printf("tom_memache_get key\n");
    return 0;
  }

  tom_socket client_socket(SERVER_IP_ADDRESS, SERVER_PORT, false);

  const std::string key(argv[1]);

  client_socket.message_server("get " + key);
  std::string server_response = client_socket.listen_for_server_response();
  std::string server_key;

  if ( server_response.length() > (key.length() + 1) ) {  // length must be greater than length of "key:" for it to not be empty string
    server_key = std::string(server_response.substr(0, key.length()));
  } else {
    printf("\n");
    return 0;
  }

  if ( server_key.compare(key) == 0 ) { // server returns "key:value" (because added ':' we don't length - 1)
    printf("%s\n", server_response.substr(key.length() + 1).data());
    return 0;
  } else {
    printf("\n");
    return 0;
  }
}
