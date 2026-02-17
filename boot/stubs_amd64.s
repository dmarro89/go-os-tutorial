.code64
.section .text

# github.com/dmarro89/go-os-tutorial/shell.outb(port uint16, value byte)
.global github_0com_1dmarro89_1go_x2dos_x2dtutorial_1shell.outb
.type   github_0com_1dmarro89_1go_x2dos_x2dtutorial_1shell.outb, @function
github_0com_1dmarro89_1go_x2dos_x2dtutorial_1shell.outb:
	movw %di, %dx
	movb %sil, %al
	outb %al, %dx
	ret
.size github_0com_1dmarro89_1go_x2dos_x2dtutorial_1shell.outb, . - github_0com_1dmarro89_1go_x2dos_x2dtutorial_1shell.outb

# void go_0kernel.Halt()
.global go_0kernel.Halt
.type   go_0kernel.Halt, @function
go_0kernel.Halt:
	hlt
	ret
.size go_0kernel.Halt, . - go_0kernel.Halt

# Minimal gccgo/runtime stubs for freestanding kernel builds.
.global __go_register_gc_roots
.type   __go_register_gc_roots, @function
__go_register_gc_roots:
	ret
.size __go_register_gc_roots, . - __go_register_gc_roots

.global __go_runtime_error
.type   __go_runtime_error, @function
__go_runtime_error:
	ret
.size __go_runtime_error, . - __go_runtime_error

.global runtime.gcWriteBarrier
.type   runtime.gcWriteBarrier, @function
runtime.gcWriteBarrier:
	ret
.size runtime.gcWriteBarrier, . - runtime.gcWriteBarrier

.global runtime.goPanicIndex
.type   runtime.goPanicIndex, @function
runtime.goPanicIndex:
	cli
1:
	hlt
	jmp 1b
.size runtime.goPanicIndex, . - runtime.goPanicIndex

.global runtime.goPanicSliceAlen
.type   runtime.goPanicSliceAlen, @function
runtime.goPanicSliceAlen:
	cli
1:
	hlt
	jmp 1b
.size runtime.goPanicSliceAlen, . - runtime.goPanicSliceAlen

.global runtime.goPanicSliceB
.type   runtime.goPanicSliceB, @function
runtime.goPanicSliceB:
	cli
1:
	hlt
	jmp 1b
.size runtime.goPanicSliceB, . - runtime.goPanicSliceB

.global runtime.panicdivide
.type   runtime.panicdivide, @function
runtime.panicdivide:
	cli
1:
	hlt
	jmp 1b
.size runtime.panicdivide, . - runtime.panicdivide

.global runtime.panicmem
.type   runtime.panicmem, @function
runtime.panicmem:
	cli
1:
	hlt
	jmp 1b
.size runtime.panicmem, . - runtime.panicmem

.global runtime.goPanicIndexU
.type   runtime.goPanicIndexU, @function
runtime.goPanicIndexU:
	cli
1:
	hlt
	jmp 1b
.size runtime.goPanicIndexU, . - runtime.goPanicIndexU

.global runtime.memequal
.type   runtime.memequal, @function
runtime.memequal:
	xor %eax, %eax
	ret
.size runtime.memequal, . - runtime.memequal

.global runtime.memequal8..f
.type   runtime.memequal8..f, @function
runtime.memequal8..f:
	xor %eax, %eax
	ret
.size runtime.memequal8..f, . - runtime.memequal8..f

.global runtime.memequal16..f
.type   runtime.memequal16..f, @function
runtime.memequal16..f:
	xor %eax, %eax
	ret
.size runtime.memequal16..f, . - runtime.memequal16..f

.global runtime.memequal32..f
.type   runtime.memequal32..f, @function
runtime.memequal32..f:
	xor %eax, %eax
	ret
.size runtime.memequal32..f, . - runtime.memequal32..f

.global runtime.memequal64..f
.type   runtime.memequal64..f, @function
runtime.memequal64..f:
	xor %eax, %eax
	ret
.size runtime.memequal64..f, . - runtime.memequal64..f
