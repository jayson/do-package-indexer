require 'socket'
require './lib/package_command'
require './lib/package_logger'

# This class is responsible for running the package index server
class PackageIndexer
  def run_server(port = 8080)
    server = TCPServer.open(port)

    loop do
      Thread.start(server.accept) do |client|
        cmd = PackageCommand.new

        loop do
          begin
            line = client.gets
            PackageLogger.instance.info("Starting line #{line.chomp}")
            response = cmd.run_command(line)
            PackageLogger.instance.info("#{line.chomp} Command response: #{response}")
            client.puts response
          rescue
            PackageLogger.instance.fatal("#{line.chomp} threw an exception")
          end
        end
      end
    end
  end
end
