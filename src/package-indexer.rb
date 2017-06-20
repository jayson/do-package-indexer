#!/usr/bin/env ruby

require 'socket'
require 'pstore'

server = TCPServer.open(8080)
loop do
  Thread.start(server.accept) do |client|
    client.puts(Time.now.ctime)
    client.close
  end
end
