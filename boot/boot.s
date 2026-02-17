.code32

.set MULTIBOOT_MAGIC, 0xE85250D6
.set MULTIBOOT_ARCH,  0

.section .multiboot2
.align 8

multiboot_header_start:
	.long MULTIBOOT_MAGIC
	.long MULTIBOOT_ARCH
	.long multiboot_header_end - multiboot_header_start
	.long -(MULTIBOOT_MAGIC + MULTIBOOT_ARCH + (multiboot_header_end - multiboot_header_start))

# Info request tag: memory map (6), ELF sections (9)
	.align 8
	.word 1
	.word 0
	.long 16
	.long 6
	.long 9

# Entry address tag
	.align 8
	.word 3
	.word 0
	.long 16
	.long _start
	.long 0

# End tag
	.align 8
	.word 0
	.word 0
	.long 8

multiboot_header_end:

.section .bootstrap_stack, "aw", @nobits

.align 16
stack_bottom:
	.skip 16384
stack_top:

# Long mode paging structures (4 KiB aligned, zero-initialized).
.align 4096
pml4:
	.skip 4096
.align 4096
pdpt:
	.skip 4096
.align 4096
pd0:
	.skip 4096
.align 4096
pd1:
	.skip 4096
.align 4096
pd2:
	.skip 4096
.align 4096
pd3:
	.skip 4096
.global __bootstrap_end
__bootstrap_end:

.align 4
multiboot_info_ptr:
	.long 0

.section .rodata
.align 8
gdt64:
	.quad 0x0000000000000000
	.quad 0x00AF9A000000FFFF
	.quad 0x00CF92000000FFFF

gdt64_desc:
	.word (gdt64_end - gdt64 - 1)
	.long gdt64

gdt64_end:

.section .text
.global  _start
.type    _start, @function

# GRUB jumps here with:
# EAX = 0x36D76289 (Multiboot2 magic)
# EBX = physical address of the Multiboot2 info structure
_start:
	cli

	# Set a temporary 32-bit stack.
	mov  $stack_top, %esp

	# Save Multiboot2 info pointer for long_mode_entry.
	movl %ebx, multiboot_info_ptr

	call setup_long_mode

	cli
.Lhang:
	jmp .Lhang
.size _start, . - _start

setup_long_mode:
	# Build minimal identity-mapped paging (4 GiB via 2 MiB pages).
	lea pml4, %edi
	movl $pdpt, %eax
	orl $0x03, %eax
	movl %eax, (%edi)
	movl $0, 4(%edi)

	lea pdpt, %edi
	movl $pd0, %eax
	orl $0x03, %eax
	movl %eax, (%edi)
	movl $0, 4(%edi)
	movl $pd1, %eax
	orl $0x03, %eax
	movl %eax, 8(%edi)
	movl $0, 12(%edi)
	movl $pd2, %eax
	orl $0x03, %eax
	movl %eax, 16(%edi)
	movl $0, 20(%edi)
	movl $pd3, %eax
	orl $0x03, %eax
	movl %eax, 24(%edi)
	movl $0, 28(%edi)

	movl $0x83, %edx  # present|rw|ps

	lea pd0, %edi
	xorl %ecx, %ecx
	movl $0x00000000, %ebx
.Lmap_2m_pd0:
	movl %ecx, %eax
	shll $21, %eax
	addl %ebx, %eax
	orl %edx, %eax
	movl %eax, (%edi)
	movl $0, 4(%edi)
	addl $8, %edi
	incl %ecx
	cmpl $512, %ecx
	jne .Lmap_2m_pd0

	lea pd1, %edi
	xorl %ecx, %ecx
	movl $0x40000000, %ebx
.Lmap_2m_pd1:
	movl %ecx, %eax
	shll $21, %eax
	addl %ebx, %eax
	orl %edx, %eax
	movl %eax, (%edi)
	movl $0, 4(%edi)
	addl $8, %edi
	incl %ecx
	cmpl $512, %ecx
	jne .Lmap_2m_pd1

	lea pd2, %edi
	xorl %ecx, %ecx
	movl $0x80000000, %ebx
.Lmap_2m_pd2:
	movl %ecx, %eax
	shll $21, %eax
	addl %ebx, %eax
	orl %edx, %eax
	movl %eax, (%edi)
	movl $0, 4(%edi)
	addl $8, %edi
	incl %ecx
	cmpl $512, %ecx
	jne .Lmap_2m_pd2

	lea pd3, %edi
	xorl %ecx, %ecx
	movl $0xC0000000, %ebx
.Lmap_2m_pd3:
	movl %ecx, %eax
	shll $21, %eax
	addl %ebx, %eax
	orl %edx, %eax
	movl %eax, (%edi)
	movl $0, 4(%edi)
	addl $8, %edi
	incl %ecx
	cmpl $512, %ecx
	jne .Lmap_2m_pd3

	# Load PML4 and enable PAE.
	movl $pml4, %eax
	movl %eax, %cr3

	movl %cr4, %eax
	orl  $0x20, %eax
	movl %eax, %cr4

	# Enable long mode in EFER.
	movl $0xC0000080, %ecx
	rdmsr
	orl  $0x100, %eax
	wrmsr

	# Load GDT and enable paging.
	lgdt gdt64_desc
	movl %cr0, %eax
	orl  $0x80000000, %eax
	movl %eax, %cr0

	# Far jump to 64-bit code segment.
	ljmp $0x08, $long_mode_entry

.code64
long_mode_entry:
	movw $0x10, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw %ax, %fs
	movw %ax, %gs

	movq $stack_top, %rsp
	andq $-16, %rsp
	subq $8, %rsp

	# Clear BSS.
	movq $__bss_start, %rdi
	movq $__bss_end, %rcx
	subq %rdi, %rcx
	xor %eax, %eax
	rep stosb

	# Pass Multiboot2 info pointer to Go entry.
	movl multiboot_info_ptr(%rip), %edi
	call go_0kernel.Main

.Lhang64:
	hlt
	jmp .Lhang64
