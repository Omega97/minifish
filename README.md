## minifish

NNUE chess engine that compresses to less than 64kb.

The implementation was based on:

- [Cfish](https://github.com/syzygy1/Cfish) - engine source code foundation
- [Obsidian](https://github.com/gab8192/Obsidian) - elegant NNUE reference code
- [bullet](https://github.com/jw1912/bullet) - for training NNUE
- [Primer](https://github.com/PGG106/Primer) - for creating .bullet format training data, modified to improve filtering

Training data:

- [source binpack training data](https://robotmoon.com/nnue-training-data/) - T77 unfiltered, T79 v6-dd, used as source data
- [final bullet training data](https://huggingface.co/datasets/linrock/bullet-training-data/tree/main) - filtered data used for training

Created for the [FIDE & Google Efficient Chess AI Challenge](https://www.kaggle.com/competitions/fide-google-efficiency-chess-ai-challenge)

---

## Main files

### Engine core (`src/`)

| File                        | Description                                                                                     |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| `main.c`                    | Program entry point: initializes bitboards, threads, TT, NNUE, then enters the UCI loop         |
| `main.py`                   | Kaggle submission wrapper: unpacks the compressed engine and bridges the competition API to UCI |
| `uci.c` / `uci.h`           | UCI protocol handling (position, go, setoption, etc.)                                           |
| `ucioption.c`               | UCI option definitions and parsing                                                              |
| `search.c` / `search.h`     | Alpha-beta search, iterative deepening, and search-related structures                           |
| `evaluate.c` / `evaluate.h` | Position evaluation entry point (delegates to NNUE)                                             |
| `nnue.h`                    | NNUE network layout, dimensions (`HIDDEN_WIDTH`, quant scales), and accumulator API             |
| `nnue_init.c`               | Loads/embeds the NNUE weights at startup                                                        |
| `nnue_fast.c`               | Incremental NNUE accumulator updates and forward pass (SIMD-optimized)                          |
| `position.c` / `position.h` | Board representation, FEN/setup, make/unmake move, Zobrist hashing                              |
| `bitboard.c` / `bitboard.h` | Bitboard tables, attack helpers, and bit operations                                             |
| `movegen.c` / `movegen.h`   | Legal (and pseudo-legal) move generation                                                        |
| `movepick.c` / `movepick.h` | Move ordering (captures, killers, history, etc.)                                                |
| `tt.c` / `tt.h`             | Transposition table                                                                             |
| `thread.c` / `thread.h`     | Search thread management                                                                        |
| `timeman.c` / `timeman.h`   | Time allocation for a search                                                                    |
| `settings.c` / `settings.h` | Runtime engine settings (threads, hash size, etc.)                                              |
| `misc.c` / `misc.h`         | Shared utilities (I/O, engine info, helpers)                                                    |
| `types.h`                   | Core chess types, values, and compile-time helpers                                              |
| `config.h`                  | Selects magic/BMI2/AVX2 bitboard backends                                                       |
| `simd.h`                    | SIMD abstractions used by NNUE                                                                  |
| `psqt.c`                    | Piece-square table data                                                                         |
| `incbin.h`                  | Header for embedding binary assets (e.g. the `.nnue` file) into the binary                      |
| `benchmark.c`               | Built-in benchmark path used by `bench` / PGO builds                                            |

### Attack generation backends (`src/`)

Compile-time alternatives for slider attacks (chosen via `config.h` / Makefile flags):

| File | Description |
|------|-------------|
| `magic-plain.*` / `magic-fancy.*` / `magic-black.*` | Magic bitboard variants |
| `bmi2-plain.*` / `bmi2-fancy.*` | PEXT/BMI2 attack generation |
| `avx2-bitboard.*` | AVX2-based attack generation |

### Build & packaging (`src/`)

| File | Description |
|------|-------------|
| `Makefile` | Build system (arch flags, size-oriented `-Oz`/`-O3` mix, PGO, strip) |
| `build.sh` | Convenience full build for the local architecture |
| `minimal_build.sh` | Size-focused profile build (`minimal=yes`, no bench) and compression size report |
| `tar_gz_prep.sh` | Builds the minimal engine, packs it as `e.7z` + `main.py` into `submission.tar` for Kaggle |
| `bench.sh` | Quick local bench run |

### NNUE weights & tooling (`src/`)

| File | Description |
|------|-------------|
| `*.nnue` | Quantized network weights (raw and rearranged 8-bit variants embedded/used by the engine) |
| `rearrange_nnue.py` | Reorders/quantizes NNUE weights into the layout expected by the engine |
| `compress_nnue.py` | Further compression/zeroing of unused weights for size |
| `print_nnue.py` | Inspects weight ranges and bit-width compatibility |
| `hist_ft_weights.py` / `bucket_hist_weights.py` | Histograms of feature-transformer weights |
| `visualize_weights.py` | Plots NNUE feature-transformer weights |

### Training (`training/`)

| File | Description |
|------|-------------|
| `HL64-*.rs` | [bullet](https://github.com/jw1912/bullet) training schedule for the HL64 network (datasets, LR, SCReLU, quant scales) |
| `requant-HL64.rs` | Loads a checkpoint and exports a requantized `.nnue` with target `QA`/`QB` scales |

---

