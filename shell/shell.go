package shell

import (
	"unsafe"

	"github.com/dmarro89/go-os-tutorial/keyboard"
)

func outb(port uint16, value byte)

const (
	VGAWidth  = 80
	VGAHeight = 25

	vgaCursorIndexPort uint16 = 0x3D4
	vgaCursorDataPort  uint16 = 0x3D5
)

const videoMemoryAddr uintptr = 0xB8000

func getVidMem() *[VGAHeight][VGAWidth][2]byte {
	return (*[VGAHeight][VGAWidth][2]byte)(unsafe.Pointer(videoMemoryAddr))
}

const (
	colorBlack     = 0
	colorLightGrey = 7
)

var (
	column int
	row    int
	color  byte
)

func Init() {
	color = makeColor(colorLightGrey, colorBlack)
	column = 0
	row = 0
	Clear()
}

func makeColor(fg, bg byte) byte {
	return fg | (bg << 4)
}

func Clear() {
	vidMem := getVidMem()
	for r := 0; r < VGAHeight; r++ {
		for c := 0; c < VGAWidth; c++ {
			vidMem[r][c][0] = ' '
			vidMem[r][c][1] = color
		}
	}
	column = 0
	row = 0
	updateCursor()
}

func Print(s string) {
	for i := 0; i < len(s); i++ {
		putByte(s[i])
	}
}

func putRune(ch rune) {
	if ch == 0 {
		return
	}

	if ch > 0xFF {
		ch = '?'
	}

	putByte(byte(ch))
}

func putByte(ch byte) {
	scrollIfNeeded()

	switch ch {
	case '\n':
		column = 0
		row++
	case '\b':
		if column == 0 {
			if row == 0 {
				updateCursor()
				return
			}
			row--
			column = VGAWidth - 1
		} else {
			column--
		}

		vidMem := getVidMem()
		vidMem[row][column][0] = ' '
		vidMem[row][column][1] = color
	default:
		vidMem := getVidMem()
		vidMem[row][column][0] = ch
		vidMem[row][column][1] = color

		column++
		if column >= VGAWidth {
			column = 0
			row++
		}
	}

	scrollIfNeeded()
	updateCursor()
}

func scrollIfNeeded() {
	if row < VGAHeight {
		return
	}

	vidMem := getVidMem()
	for r := 1; r < VGAHeight; r++ {
		for c := 0; c < VGAWidth; c++ {
			vidMem[r-1][c][0] = vidMem[r][c][0]
			vidMem[r-1][c][1] = vidMem[r][c][1]
		}
	}

	for c := 0; c < VGAWidth; c++ {
		vidMem[VGAHeight-1][c][0] = ' '
		vidMem[VGAHeight-1][c][1] = color
	}

	row = VGAHeight - 1
}

func updateCursor() {
	pos := uint16(row*VGAWidth + column)

	outb(vgaCursorIndexPort, 0x0F)
	outb(vgaCursorDataPort, byte(pos&0xFF))

	outb(vgaCursorIndexPort, 0x0E)
	outb(vgaCursorDataPort, byte((pos>>8)&0xFF))
}

func readLine(buf []rune) int {
	pos := 0

	for {
		r := keyboard.ReadKey()
		switch r {
		case '\b':
			if pos > 0 {
				pos--
				putRune(r)
			}
		case '\n':
			putRune(r)
			return pos
		default:
			if pos < len(buf) {
				buf[pos] = r
				pos++
				putRune(r)
			}
		}
	}
}

func RunShell() {
	var line [80]rune
	for {
		Print("> ")
		n := readLine(line[:])
		execute(line[:n], n)
	}
}

func execute(buf []rune, n int) {
	if n == 0 {
		return
	}

	if n == 4 &&
		buf[0] == 'h' &&
		buf[1] == 'e' &&
		buf[2] == 'l' &&
		buf[3] == 'p' {
		Print("Available commands:\n")
		Print("  help   - show this help\n")
		Print("  clear  - clear the screen\n")
		Print("  about  - info about DavideOS\n")
		return
	}

	if n == 5 &&
		buf[0] == 'c' &&
		buf[1] == 'l' &&
		buf[2] == 'e' &&
		buf[3] == 'a' &&
		buf[4] == 'r' {
		Clear()
		return
	}

	if n == 5 &&
		buf[0] == 'a' &&
		buf[1] == 'b' &&
		buf[2] == 'o' &&
		buf[3] == 'u' &&
		buf[4] == 't' {
		Print("Dav-OS-Go tutorial kernel\n")
		return
	}

	Print("Unknown command: ")
	for i := 0; i < n; i++ {
		putRune(buf[i])
	}
	Print("\nType 'help' for a list of commands.\n")
}
