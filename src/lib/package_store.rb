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
    @index = { packages: [], deps: {} }
  end

  # Adds a package and deps to storage. Thread safe with Mutex
  def add_package(pkg_name, deps)
    with_mutex do
      return true if @index[:packages].include?(pkg_name)

      PackageLogger.instance.debug("Installing #{pkg_name} with #{deps}")
      if deps.length > 0
        deps.each do |dep|
          PackageLogger.instance.debug("#{pkg_name} needs #{dep}")
          return false unless @index[:packages].include?(dep.to_s)
          PackageLogger.instance.debug("#{pkg_name} found #{dep}")
        end
      end

      @index[:packages].push(pkg_name)
      @index[:deps][pkg_name] = deps
      true
    end
  end

  # Looks up whether or not a package is indexed
  def query_package(pkg_name)
    @index[:packages].include?(pkg_name)
  end

  # Removes a package if nothing depends on it
  def remove_package(pkg_name)
    with_mutex do
      if @index[:deps].key? pkg_name
        @index[:deps][pkg_name].each do |pkg|
          return false if query_package(pkg)
        end
      end
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
        PackageLogger.instance.fatal("Unable to store pkg index... #{e.to_s}")
      end
    end
    PackageLogger.instance.debug("mutex done")
  end
end
