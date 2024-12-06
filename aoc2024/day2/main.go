package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	// Hastly done on vaction, will not clean up later
	partTwo()
}

func partTwo() {
	input, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	totalSafe := 0
	scanner := bufio.NewScanner(bytes.NewBuffer(input))
	for scanner.Scan() {
		line := scanner.Text()
		line = strings.TrimSpace(line)

		vals := strings.Split(line, " ")
		ivs := toInts(vals)

		before := totalSafe
		for i := 0; i < len(ivs); i++ {
			fmt.Println("checking", ivs, i)
			if ok, _ := safe(ivs, i); ok {
				totalSafe++
				break
			}
		}
		if before == totalSafe {
			fmt.Println("not safe", ivs)
		}
	}
	fmt.Println(totalSafe)
}

func partOne() {
	input, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	totalSafe := 0
	scanner := bufio.NewScanner(bytes.NewBuffer(input))
	for scanner.Scan() {
		line := scanner.Text()
		line = strings.TrimSpace(line)
		vals := strings.Split(line, " ")
		ivs := toInts(vals)

		if ok, _ := safe(ivs, -1); ok {
			totalSafe++
		}
	}
	fmt.Println(totalSafe)
}
func toInts(vals []string) []int {
	ints := make([]int, len(vals))
	for i, val := range vals {
		ints[i] = mustAtoi(val)
	}
	return ints

}

func safe(vals []int, exclude int) (bool, int) {
	cpy := make([]int, 0, len(vals))
	for i, val := range vals {
		if i == exclude {
			continue
		}
		cpy = append(cpy, val)
	}
	vals = cpy
	fmt.Println("safe", vals)

	v1, v2 := vals[0], vals[1]
	inc := v1 < v2
	last := v1

	for i, val := range vals[1:] {
		iv := val

		// at least 1, at most 3
		increased := last < iv
		if inc != increased {
			return false, i + 1
		}

		diff := iv - last
		if !increased {
			diff = -diff
		}
		if diff < 1 || diff > 3 {
			return false, i + 1

		}
		last = iv
	}
	return true, -1
}

func mustAtoi(s string) int {
	v, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return v
}
