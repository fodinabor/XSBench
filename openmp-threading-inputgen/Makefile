#===============================================================================
# User Options
#===============================================================================

# Compiler can be set below, or via environment variable
ifeq ($(CC),)
CC    = clang
endif
OPTIMIZE    = yes
OPENMP      = no
DEBUG       = no
PROFILE     = no
MPI         = no
AML         = no

#===============================================================================
# Program name & source code list
#===============================================================================

program = XSBench

source = \
Main.c \
io.c \
Simulation.c \
GridInit.c \
XSutils.c \
Materials.c

obj = $(source:.c=.o)
objopt = $(source:.c=.opt)

#===============================================================================
# Sets Flags
#===============================================================================

# Make sure we didn't pick up lower case cc
ifeq (cc,$(CC))
CC    = clang
endif

# Standard Flags
CFLAGS := -std=gnu99 -Wall -disable-llvm-passes

# Linker Flags
LDFLAGS = -lm -fuse-ld=lld

# Regular gcc Compiler
ifneq (,$(findstring gcc,$(CC)))
  CFLAGS += -flto
  ifeq ($(OPENMP),yes)
	CFLAGS +=
  endif
endif

# LLVM Compiler
ifneq (,$(findstring clang,$(CC)))
  CFLAGS += -flto
  ifeq ($(OPENMP),yes)
	CFLAGS +=
  endif
endif

# Intel Compiler
ifneq (,$(findstring intel,$(CC)))
  CFLAGS += -ipo
  ifeq ($(OPENMP),yes)
	CFLAGS +=
  endif
endif

# Debug Flags
ifeq ($(DEBUG),yes)
  CFLAGS += -g
  LDFLAGS  += -g
endif

# Profiling Flags
ifeq ($(PROFILE),yes)
  CFLAGS += -pg
  LDFLAGS  += -pg
endif

# # Optimization Flags
# ifeq ($(OPTIMIZE),yes)
#   CFLAGS += -O3
# endif

# MPI
ifeq ($(MPI),yes)
  CC = mpicc
  CFLAGS += -DMPI
endif

# AML
ifeq ($(AML),yes)
  LDFLAGS += $(shell pkg-config --libs aml)
  CFLAGS += -DAML $(shell pkg-config --cflags aml)
endif

#===============================================================================
# Targets to Build
#===============================================================================

$(program): $(obj) XSbench_header.h Makefile
	$(CC) $(CFLAGS) $(obj) -o $@ $(LDFLAGS) -O1

$(program).opt: $(objopt) XSbench_header.h Makefile
	$(CC) $(CFLAGS) $(objopt) -o $@ $(LDFLAGS) -O3

%.o: %.c XSbench_header.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@ -O1

%.opt: %.c XSbench_header.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@ -O3

clean:
	rm -rf $(program) $(obj) $(objopt)

edit:
	vim -p $(source) XSbench_header.h

run:
	./$(program)

default: $(program) $(program).opt
