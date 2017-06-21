require 'socket'
require 'lib/package_command'

# This class is responsible for running the package index server
class PackageIndexer
  def run_server(port = 8080)
    server = TCPServer.open(port)

    loop do
      Thread.start(server.accept) do |client|
        loop do
          line = client.gets
          puts line
        end
      end
    end
  end
end
