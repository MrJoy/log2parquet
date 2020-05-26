# log2parquet

This is not the project you're looking for.

## Setup

```bash
brew install gimme golangci/tap/golangci-lint
eval "$(gimme 1.14.2)"
go get golang.org/x/tools/cmd/goimports

make compile &&
  ./log2parquet &&
  parquet-tools dump output/shoes.parquet

make # Show available tasks
```
