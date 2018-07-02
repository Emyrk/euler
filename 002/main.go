package main

import "fmt"

func main() {
	fib, sum := []int{1, 2}, 2
	for fib[1] < 4e6 {
		fib[0], fib[1] = fib[1], fib[0]+fib[1]
		if fib[1]%2 == 0 {
			sum += fib[1]
		}
	}
	fmt.Println(sum)
}
