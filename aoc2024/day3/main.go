package main

import (
	"fmt"
	"os"
	"regexp"
	"sort"
	"strconv"
)

func main() {
	partTwo()
}

type index struct {
	offset  int
	index   int
	mulSum  int
	do      bool
	enabled bool
}

func partTwo() {
	input, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	// mul(1,5)
	re, err := regexp.Compile(`mul\((\d+)+,(\d+)+\)`)
	if err != nil {
		panic(err)
	}

	reDo, err := regexp.Compile(`do(n't)?\(\)`)
	if err != nil {
		panic(err)
	}

	submatches := re.FindAllStringSubmatch(string(input), -1)
	doStrings := reDo.FindAllStringSubmatch(string(input), -1)
	mulIndexs := re.FindAllIndex(input, -1)
	doIndexs := reDo.FindAllIndex(input, -1)

	allIndexs := []index{}
	for i, mulIndex := range mulIndexs {
		allIndexs = append(allIndexs, index{
			offset: mulIndex[0],
			index:  i,
			mulSum: mustAtoi(submatches[i][1]) * mustAtoi(submatches[i][2]),
		})
	}

	for i, doIndex := range doIndexs {
		allIndexs = append(allIndexs, index{
			offset:  doIndex[0],
			index:   i,
			do:      true,
			enabled: doStrings[i][0] == "do()",
		})
	}

	sort.Slice(allIndexs, func(i, j int) bool {
		return allIndexs[i].offset < allIndexs[j].offset
	})

	total := 0
	enabled := true
	for _, idx := range allIndexs {
		if idx.do {
			enabled = idx.enabled
			continue
		}

		if enabled {
			total += idx.mulSum
		}
	}
	fmt.Println(total)
}

func partOne() {
	input, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	// mul(1,5)
	re, err := regexp.Compile(`mul\((\d+)+,(\d+)+\)`)
	if err != nil {
		panic(err)
	}

	submatches := re.FindAllStringSubmatch(string(input), -1)

	total := 0
	for _, submatch := range submatches {
		total += mustAtoi(submatch[1]) * mustAtoi(submatch[2])
	}
	fmt.Println(total)
}

func mustAtoi(s string) int {
	v, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return v
}
