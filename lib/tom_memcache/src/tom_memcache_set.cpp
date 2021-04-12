#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
  
#define SERVER_PORT     4334
#define MAX_BUFFER_SIZE 1024
  
int main() {
  int socket_file_descriptor;
  char socket_buffer[MAX_BUFFER_SIZE];
  const char *message = "Testing from client messageeee";
  struct sockaddr_in servaddr;

  if ( (socket_file_descriptor = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) {
    perror("socket creation failed");
    exit(EXIT_FAILURE);
  }

  memset(&servaddr, 0, sizeof(servaddr));

  servaddr.sin_family = AF_INET;
  servaddr.sin_addr.s_addr = INADDR_ANY;
  //servaddr.sin_addr.s_addr = INADDR_LOOPBACK;
  servaddr.sin_port = htons(SERVER_PORT);

  socklen_t length;

  sendto(socket_file_descriptor, (const char *)message, strlen(message), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr));
  printf("message sent.\n");

  int server_message_length = recvfrom(socket_file_descriptor, (char *)socket_buffer, MAX_BUFFER_SIZE, MSG_WAITALL, (struct sockaddr *) &servaddr, &length);
  socket_buffer[server_message_length] = '\0';
  printf("Server : %s\n", socket_buffer);

  close(socket_file_descriptor);
  return 0;
}
