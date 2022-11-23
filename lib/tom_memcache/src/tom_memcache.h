#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string>
#include <cstring>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <arpa/inet.h>
#include <netinet/in.h>
 
#define SERVER_IP_ADDRESS      "127.0.0.1"
#define SERVER_PORT            4334
#define MAX_SOCKET_BUFFER_SIZE 10240
#define CLIENT_SOCKET_TIMEOUT  300000 // 300 ms


struct tom_socket {
  struct client_message {
    struct sockaddr_in address;
    socklen_t address_length;
    std::string message;

    client_message(const std::string& p_message, struct sockaddr_in p_address, socklen_t p_address_length) : address(p_address), address_length(p_address_length), message(p_message) {};
  };

 private:
  int file_descriptor;
  char buffer[MAX_SOCKET_BUFFER_SIZE];
  struct sockaddr_in servaddr, cliaddr;
  socklen_t caddress_length;
 public:
  const char* server_ip_address;
  const int server_port;
  const bool is_server;

  tom_socket(const std::string& p_server_ip_address, const int p_server_port_number, const bool p_is_server) : server_ip_address{p_server_ip_address.data()}, server_port{p_server_port_number}, is_server{p_is_server}
  {
    if ( (file_descriptor = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) {
      perror("socket creation failed");
      exit(EXIT_FAILURE);
    }
      
    std::memset(&servaddr, 0, sizeof(servaddr));
    std::memset(&cliaddr, 0, sizeof(cliaddr));
    std::memset(buffer, '\0', sizeof(char) * MAX_SOCKET_BUFFER_SIZE);

    servaddr.sin_family      = AF_INET;
    servaddr.sin_addr.s_addr = inet_addr(server_ip_address);
    servaddr.sin_port        = htons(server_port);

    if (is_server) {
      if ( bind(file_descriptor, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0 ) {
        perror("bind failed");
        exit(EXIT_FAILURE);
      }
    }

    caddress_length = sizeof(cliaddr);
  }

  const client_message listen_for_client_message() {
    std::memset(buffer, '\0', sizeof(char) * MAX_SOCKET_BUFFER_SIZE);
    recvfrom(file_descriptor, (char *)buffer, MAX_SOCKET_BUFFER_SIZE, MSG_WAITALL, (struct sockaddr *) &cliaddr, &caddress_length);
    return client_message(std::string(buffer), cliaddr, caddress_length);
  }

  inline void respond_to_client(const std::string& message, const struct sockaddr_in client_address, const socklen_t client_address_length) const {
    const char* message_data = message.data();
    sendto(file_descriptor, message_data, strlen(message_data), MSG_CONFIRM, (const struct sockaddr *) &client_address, client_address_length);
  }

  void message_server(const std::string& message) const {
    const char* message_data = message.data();
    sendto(file_descriptor, message_data, strlen(message_data), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr));
  }
  
  const std::string listen_for_server_response() {
    socklen_t address_length;
    struct timeval timeout;

    timeout.tv_sec  = 0;
    timeout.tv_usec = CLIENT_SOCKET_TIMEOUT;
    if (setsockopt(file_descriptor, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0) {
      perror("Error");
    }

    recvfrom(file_descriptor, (char *)buffer, MAX_SOCKET_BUFFER_SIZE, MSG_WAITALL, (struct sockaddr *) &servaddr, &address_length);
    return std::string(buffer);
  }

  virtual ~tom_socket() {
    close(file_descriptor);
  }
};
