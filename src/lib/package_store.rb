require 'pstore'
require 'thread'
require 'singleton'
require 'lib/package'

# This class is responsible for handling the storage of packages and
#   dependencies
class PackageStore
  include Singleton

  def initialize
    # Use a single mutex for all threads
    @mutex = Mutex.new
    @packages = {}
  end

  # Adds a package and deps to storage. Thread safe with Mutex
  def add_package(pkg_name, deps)
    with_mutex do
      package = Package.new(pkg_name, deps)
      puts package.to_s
    end
  end

  private

  # Helper method for thread safe locking operations
  def with_mutex
    @mutex.synchronize do
      yield
    end
  end
end
