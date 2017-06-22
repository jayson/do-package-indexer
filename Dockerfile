FROM ubuntu:latest

MAINTAINER "Jayson Paul" <jaysonpaul@gmail.com>

# Install ruby
RUN apt-get update && apt-get install -y ruby

# Make src, data and log directories for package installer
RUN mkdir /usr/src/package-indexer
RUN mkdir /var/lib/package-indexer
RUN mkdir /var/log/package-indexer

# Place ruby source in /usr/src/package-installer
ADD src/* /usr/src/package-indexer

# Run our package indexer with this cwd so relative requires work
WORKDIR /usr/src/package-indexer

# Our service runs on 8080
EXPOSE 8080

# Testing CMD
CMD ["/bin/bash"]

# Package Indexing Daemon
#CMD ["./package-indexer"]
