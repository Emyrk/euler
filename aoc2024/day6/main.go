package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	m := parse("input.txt")
	fmt.Println("Part 1:", run(m))
}

func run(m *Map) int {
	hit := make(map[int]struct{})
	// Always include the start
	hit[spotID(m.Guard.X, m.Guard.Y)] = struct{}{}
	for m.step() {
		hit[spotID(m.Guard.X, m.Guard.Y)] = struct{}{}
	}

	return len(hit)
}

func spotID(x, y int) int {
	return x*10000 + y
}

type Map struct {
	Room  [][]rune
	Guard Person
}

func (m Map) Print() string {
	var str strings.Builder
	for y := 0; y < len(m.Room); y++ {
		for x := 0; x < len(m.Room); x++ {
			if m.Guard.X == x && m.Guard.Y == y {
				str.WriteRune(m.Guard.Direction)
				continue
			}
			str.WriteRune(m.Room[y][x])
		}
		str.WriteRune('\n')
	}
	return str.String()
}

func (m *Map) step() bool {
	ng := m.Guard.Forward()
	if ng.X < 0 || ng.X > len(m.Room[0])-1 {
		return false
	}

	if ng.Y < 0 || ng.Y > len(m.Room)-1 {
		return false
	}

	if m.Room[ng.Y][ng.X] == '#' {
		m.Guard = m.Guard.Rotate()
		return m.step()
	}

	m.Guard = ng
	return true
}

type Person struct {
	X         int
	Y         int
	Direction rune // <, v, >, ^
}

func (p Person) Rotate() Person {
	np := Person{
		X:         p.X,
		Y:         p.Y,
		Direction: p.Direction,
	}
	switch p.Direction {
	case '<':
		np.Direction = '^'
	case '>':
		np.Direction = 'v'
	case '^':
		np.Direction = '>'
	case 'v':
		np.Direction = '<'
	default:
		panic("wtf")
	}
	return np
}

func (p Person) Forward() Person {
	np := Person{
		X:         p.X,
		Y:         p.Y,
		Direction: p.Direction,
	}
	switch p.Direction {
	case '<':
		np.X -= 1
	case '>':
		np.X += 1
	case '^':
		np.Y -= 1
	case 'v':
		np.Y += 1
	default:
		panic("wtf")
	}
	return np
}

func parse(filename string) *Map {
	file, err := os.Open(filename)
	if err != nil {
		panic(err)
	}

	scanner := bufio.NewScanner(file)
	m := Map{
		Room:  make([][]rune, 0),
		Guard: Person{},
	}
	y := 0

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		row := make([]rune, 0, len(line))
		for x, r := range line {
			if r == '<' || r == 'v' || r == '>' || r == '^' {
				m.Guard = Person{
					X:         x,
					Y:         y,
					Direction: r,
				}
				row = append(row, '.')
				continue
			}
			row = append(row, r)
		}
		m.Room = append(m.Room, row)
		y++
	}

	return &m
}
