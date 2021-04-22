#include "tom_memcache.h" 

int main(int argc, char* argv[]) {
  if (argc != 3) {
    printf("tom_memache_set key value\n");
    return 0;
  }

  tom_socket client_socket(SERVER_IP_ADDRESS, SERVER_PORT, false);

  client_socket.message_server("set " + std::string(argv[1]) + "%*=tom-cache-delim=*08071992%" + std::string(argv[2]));

  return 0;
}
