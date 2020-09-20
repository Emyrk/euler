package main

import (
	"fmt"
)

func main() {

	bruteForce(-1)
}

//
// func guess(million int) int64 {
// 	switch million {
// 	case 1:
// 		return 987048
// 	}
// }

func bruteForce(max int) {
	var b float64
	var bs int

	var i int
	for i = 0; max > i || max == -1; i++ {
		if bouncy(i) {
			b++
			bs++
		}

		// p := (b / float64(i))
		if i%100000000 == 0 {
			// if bs != 100000 {
			fmt.Println(i, b, bs)
			// }
			bs = 0
		}
	}

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
