package shell

import "unsafe"

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
		putRune(rune(s[i]))
	}
}

func putRune(ch rune) {
	vidMem := getVidMem()

	vidMem[row][column][0] = byte(ch)
	vidMem[row][column][1] = color

	column++
	if column >= VGAWidth {
		column = 0
		row++
	}
}

func updateCursor() {
	pos := uint16(row*VGAWidth + column)

	outb(vgaCursorIndexPort, 0x0F)
	outb(vgaCursorDataPort, byte(pos&0xFF))

	outb(vgaCursorIndexPort, 0x0E)
	outb(vgaCursorDataPort, byte((pos>>8)&0xFF))
}
