#!/usr/bin/env ruby


require 'socket'

server = TCPServer.open(8080)
loop {
  Thread.start(server.accept) do |client|
    client.puts(Time.now.ctime) # Send the time to the client
    client.puts "Closing the connection. Bye!"
    client.close                # Disconnect from the client
  end
}
