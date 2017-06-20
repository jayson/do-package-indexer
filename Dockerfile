FROM ubuntu:latest

MAINTAINER "Jayson Paul" <jaysonpaul@gmail.com>

RUN apt-get update && apt-get install -y ruby

RUN mkdir /usr/src/package-indexer
ADD src/* /usr/src/package-indexer
WORKDIR /usr/src/package-indexer

EXPOSE 8080
CMD ["/bin/bash"]
#CMD ["./package-indexer"]
