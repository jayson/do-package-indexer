require 'lib/package_store'

# Class to parse and validate command from client
class PackageCommand
  # Immutable constant for valid command strings
  VALID_COMMANDS = %i[INDEX QUERY REMOVE].freeze

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

  private

  # Parse command string and valiate for errors
  def parse_command(cmd)
    # Start with splitting on pipes
    cmd_array = cmd.split('|')

    # Check for invalid number of parameters
    return parse_error if cmd_array.length < 2 || cmd_array.length > 3

    # Check for valid commands
    return parse_error unless VALID_COMMANDS.include?(cmd_array[0].upcase)

    cmd_hash = {}

    cmd_hash
  end

  def execute_command(cmd_hash)
    # Verified to exist and be valid by parse_command method
    case cmd_hash[0]
    when :INDEX
      puts 'indexing package'
    when :QUERY
      puts 'querying package'
    when :REMOVE
      puts 'removing package'
    else
      return command_error
    end

    command_success
  end

  def parse_error
    { type: :error }
  end

  def command_error
    "ERROR\n"
  end

  def command_fail
    "FAIL\n"
  end

  def command_success
    "OK\n"
  end
end
