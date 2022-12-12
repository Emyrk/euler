package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

func noop(cpu *CPU) {
	// increment cycle, then calculate
	cpu.draw()
	cpu.Cycle++
	cpu.strength()
}

func addx(cpu *CPU, value int) {
	cpu.draw()
	cpu.Cycle++
	cpu.strength()

	cpu.draw()
	cpu.Cycle++
	cpu.strength()

	cpu.Value += value
}

type CPU struct {
	Cycle    int
	Value    int
	Strength int
}

func (c *CPU) Run(rdr io.Reader) {
	buf := bufio.NewReader(rdr)
	for {
		line, ok := nextLine(buf)
		if !ok {
			c.draw()
			return
		}

		split := strings.Split(line, " ")
		switch split[0] {
		case "noop":
			noop(c)
		case "addx":
			addx(c, must(strconv.Atoi(split[1])))
		}
	}
}

func (c *CPU) strength() {
	if c.Cycle == 20 || (c.Cycle-20)%40 == 0 {
		c.Strength += c.Cycle * c.Value
	}
}

func (c *CPU) draw() {
	if c.Cycle%40 == 0 {
		fmt.Println()
	}
	// Pixel time
	diff := c.Value - (c.Cycle % 40)
	if diff >= -1 && diff <= 1 {
		fmt.Print("#")
	} else {
		fmt.Print(".")
	}
	// fmt.Println(" ", diff, c.Value, c.Cycle%40, c.Cycle)
}

func main() {
	file := must(os.OpenFile("/home/steven/go/src/github.com/Emyrk/euler/aoc2022/day10/input.txt", os.O_RDONLY, 0))
	defer file.Close()

	cpu := &CPU{
		Cycle:    0,
		Value:    1,
		Strength: 0,
	}

	cpu.Run(file)
	fmt.Printf("Strength: %d\n", cpu.Strength)
}

func must[V any](value V, err error) V {
	if err != nil {
		panic(err)
	}
	return value
}

func nextLine(rd *bufio.Reader) (string, bool) {
	line, _, err := rd.ReadLine()
	if errors.Is(err, io.EOF) {
		return "", false
	}
	if err != nil {
		panic(err)
	}
	return string(line), true
}
