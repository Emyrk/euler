package main

import (
	"fmt"
	"time"
)

// Ok this is kinda cheating using the go date library lol
func main() {
	// How many Sundays fell on the first of the month during the twentieth century (1 Jan 1901 to 31 Dec 2000)?
	var total int
	for y := 1901; y <= 2000; y++ {
		for m := time.January; m <= time.December; m++ {
			d := time.Date(y, m, 1, 0, 0, 0, 0, time.UTC)
			if d.Weekday() == time.Sunday {
				total++
			}
		}
	}

	fmt.Println(total)
}
