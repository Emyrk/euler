package main

import (
	"bufio"
	"os"
	"strconv"
	"strings"
)

func main() {
	grid := GetGrid()
	WorstBruteForce(grid)
}

func WorstBruteForce(grid [][]int) {
	grid = expandGrid(grid)
	//largestProduct := 0
	for i := 3; i < len(grid)-3; i++ {
		for i := 3; i < len(grid[i])-3; i++ {

		}
	}
}

func expandGrid(grid [][]int) [][]int {
	// Add 3 cols and 3 rows to all sides
	rowLength := len(grid[0])
	blankRow := make([]int, rowLength+6)
	for i := range grid {
		grid[i] = append([]int{1, 1, 1}, grid[i]...)
		grid[i] = append(grid[i], []int{1, 1, 1}...)
	}

	grid = append([][]int{blankRow, blankRow, blankRow}, grid...)
	grid = append(grid, [][]int{blankRow, blankRow, blankRow}...)
	return grid
}

func ComputeLargestProduct(grid [][]int, i, j int) {
	// Check products vertically
	for i := range grid {

	}
}

func GetGrid() [][]int {
	file, err := os.OpenFile("grid.txt", os.O_RDONLY, 0777)
	if err != nil {
		panic(err)
	}

	rows := make([][]int, 0)
	reader := bufio.NewReader(file)
	for {
		line, _, err := reader.ReadLine()
		if err != nil {
			break
		}
		row := strings.Split(string(line), " ")
		row_int := make([]int, len(row))
		for i := range row {
			row_int[i], _ = strconv.Atoi(row[i])
		}
		rows = append(rows, row_int)
	}

	return rows
}
