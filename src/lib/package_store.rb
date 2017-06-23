require 'thread'
require 'singleton'
require './lib/package_logger'

# This class is responsible for handling the storage of packages and
#   dependencies
class PackageStore
  include Singleton

  def initialize
    # Use a single mutex for all threads
    @mutex = Mutex.new
    @index = { packages: {}, deps: {} }
    @logger = PackageLogger.instance
  end

  # Adds a package and deps to storage. Thread safe with Mutex
  def add_package(pkg_name, deps)
    with_mutex do
      @logger.debug("Installing #{pkg_name} with #{deps}")

      # Check if we have dependencies installed
      unless deps.empty?
        deps.each do |dep|
          @logger.debug("#{pkg_name} needs #{dep}")
          return false unless @index[:packages].key?(dep.to_s)
          @logger.debug("#{pkg_name} found #{dep}")
        end
      end

      @index[:packages][pkg_name] = true
      # Store reverse dependency lookup
      unless deps.empty?
        deps.each do |dep|
          @index[:deps][dep] = [] unless @index[:deps].key?(dep)
          @index[:deps][dep].push(pkg_name)
        end
      end
      @index[:deps][pkg_name] = deps
      @logger.info("Added #{pkg_name} to index")
      true
    end
  end

  # Looks up whether or not a package is indexed
  def query_package(pkg_name)
    @logger.info("Querying for #{pkg_name}")
    @index[:packages].key?(pkg_name)
  end

  # Removes a package if nothing depends on it
  def remove_package(pkg_name)
    with_mutex do
      if @index[:deps].key? pkg_name
        @index[:deps][pkg_name].each do |pkg|
          if query_package(pkg)
            @logger.info("Unable to remove package #{pkg_name} due to dependency on #{pkg}")
            return false
          end
        end
      end
      @index[:packages].delete(pkg_name)
      @logger.info("Removed #{pkg_name} from index")
      return true
    end
  end

  private

  # Helper method for thread safe locking operations
  def with_mutex
    @logger.debug('waiting for mutex...')
    @mutex.synchronize do
      begin
        yield
      rescue
        @logger.fatal('Unable to store pkg index...')
      end
    end
    @logger.debug('mutex done')
  end
end
