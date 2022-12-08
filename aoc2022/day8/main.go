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

type Grid struct {
	Width        int
	Height       int
	Cells        [][]int
	VisibleTrees [][]int
	ScenicScores [][]int
}

func BuildGrid(rdr io.Reader) *Grid {
	g := &Grid{}
	buf := bufio.NewReader(rdr)
	for {
		row := make([]int, 0, g.Width)
		line, ok := nextLine(buf)
		if !ok {
			break
		}

		chars := strings.Split(line, "")
		g.Width = len(chars)
		for _, c := range chars {
			row = append(row, must(strconv.Atoi(c)))
		}
		g.Cells = append(g.Cells, row)
		g.Height++
	}
	g.VisibleTrees = make([][]int, g.Height)
	g.ScenicScores = make([][]int, g.Height)
	for i := range g.VisibleTrees {
		g.VisibleTrees[i] = make([]int, g.Width)
		g.ScenicScores[i] = make([]int, g.Width)
		// Edges are all visible
		g.VisibleTrees[i][0] = 1
		g.VisibleTrees[i][g.Width-1] = 1
		if i == 0 || i == g.Height-1 {
			for j := range g.VisibleTrees[i] {
				g.VisibleTrees[i][j] = 1
			}
		}
	}
	return g
}

func (g *Grid) CountVisible() int {
	count := 0
	for _, row := range g.VisibleTrees {
		for _, v := range row {
			if v == 1 {
				count++
			}
		}
	}
	return count
}

// CalcScenicScore is done with brute force. Really should use dynamic programming....
func (g *Grid) CalcScenicScore(sx, sy int) int {
	me := g.Cells[sy][sx]
	// Left
	var left int
	for x := sx - 1; x >= 0; x-- {
		left++
		if g.Cells[sy][x] >= me {
			break
		}
	}

	// Right
	var right int
	for x := sx + 1; x < g.Width; x++ {
		right++
		if g.Cells[sy][x] >= me {
			break
		}
	}

	// Up
	var up int
	for y := sy - 1; y >= 0; y-- {
		up++
		if g.Cells[y][sx] >= me {
			break
		}
	}

	// Down
	var down int
	for y := sy + 1; y < g.Height; y++ {
		down++
		if g.Cells[y][sx] >= me {
			break
		}
	}

	g.ScenicScores[sy][sx] = left * right * up * down
	return g.ScenicScores[sy][sx]
}

func (g *Grid) CalcVisibleFromEdge() {
	// First row by row
	for y := 0; y < g.Height; y++ {
		{ // From left
			var rowLowest int = -1
			for x := 0; x < g.Width; x++ {
				v := g.Cells[y][x]
				if v > rowLowest {
					rowLowest = g.Cells[y][x]
					g.VisibleTrees[y][x] = 1
				}
			}
		}

		{ // From right
			var rowLowest int = -1
			for x := g.Width - 1; x >= 0; x-- {
				if g.Cells[y][x] > rowLowest {
					rowLowest = g.Cells[y][x]
					g.VisibleTrees[y][x] = 1
				}
			}
		}
	}

	for x := 0; x < g.Width; x++ {
		{ // Column from top
			var colLowest int = -1
			for y := 0; y < g.Height; y++ {
				if g.Cells[y][x] > colLowest {
					colLowest = g.Cells[y][x]
					g.VisibleTrees[y][x] = 1
				}
			}
		}

		{ // Column from bottom
			var colLowest int = -1
			for y := g.Height - 1; y >= 0; y-- {
				if g.Cells[y][x] > colLowest {
					colLowest = g.Cells[y][x]
					g.VisibleTrees[y][x] = 1
				}
			}
		}
	}
}

func main() {
	file := must(os.OpenFile("/home/steven/go/src/github.com/Emyrk/euler/aoc2022/day8/input.txt", os.O_RDONLY, 0))
	defer file.Close()

	grid := BuildGrid(file)
	grid.CalcVisibleFromEdge()
	fmt.Printf("Part 1: %d\n", grid.CountVisible())

	var best int
	for y := 0; y < grid.Height; y++ {
		for x := 0; x < grid.Width; x++ {
			ss := grid.CalcScenicScore(x, y)
			if ss > best {
				best = ss
			}
		}
	}
	fmt.Printf("Part 2: %d\n", best)
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
