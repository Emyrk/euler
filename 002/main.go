package main

import "fmt"

func main() {
	// Fibonacci
	fib := []int{1, 2}
	sum := 2
	for {
		next := fib[0] + fib[1]
		fib[0], fib[1] = fib[1], next
		if next%2 == 0 {
			sum += next
		}
		if next > 4e6 {
			break
		}
	}

	fmt.Println(sum)
}
