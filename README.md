# go-os-tutorial

Minimal OS tutorial project in Go + assembly:

- Multiboot2 header for GRUB
- 32-bit entry point (`_start`)
- switch to x86_64 long mode
- call into Go (`kernel.Main`)
- print `Hello world` through VGA text buffer

## Build

```bash
make
```

This generates:

- `build/kernel.elf`
- `build/go-os-tutorial.iso`

## Run

```bash
make run
```

## Docker workflow

```bash
make docker-build-only
make docker-run
```
