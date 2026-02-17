CROSS    ?= x86_64-elf

AS       := $(CROSS)-as
GCC      := $(CROSS)-gcc
GCCGO    := $(CROSS)-gccgo
OBJCOPY  := $(CROSS)-objcopy
GCCGOFLAGS := -m64
GRUB_CFG := iso/grub/grub.cfg

GRUBMKRESCUE := grub-mkrescue
QEMU         := qemu-system-x86_64

DOCKER_PLATFORM  := linux/amd64
DOCKER_IMAGE     := go-os-tutorial-toolchain
DOCKER_RUN_FLAGS := -it

BUILD_DIR := build
ISO_DIR   := $(BUILD_DIR)/isodir

KERNEL_ELF := $(BUILD_DIR)/kernel.elf
ISO_IMAGE  := $(BUILD_DIR)/go-os-tutorial.iso

BOOT_SRCS      := $(wildcard boot/*.s)
LINKER_SCRIPT  := boot/linker.ld

MODPATH      := github.com/dmarro89/go-os-tutorial
SHELL_IMPORT := $(MODPATH)/shell

KERNEL_SRCS := $(filter-out %_test.go, $(wildcard kernel/*.go))
SHELL_SRCS  := $(filter-out %_test.go, $(wildcard shell/*.go))

BOOT_OBJ   := $(BUILD_DIR)/boot.o
SHELL_OBJ  := $(BUILD_DIR)/shell.o
SHELL_GOX  := $(BUILD_DIR)/github.com/dmarro89/go-os-tutorial/shell.gox
KERNEL_OBJ := $(BUILD_DIR)/kernel.o

.PHONY: all kernel iso run clean docker-build docker-image docker-shell docker-run docker-build-only

all: $(ISO_IMAGE)

kernel: $(KERNEL_ELF)

iso: $(ISO_IMAGE)

run: $(ISO_IMAGE) disk.img
	$(QEMU) -cdrom $(ISO_IMAGE) -drive file=disk.img,format=raw

disk.img:
	dd if=/dev/zero of=disk.img bs=1M count=20

clean:
	rm -rf $(BUILD_DIR) disk.img

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_OBJ): $(BOOT_SRCS) | $(BUILD_DIR)
	$(AS) $(BOOT_SRCS) -o $(BOOT_OBJ)

$(SHELL_OBJ): $(SHELL_SRCS) | $(BUILD_DIR)
	$(GCCGO) $(GCCGOFLAGS) -static -Werror -nostdlib -nostartfiles -nodefaultlibs \
		-I $(BUILD_DIR) \
		-fgo-pkgpath=$(SHELL_IMPORT) \
		-c $(SHELL_SRCS) -o $(SHELL_OBJ)

$(SHELL_GOX): $(SHELL_OBJ) | $(BUILD_DIR)
	mkdir -p $(dir $(SHELL_GOX))
	$(OBJCOPY) -j .go_export $(SHELL_OBJ) $(SHELL_GOX)

$(KERNEL_OBJ): $(KERNEL_SRCS) $(SHELL_GOX) | $(BUILD_DIR)
	$(GCCGO) $(GCCGOFLAGS) -static -Werror -nostdlib -nostartfiles -nodefaultlibs \
		-I $(BUILD_DIR) \
		-c $(KERNEL_SRCS) -o $(KERNEL_OBJ)

$(KERNEL_ELF): $(BOOT_OBJ) $(SHELL_OBJ) $(KERNEL_OBJ) $(LINKER_SCRIPT)
	$(GCC) -T $(LINKER_SCRIPT) -o $(KERNEL_ELF) \
		-ffreestanding -O2 -nostdlib \
		$(BOOT_OBJ) $(SHELL_OBJ) $(KERNEL_OBJ) -lgcc

$(ISO_DIR)/boot/grub:
	mkdir -p $(ISO_DIR)/boot/grub

$(ISO_DIR)/boot/kernel.elf: $(KERNEL_ELF) $(GRUB_CFG) | $(ISO_DIR)/boot/grub
	cp $(KERNEL_ELF) $(ISO_DIR)/boot/kernel.elf
	cp $(GRUB_CFG) $(ISO_DIR)/boot/grub/grub.cfg

$(ISO_IMAGE): $(ISO_DIR)/boot/kernel.elf
	$(GRUBMKRESCUE) -o $(ISO_IMAGE) $(ISO_DIR)

docker-build: docker-image

docker-image:
	docker build --platform=$(DOCKER_PLATFORM) -t $(DOCKER_IMAGE) .

docker-run: docker-image
	docker run $(DOCKER_RUN_FLAGS) --rm --platform=$(DOCKER_PLATFORM) \
	  -v "$(CURDIR)":/work -w /work $(DOCKER_IMAGE) \
	  make run

docker-build-only: docker-image
	docker run --rm --platform=$(DOCKER_PLATFORM) \
	  -v "$(CURDIR)":/work -w /work $(DOCKER_IMAGE) \
	  make

docker-shell: docker-image
	docker run -it --rm --platform=$(DOCKER_PLATFORM) \
	  -v "$(CURDIR)":/work -w /work $(DOCKER_IMAGE) bash
