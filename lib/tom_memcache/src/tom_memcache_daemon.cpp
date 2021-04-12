#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
  
#define PORT            4334
#define MAX_BUFFER_SIZE 1024

int main() {
  int socket_file_descriptor;
  char socket_buffer[MAX_BUFFER_SIZE];
  struct sockaddr_in servaddr, cliaddr;
  const char* return_message = "Testing from server message";
    
  if ( (socket_file_descriptor = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) {
    perror("socket creation failed");
    exit(EXIT_FAILURE);
  }
    
  memset(&servaddr, 0, sizeof(servaddr));
  memset(&cliaddr, 0, sizeof(cliaddr));

  servaddr.sin_family      = AF_INET;
  servaddr.sin_addr.s_addr = INADDR_ANY;
  //servaddr.sin_addr.s_addr = INADDR_LOOPBACK;
  servaddr.sin_port        = htons(PORT);

  if ( bind(socket_file_descriptor, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0 ) {
    perror("bind failed");
    exit(EXIT_FAILURE);
  }
    
  socklen_t client_address_length = sizeof(cliaddr);
  int message_length = recvfrom(socket_file_descriptor, (char *)socket_buffer, MAX_BUFFER_SIZE, MSG_WAITALL, ( struct sockaddr *) &cliaddr, &client_address_length);
  socket_buffer[message_length] = '\0';
  printf("Client : %s\n", socket_buffer);

  sendto(socket_file_descriptor, (const char *)return_message, strlen(return_message), MSG_CONFIRM, (const struct sockaddr *) &cliaddr, client_address_length);
  printf("message sent.\n");

  return 0;
}
