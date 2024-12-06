package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"strings"
)

func main() {
	input, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	grid := loadGrid(input)
	count := bruteForce(grid)
	fmt.Println(count)
}

func bruteForce(grid [][]rune) int {
	found := 0
	for i := range grid {
		for j := range grid[i] {
			found += partTwo(grid, i, j)
		}
	}
	return found
}

func partTwo(grid [][]rune, i, j int) int {
	letter := grid[i][j]
	if letter != 'A' {
		// Only find from A
		return 0
	}

	// A on the edge
	if i < 1 || j < 1 || i > len(grid)-2 || j > len(grid)-2 {
		return 0
	}

	tl := grid[i-1][j-1]
	br := grid[i+1][j+1]

	if !((tl == 'M' && br == 'S') || (tl == 'S' && br == 'M')) {
		return 0
	}

	bl := grid[i-1][j+1]
	tr := grid[i+1][j-1]
	if !((bl == 'M' && tr == 'S') || (bl == 'S' && tr == 'M')) {
		return 0
	}

	return 1
}

func partOne(grid [][]rune, i, j int) int {
	letter := grid[i][j]
	if letter != 'X' {
		// Only find from X
		return 0
	}

	found := 0

	want := []rune{'M', 'A', 'S'}
	deltaI := []int{-1, 0, 1}
	deltaJ := []int{-1, 0, 1}
	for _, di := range deltaI {
		for _, dj := range deltaJ {
			found += search(grid, want, i, j, func(i, j int) (int, int) {
				return i + di, j + dj
			})
		}
	}

	return found
}

func search(grid [][]rune, want []rune, i, j int, next func(i, j int) (int, int)) int {
	ci, cj := i, j

	for _, w := range want {
		ci, cj = next(ci, cj)
		if ci < 0 || cj < 0 || ci > len(grid)-1 || cj > len(grid)-1 {
			return 0
		}
		if grid[ci][cj] != w {
			return 0
		}
	}
	return 1
}

func loadGrid(data []byte) [][]rune {
	scanner := bufio.NewScanner(bytes.NewBuffer(data))
	grid := make([][]rune, 0)
	for scanner.Scan() {
		row := make([]rune, 0)
		line := strings.TrimSpace(scanner.Text())
		for _, r := range line {
			row = append(row, r)
		}
		grid = append(grid, row)
	}
	return grid
}
