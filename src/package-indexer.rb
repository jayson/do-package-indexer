#!/usr/bin/env ruby

require 'socket'
require 'pstore'

server = TCPServer.open(8080)
loop do
  Thread.start(server.accept) do |client|
    client.puts(Time.now.ctime) # Send the time to the client
    client.close                # Disconnect from the client
  end
end
