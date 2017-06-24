require './lib/package_command.rb'
require './lib/test_logger.rb'

describe '.parse_command' do
  let(:pkg_cmd) { PackageCommand.new }

  context 'with valid commands' do
    it 'parses an index with no deps' do
      cmd_hash = pkg_cmd.parse_command("INDEX|glibc|\n")
      expect(cmd_hash).to eql(type: :INDEX, package: 'glibc', deps: [])
    end

    it 'parses an index with a dependency' do
      cmd_hash = pkg_cmd.parse_command("INDEX|glibc-common|glibc\n")
      expect(cmd_hash).to eql(type: :INDEX, package: 'glibc-common', deps: ['glibc'])
    end

    it 'parses an index with dependencies' do
      cmd_hash = pkg_cmd.parse_command("INDEX|weechat|gc,guile,v8\n")
      expect(cmd_hash).to eql(type: :INDEX, package: 'weechat', deps: %w[gc guile v8])
    end

    it 'parses a query command' do
      cmd_hash = pkg_cmd.parse_command("QUERY|weechat|\n")
      expect(cmd_hash).to eql(type: :QUERY, package: 'weechat', deps: [])
    end

    it 'parses a remove command' do
      cmd_hash = pkg_cmd.parse_command("REMOVE|weechat|\n")
      expect(cmd_hash).to eql(type: :REMOVE, package: 'weechat', deps: [])
    end
  end

  context 'with invalid commands' do
    it 'has wrong number of params' do
      cmd_hash = pkg_cmd.parse_command("INDEX|abc\n")
      expect(cmd_hash).to eql(type: :error)
    end

    it 'has an invalid command' do
      cmd_hash = pkg_cmd.parse_command("DESTROY|abc|\n")
      expect(cmd_hash).to eql(type: :error)
    end

    it 'has an empty package' do
      cmd_hash = pkg_cmd.parse_command("INDEX||\n")
      expect(cmd_hash).to eql(type: :error)
    end

    it 'has an invalid package names' do
      cmd_hash = pkg_cmd.parse_command("INDEX|expect!|\n")
      expect(cmd_hash).to eql(type: :error)
    end

    it 'has an invalid dependency names' do
      cmd_hash = pkg_cmd.parse_command("INDEX|glibc|a,b,c$,g\n")
      expect(cmd_hash).to eql(type: :error)
    end
  end
end

describe '.run_command' do
  let(:pkg_cmd) { PackageCommand.new }

  context 'indexing packages' do
    it 'adds package with no deps' do
      response = pkg_cmd.run_command("INDEX|glibc|\n")
      expect(response).to eql("OK\n")
    end

    it 'adds package with no deps met' do
      response = pkg_cmd.run_command("INDEX|glibc-common|glibc\n")
      expect(response).to eql("OK\n")
    end

    it 'checks deps requirement' do
      response = pkg_cmd.run_command("INDEX|weechat|gc,guile,v8\n")
      expect(response).to eql("FAIL\n")
    end

    it 'adds package already indexed' do
      response = pkg_cmd.run_command("INDEX|glibc|\n")
      expect(response).to eql("OK\n")
    end

    it 'will delete old deps on multiple INDEX commands' do
      response = pkg_cmd.run_command("INDEX|pkg1|\n")
      expect(response).to eql("OK\n")
      response = pkg_cmd.run_command("INDEX|pkg2|\n")
      expect(response).to eql("OK\n")
      response = pkg_cmd.run_command("INDEX|jpaul|pkg1,pkg2\n")
      expect(response).to eql("OK\n")
      response = pkg_cmd.run_command("INDEX|jpaul|pkg1\n")
      expect(response).to eql("OK\n")
      # Should be able to remove this now that jpaul no longer depends on it
      response = pkg_cmd.run_command("REMOVE|pkg2|\n")
      expect(response).to eql("OK\n")
    end

    it 'will add new deps on multiple INDEX commands' do
      response = pkg_cmd.run_command("INDEX|pkg1|\n")
      expect(response).to eql("OK\n")
      response = pkg_cmd.run_command("INDEX|pkg2|\n")
      expect(response).to eql("OK\n")
      response = pkg_cmd.run_command("INDEX|jpaul|pkg1\n")
      expect(response).to eql("OK\n")
      response = pkg_cmd.run_command("INDEX|jpaul|pkg1,pkg2\n")
      expect(response).to eql("OK\n")
      response = pkg_cmd.run_command("REMOVE|pkg2|\n")
      expect(response).to eql("FAIL\n")
    end
  end

  context 'querying packages' do
    it 'finds a package' do
      response = pkg_cmd.run_command("QUERY|glibc|\n")
      expect(response).to eql("OK\n")
    end

    it 'cannnot find a package' do
      response = pkg_cmd.run_command("QUERY|weechat|\n")
      expect(response).to eql("FAIL\n")
    end
  end

  context 'removing packages' do
    it 'fails removing dependent packages' do
      response = pkg_cmd.run_command("REMOVE|glibc|\n")
      expect(response).to eql("FAIL\n")
    end

    it 'removes package with no deps' do
      response = pkg_cmd.run_command("REMOVE|glibc-common|\n")
      expect(response).to eql("OK\n")
    end

    it 'removes package with deps gone' do
      response = pkg_cmd.run_command("REMOVE|glibc-common|\n")
      expect(response).to eql("OK\n")
    end

    it 'returns okay for non-existant packages' do
      response = pkg_cmd.run_command("REMOVE|qt4|\n")
      expect(response).to eql("OK\n")
    end
  end
end
