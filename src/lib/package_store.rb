require 'thread'
require 'singleton'
require './lib/package'
require './lib/package_logger'

# This class is responsible for handling the storage of packages and
#   dependencies
class PackageStore
  include Singleton

  def initialize
    # Use a single mutex for all threads
    @mutex = Mutex.new
    @index = { packages: [], deps: [] }
  end

  # Adds a package and deps to storage. Thread safe with Mutex
  def add_package(pkg_name, deps)
    with_mutex do
      return true if @index[:packages].include?(pkg_name)

      PackageLogger.instance.debug("Installing #{pkg_name} with #{deps}")
      if deps.length > 0
        puts deps.to_s
        deps.each { |dep|
          puts deps
          PackageLogger.instance.debug("#{pkg_name} searching #{dep}")
          return false unless @index[:packages].include?(dep.to_s)
          PackageLogger.instance.debug("#{pkg_name} found#{dep}")
        }
      end

      PackageLogger.instance.debug("#{pkg_name} push")
      @index[:packages].push(pkg_name)
      PackageLogger.instance.debug("#{pkg_name} pushed")
      true
    end
  end

  # Removes a package if nothing depends on it
  def remove_package(pkg_name)
    puts "Removing #{pkg_name}"
    with_mutex do
      @index[:packages].delete(pkg_name)
      return true
    end
  end

  private

  # Helper method for thread safe locking operations
  def with_mutex
    PackageLogger.instance.debug("waiting for mutex...")
    @mutex.synchronize do
      begin 
        yield
      rescue Exception => e
        PackageLogger.instance.warn("Unable to store pkg index... #{e.tos}")
      end
    end
    PackageLogger.instance.debug("mutex done")
  end
end
