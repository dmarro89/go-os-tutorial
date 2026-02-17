package kernel

import "github.com/dmarro89/go-os-tutorial/shell"

func Halt()

func Main(multibootInfoAddr uint64) {
	_ = multibootInfoAddr

	shell.Init()
	shell.Print("Hello world")

	for {
		Halt()
	}
}
