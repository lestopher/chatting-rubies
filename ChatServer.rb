require 'socket'

# Catch SIGINT <ctrl+c>
trap("SIGINT") { 
     begin
         # Catch exceptions 
         puts "Closing client sockets"
         instanceChatServer.close_clients 
         puts "...Done"
         puts "Bringing Chat Server down"
         instanceChatServer.close_server
     rescue
         puts "Failed to close server socket"
     ensure 
         puts "Exiting."
         exit
     end
}

class ChatServer

  def initialize(port)
    @descriptors = Array::new
    @serverSocket = TCPServer.new("", port)
    @serverSocket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    printf("Chatserver started on port %d\n", port)
    @descriptors.push(@serverSocket)

  end # End initialize

  def run

    while 1

      res = select(@descriptors, nil, nil, nil)

      if res != nil then

        # Iterate through the tagged read descriptors
        for sock in res[0]

          # Received a connect to the server (listening) socket
          if sock == @serverSocket then
            accept_new_connection
          else
            # Received something on a client socket
            if sock.eof? then
              str = sprintf("Client left %s:%s\n",
                            sock.peeraddr[2], sock.peeraddr[1])
              broadcast_string(str, sock)
              sock.close
              @descriptors.delete(sock)
            else
              str = sprintf("[%s|%s]: %s",
                            sock.peeraddr[2], sock.peeraddr[1], sock.gets())
              broadcast_string(str, sock)
            end # End if sock.eof? then
          end # End sock == @serverSocket then

        end # End for sock in res[0]
      end # End if res!= nil then
    end # End while

  end # End run

  private

  def broadcast_string(str, omit_sock)

    @descriptors.each do |client_sock|
      if client_sock != @serverSocket && client_sock != omit_sock
        client_sock.write(str)
      end
    end

    print(str)

  end # End broadcast_string

  def accept_new_connection

    newsock = @serverSocket.accept
    @descriptors.push(newsock)

    newsock.write("You've connected to the Ruby chatserver\n")

    str = sprintf("Client joined %s:%s\n",
                  newsock.peeraddr[2], newsock.peeraddr[1])

    broadcast_string(str, newsock)

  end # End accept_new_connection

  def close_clients

    @descriptors.each do |client_sock|
      client_sock.close
      @descriptors.delete(client_sock)
    end

  end # End close_clients
      
  def close_server

    @serverSocket.close

  end # End close_server

end # End ChatServer


instanceChatServer = ChatServer.new(33333).run


