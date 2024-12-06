package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	m := parse("simple.txt")
	fmt.Println("Part 1:", partOne(m.copy()))
	// The best solution would be some kind of backtracking solution. But I'm lazy
	fmt.Println("Part 2:", partTwoBruteForce(m.copy())) // 2143
}

func partTwo(m *Map) int {
	loopCheck := make(map[string]struct{})
	loopCheck[uid(m.Guard)] = struct{}{}
	obstacles := make(map[int]struct{})

	return recurse(m, loopCheck, obstacles)
}

// This is broken, plane is landing. Whelp
func recurse(m *Map, loopCheck map[string]struct{}, obstacles map[int]struct{}) int {
	var start *Map

	last := m.step()
	if !last {
		// Guard exited the room
		return 0
	}
	for {
		start = m.copy()
		loopCheck[uid(m.Guard)] = struct{}{}
		if _, ok := obstacles[spotID(m.Guard.X, m.Guard.Y)]; !ok {
			break
		}
		if !m.step() {
			return 0
		}
	}

	myLoopCheck := map[string]struct{}{}
	for k := range loopCheck {
		myLoopCheck[k] = struct{}{}
	}
	prev := start.copy()
	prev.Obstacle = []int{
		m.Guard.X,
		m.Guard.Y,
	}

	obstacles[spotID(m.Guard.X, m.Guard.Y)] = struct{}{}
	for m.step() {
		if _, ok := myLoopCheck[uid(m.Guard)]; ok {
			// Loop detected. Add it plus backtrack
			return 1 + recurse(start, loopCheck, obstacles)
		}
		myLoopCheck[uid(m.Guard)] = struct{}{}
	}

	return recurse(start, loopCheck, obstacles)
}

// This is super slow and brute forces it, takes about a minute.
// Did this on a plane, don't feel like improving it.
// A much better idea would be to use a backtracking solution.
// 0. Save previous state
// 1. Take 1 step with the guard
// 2. Try placing an obstacle where the guard is
// 3. Continue stepping, detect a loop.
// 4. If the guard exits, backtrack to when the obstacle was placed.
// 5. Step forward, place a new obstacle and try again
// 6. Save which locations we tried to prevent trying something twice.
func partTwoBruteForce(m *Map) int {
	total := 0
	for y := 0; y < len(m.Room); y++ {
		fmt.Printf("row %d/%d done\n", y, len(m.Room))
		for x := 0; x < len(m.Room[0]); x++ {
			if m.Room[y][x] != '.' {
				continue
			}

			nm := m.copy()
			nm.Room[y][x] = '#'
			if loops(nm) {
				total++
			}
		}
	}
	return total
}

func loops(m *Map) bool {
	already := make(map[string]struct{})
	already[uid(m.Guard)] = struct{}{}
	for m.step() {
		if _, ok := already[uid(m.Guard)]; ok {
			return true
		}
		already[uid(m.Guard)] = struct{}{}
	}
	return false
}

func partOne(m *Map) int {
	hit := make(map[int]struct{})
	// Always include the start
	hit[spotID(m.Guard.X, m.Guard.Y)] = struct{}{}
	for m.step() {
		hit[spotID(m.Guard.X, m.Guard.Y)] = struct{}{}
	}

	return len(hit)
}

func uid(p Person) string {
	return fmt.Sprintf("%s(%d, %d)", string(p.Direction), p.X, p.Y)
}

func spotID(x, y int) int {
	return x*10000 + y
}

type Map struct {
	Room     [][]rune
	Guard    Person
	Obstacle []int
}

func (m Map) copy() *Map {
	m2 := Map{
		Room: make([][]rune, 0, len(m.Room)),
		Guard: Person{
			X:         m.Guard.X,
			Y:         m.Guard.Y,
			Direction: m.Guard.Direction,
		},
	}
	for i := range m.Room {
		m2.Room = append(m2.Room, append([]rune{}, m.Room[i]...))
	}
	return &m2
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

	if len(m.Obstacle) == 2 && ng.X == m.Obstacle[0] && ng.Y == m.Obstacle[1] {
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
