require 'logger'
require 'singleton'

# Singleton logger wrapper
class PackageLogger
  include Singleton

  def initialize(file = '/var/log/package-indexer/index.log')
    @logger = Logger.new(file)
    @logger.level = Logger::WARN
  end

  # Pass through our logger methods to standard Logger class
  %w[info warn debug fatal level add].each do |method|
    define_method method.to_s do |*args|
      @logger.public_send(method.to_s, *args)
    end
  end
end
