#####
## BUILD
#####
CC=riscv64-unknown-elf-gcc
CFLAGS=-Wall -Wextra -pedantic -Wextra -O0 -g 
CFLAGS+=-static -ffreestanding -nostdlib -fno-rtti -fno-exceptions
CFLAGS+=-march=rv64gc  -mabi=lp64d
INCLUDES=
LINKER_SCRIPT=-Tsrc/lds/virt.lds
TYPE=debug
RUST_TARGET=./target/riscv64gc-unknown-none-elf/$(TYPE)
LIBS=-L$(RUST_TARGET)
SOURCES_ASM=$(wildcard src/asm/*.S)
LIB=-lkernel -lgcc
OUT=os.elf

#####
## QEMU
#####
QEMU=qemu-system-riscv64
MACH=virt
CPU=rv64
CPUS=4
MEM=128M
DRIVE=hdd.dsk

all:
	cargo xbuild --target=riscv64gc-unknown-none-elf
	$(CC) $(CFLAGS) $(LINKER_SCRIPT) $(INCLUDES) -o $(OUT) $(SOURCES_ASM) $(LIBS) $(LIB)
	
run: all
	$(QEMU) -machine $(MACH) -cpu $(CPU) -smp $(CPUS) -m $(MEM)  -serial mon:stdio -bios none -kernel $(OUT) -drive if=none,format=raw,file=$(DRIVE),id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0


.PHONY: clean
clean:
	cargo clean
	rm -f $(OUT)
