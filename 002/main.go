package main

import "fmt"

func main() {
	// 2 ways to do it, iterativly or recusively.
	// Goal was to minimize lines
	fmt.Println(iterative())
	fmt.Println(rec(1, 2, 2))
}

func iterative() int {
	fib, sum := []int{1, 2}, 2
	for fib[1] < 4e6 {
		fib[0], fib[1] = fib[1], fib[0]+fib[1]
		if fib[1]%2 == 0 {
			sum += fib[1]
		}
	}
	return sum
}

func rec(one, two, sum int) int {
	if one > 4e6 {
		return sum
	}
	three := one + two
	if three%2 == 0 {
		sum += three
	}
	return rec(two, three, sum)
}
