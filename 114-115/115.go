package main

import (
	"fmt"
)

func main() {
	n := 50
	for m := n; ; m++ {
		initMem(m, n)
		v := TotalCombinations(m, n)
		if v > 1e6 {
			fmt.Println(m)
			return
		}
	}
}
