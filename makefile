KERNELDIR = kernel

BUILDDIR = build
KERNELBUILDDIR = kbuild
BOOTDIR = $(BUILDDIR)/boot
GRUBDIR = $(BOOTDIR)/grub

PASDIRS = -Fukernel/memory -Fukernel/console -Fukernel/utils

ASPARAMS = -g -o $(KERNELBUILDDIR)/init.o
CCPARAMS = -g -T $(KERNELDIR)/arch/i686/linker.ld -o kernel.bin -ffreestanding -fno-pic -O2 -nostdlib
FPCPARAMS = -Aelf -n -O2 -Op3 -Si -Sc -Sg -Xd -CX -XX -Pi386 -Rintel $(PASDIRS) -FU$(KERNELBUILDDIR) -dARCH_i686 -dCONSOLE_MODE_VGA

objects = $(KERNELBUILDDIR)/*.o

mkdirs:
	mkdir ${BUILDDIR}
	mkdir ${KERNELBUILDDIR}
	mkdir ${BOOTDIR}
	mkdir ${GRUBDIR}

fpcbuild:
	@echo 'Compiling kernel'
	fpc $(FPCPARAMS) $(KERNELDIR)/kernel.pas
asbuild:
	@echo 'Compiling init'
	i686-elf-as $(ASPARAMS) $(KERNELDIR)/arch/i686/init.S
link:
	@echo 'Linking objects'
	i686-elf-gcc $(CCPARAMS) $(objects) -o minipOS.bin

install:
	cp minipOS.bin $(BOOTDIR)/minipOS.bin
	cp boot/grub.cfg $(GRUBDIR)/grub.cfg
	grub-mkrescue -o minipOS.iso $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR)
	rm -rf ${KERNELBUILDDIR}

build: mkdirs fpcbuild asbuild link
all: mkdirs fpcbuild asbuild link install clean
