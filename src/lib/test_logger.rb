require 'logger'
require 'singleton'

# Singleton logger wrapper
class PackageLogger
  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  # Pass through our logger methods to standard Logger class
  %w[info warn debug fatal level add].each do |method|
    define_method method.to_s do |*args|
      @logger.public_send(method.to_s, *args)
    end
  end
end
