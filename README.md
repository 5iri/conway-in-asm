# Conway's Game of Life in RISC-V Assembly

This project implements Conway's Game of Life on an 8x8 grid, written in RISC-V assembly. The simulation runs in a terminal emulator that supports VT100 escape codes, animating the evolution of the grid in real time.

## Features
- 8x8 grid with a glider pattern as the initial state
- True Conway's Game of Life rules (birth, survival, death)
- Uses VT100 escape codes to animate the grid in-place
- Adjustable delay for animation speed
- No dependencies beyond a RISC-V simulator (e.g., spike, QEMU)

## Files
- `conway.S` — Main source file with the Game of Life logic and animation loop
- `Makefile` — Build and run targets for your RISC-V toolchain

## How It Works
- The program prints an intro and saves the cursor position.
- It repeatedly restores the cursor, prints the current grid, waits, computes the next generation, and repeats.
- The grid is updated in-place using a temporary buffer for the next generation.
- The animation continues indefinitely.

## Usage
1. **Build:**
   ```sh
   make
   ```
2. **Run (with spike):**
   ```sh
   make run
   ```
   Or run with your preferred RISC-V simulator.

## Customization
- **Initial Pattern:** Edit the `grid` in the `.data` section of `conway.S`.
- **Animation Speed:** Change the `DELAY_CYCLES` constant in `conway.S`.

## Requirements
- RISC-V toolchain (assembler, linker, and simulator)
- Terminal emulator with VT100 support (for cursor movement)

## License
MIT License. See LICENSE file if present.

---
Inspired by classic cellular automata and low-level programming fun!
