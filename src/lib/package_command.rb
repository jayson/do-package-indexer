require './lib/package_store'

# Class to parse and validate command from client
class PackageCommand
  # Immutable constants for valid command strings
  VALID_COMMANDS = %i[INDEX QUERY REMOVE].freeze
  OK_RESPONSE = "OK\n".freeze
  ERROR_RESPONSE = "ERROR\n".freeze
  FAIL_RESPONSE = "FAIL\n".freeze

  def initialize
    @logger = PackageLogger.instance
  end

  def run_command(cmd)
    # Do some inital sanity checks
    return command_error if cmd.empty?

    # Parse command into hash with format
    # { :type => :index, :package => "cloog", :deps => "gmp,isl,pkg-config" }
    cmd_hash = parse_command(cmd)

    # Bubble up errors in parsing
    return command_error if cmd_hash[:type] == :error

    execute_command(cmd_hash)
  end

  # Parse command string and valiate for errors
  def parse_command(cmd)
    cmd.chomp!
    @logger.debug("Received #{cmd} from socket")
    # Start with splitting on pipes

    return parse_error if cmd.count('|') != 2
    cmd_array = cmd.split('|')

    @logger.debug("Parsed cmd into array: #{cmd_array}")

    return parse_error unless valid_command?(cmd_array)

    @logger.debug("Command valid: #{cmd_array}")

    # Return parsed command line
    cmd_hash = {}
    cmd_hash[:type] = cmd_array[0].upcase.to_sym
    cmd_hash[:package] = cmd_array[1].downcase
    cmd_hash[:deps] = []
    cmd_hash[:deps] = cmd_array[2].downcase.split(',') if cmd_array.length == 3

    @logger.debug("Parsed hash: #{cmd_hash}")

    cmd_hash
  end

  private

  def valid_command?(cmd_array)
    # Check for invalid number of parameters
    if cmd_array.length < 2 || cmd_array.length > 3
      @logger.debug("Invalid number of params for #{cmd_array}")
      return false
    end

    # Check for valid commands
    unless VALID_COMMANDS.include?(cmd_array[0].upcase.to_sym)
      @logger.debug("Invalid command: #{cmd_array[0]}")
      return false
    end

    # Check for empty package names
    if cmd_array[1].empty?
      @logger.debug('Package Name Empty')
      return false
    end

    # Check for invalid package names
    if /[^a-zA-Z0-9\-_+]/ =~ cmd_array[1]
      @logger.debug("Invalid package name #{cmd_array[1]}")
      return false
    end

    # Check for invalid dep names and allow multiple packages with comma
    if cmd_array[0].casecmp('INDEX') && /[^a-zA-Z0-9\-_+,]/ =~ cmd_array[2]
      @logger.debug("Invalid deps format: #{cmd_array[2]}")
      return false
    end

    true
  end

  def execute_command(cmd_hash)
    # Package Name is required
    unless cmd_hash.key?(:package) && !cmd_hash[:package].empty?
      return command_error
    end

    case cmd_hash[:type]
    when :INDEX
      result = PackageStore.instance.add_package(cmd_hash[:package], cmd_hash[:deps])
      return command_fail unless result
    when :QUERY
      result = PackageStore.instance.query_package(cmd_hash[:package])
      return command_fail unless result
    when :REMOVE
      result = PackageStore.instance.remove_package(cmd_hash[:package])
      return command_fail unless result
    else
      return command_error
    end

    command_success
  end

  def parse_error
    { type: :error }
  end

  def command_error
    ERROR_RESPONSE
  end

  def command_fail
    FAIL_RESPONSE
  end

  def command_success
    OK_RESPONSE
  end
end
