#!/usr/bin/env ruby

require 'lib/package_indexer'

server = new PackageIndexer
server.run(8080)
