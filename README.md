# do-package-indexer

## Building Docker Image
This takes params for -p, -m and -M for bumping the patch, minor and major
versions respectively of the last tag
```bash
./build-indexer
```

## Running Docker Image
```bash
./run-indexer
```

### Running without Docker
```bash
cd src
./package-indexer.rb
```
