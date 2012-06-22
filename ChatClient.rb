require 'socket'

# Catch SIGINT <ctrl+c>
trap("SIGINT") { 
     begin
         # Catch exceptions 
         puts "Closing client sockets"
         instanceChatClient.close_connection
         puts "...Done"
     rescue
         puts "Failed to close server socket"
     ensure 
         puts "Exiting."
         exit
     end
}

class ChatClient

  def initialize(hostname, port)
    @descriptors = Array::new
    @serverConnection = TCPSocket.open(hostname, port)
    
    if @serverConnection then
      printf("Connected to server %s on %d\n", hostname, port)
      @descriptors.push(@serverConnection)
    else
      printf("Failed to connect, exiting\n")
      exit
    end
    
  end # End initialize

  def run
    res = select(@descriptors, nil, nil, nil)

    if res != nil then
      for sock_print in res[0]
          sock_print = res[0]
          str = sprintf("message> %s", sock_print.gets())
          print str
      end
    end
  end

  def close_connection
    @serverConnection.close
  end # End close_connection

end # End Chat Client

instanceChatClient = ChatClient.new('127.0.0.1', 33333).run

