# go-os-tutorial

Minimal OS tutorial project in Go + assembly.

Current features:

- Multiboot2 header for GRUB
- 32-bit entry point (`_start`)
- switch to x86_64 long mode
- call into Go (`kernel.Main`)
- VGA text output in text mode
- basic PS/2 keyboard input
- interactive shell with `help`, `clear`, and `about`

At boot the kernel initializes the VGA console, prints `Hello world`, and then starts a minimal shell.

## Requirements

Local builds use a cross toolchain with the `x86_64-elf-` prefix plus:

- `grub-mkrescue`
- `qemu-system-x86_64`

If your tools use a different prefix, override `CROSS`, for example:

```bash
make CROSS=/opt/cross/bin/x86_64-elf
```

## Build

```bash
make
```

This generates:

- `build/kernel.elf`
- `build/go-os-tutorial.iso`

Useful targets:

- `make kernel` builds only `build/kernel.elf`
- `make iso` builds only the bootable ISO
- `make clean` removes build artifacts and `disk.img`

## Run

```bash
make run
```

This boots the ISO in QEMU and creates `disk.img` on first run.

The shell currently uses the Italian keyboard layout defined in [`keyboard/layout.go`](keyboard/layout.go).

## Docker workflow

```bash
make docker-build-only
make docker-run
```

For an interactive container with the toolchain installed:

```bash
make docker-shell
```
