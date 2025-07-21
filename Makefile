# ============================================================
#   Flexible RISC-V Assembly Makefile
#   Usage:  make            (build default *.s)
#           make run        (run default *.s)
#           make FILE=foo.s      (build foo.s)
#           make run FILE=bar.s  (build & run bar.s)
# ============================================================

# -------- toolchain prefix (override on command line) -------
RISCV_PREFIX ?= riscv64-unknown-elf
AS      := $(RISCV_PREFIX)-as
LD      := $(RISCV_PREFIX)-ld
OBJDUMP := $(RISCV_PREFIX)-objdump

# -------- flags ---------------------------------------------
ASFLAGS :=
LDFLAGS :=

# -------- source file (may pass FILE=xyz.s) -----------------

# Strip extension to form object / elf names
BASE  := $(basename $(FILE))
OBJ   := $(BASE).o
ELF   := $(BASE).elf

# -------- default target ------------------------------------
all: $(ELF)

# ---------- rules -------------------------------------------
$(OBJ): $(FILE)
	$(AS) $(ASFLAGS) -o $@ $<

$(ELF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $<

# ---------- helpers -----------------------------------------
.PHONY: run
run: $(ELF)
	spike pk $(ELF)

.PHONY: dump
dump: $(ELF)
	$(OBJDUMP) -d $(ELF) | less

.PHONY: clean
clean:
	rm -f $(OBJ) $(ELF)

