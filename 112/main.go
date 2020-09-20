package main

import (
	"fmt"
)

func main() {

	bruteForce(-1)
}

func bruteForce(max int) {
	var b float64

	var i int
	for i = 0; max > i || max == -1; i++ {
		if bouncy(i) {
			b++
		}

		p := (b / float64(i))
		if p == 0.99 {
			break
		}
	}

	// 1587000
	fmt.Println(i)
}

func bouncy(v int) bool {
	var inc bool
	var dec bool

	l := v % 10
	v = v / 10
	for v != 0 && !(inc && dec) {
		d := v % 10
		v = v / 10
		if d > l {
			inc = true
		} else if d < l {
			dec = true
		}
		l = d
	}

	return inc && dec
}
