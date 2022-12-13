package main

import (
	"bytes"
	"errors"
	"io"
	"os"
	"strings"
)

type Signal struct {
}

func parseSignal(line string) {
	buf := bytes.NewBuffer(line)

	for {
		r, _, err := buf.ReadRune()
		if errors.Is(err, io.EOF) {
			break
		}

		switch r {
		case '[':
		case ']':
		case ',':
		}
	}

}

func parse(data string) {
	split := strings.Split(data, "\n")
	for i := 0; i < len(split); i += 3 {
		// 0 & 1 are pairs
		a, b := split[0], split[1]
	}
}

func main() {
	file := must(os.Open("easy.txt"))
	data := must(io.ReadAll(file))
}

func must[V any](value V, err error) V {
	if err != nil {
		panic(err)
	}
	return value
}
