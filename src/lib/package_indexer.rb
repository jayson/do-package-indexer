require 'socket'
require './lib/package_command'
require './lib/package_logger'

# This class is responsible for running the package index server
class PackageIndexer
  def run_server(port = 8080)
    server = TCPServer.open(port)

    loop do
      pkg_store = PackageStore.instance
      Thread.start(server.accept) do |client|
        cmd = PackageCommand.new

        loop do
          line = client.gets
          PackageLogger.instance.debug("Starting line #{line.chomp}")
          response = cmd.run_command(line)
          PackageLogger.instance.debug("#{line.chomp} Command response: #{response}")
          client.puts response
        end
      end
    end
  end
end
