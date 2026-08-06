#!/bin/bash
# Purpose: Quick local build and stockfish bench run.
set -eu -o pipefail

make clean
make -j build ARCH=x86-64-modern > /dev/null
./stockfish bench
