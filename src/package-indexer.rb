#!/usr/bin/env ruby

require './lib/package_indexer.rb'

server = PackageIndexer.new
server.run_server(8080)
