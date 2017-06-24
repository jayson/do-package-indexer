# do-package-indexer

## Building Docker Image
This takes params for -p, -m and -M for bumping the patch, minor and major
versions respectively of the last tag
```bash
./build-indexer -p
```

## Running Docker Image
```bash
./run-indexer
```

### Running without Docker
```bash
sudo mkdir /var/log/package-indexer # make your log directory
cd src
./package-indexer.rb
```

### Running the tests
Requires rubocop, rake and rspec for running tests
```bash
cd src
rake
```
