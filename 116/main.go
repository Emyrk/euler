package main

import (
	"fmt"
)

// memoize combination values. Once we caluclator F(m,n)
// we can store the answer in a lookup table
var mem map[int]map[int]int = make(map[int]map[int]int)

func initMem(m, n int) {
	for i := 0; i <= m; i++ {
		mem[i] = make(map[int]int)
		for j := 0; j <= m; j++ {
			mem[i][j] = -1
		}
	}
}

func main() {
	bases := []int{2, 3, 4}
	m := 50
	var sum int
	for i := 0; i < len(bases); i++ {
		n := bases[i]
		initMem(m, n)
		sum += TotalCombinations(m, n)
	}

	// 20492570929
	fmt.Println(sum)
}

func TotalCombinations(m, n int) int {
	for i := 0; i <= m; i++ {
		mem[i] = make(map[int]int)
		for j := 0; j <= m; j++ {
			mem[i][j] = -1
		}
	}

	// We start the sum at 1 as the 0 set counts too
	var sum int = 0
	for i := n; i <= m; i += n {
		a := BlockCombinations(m, i, n)
		sum += a
	}
	return sum
}

// on is the original n, and on <= n
func BlockCombinations(m, n, on int) int {
	if m < n {
		return 0
	}
	v, ok := mem[m][n]
	if !ok {
		panic(fmt.Sprintf("%d %d", m, n))
	}
	if v != -1 {
		return v
	}

	var extra int
	// (m-n)+1 possible locations we can place our set of n
	// We iterate through each place we can place a single set
	// of size n, and find out if we can place other sets of
	// blocks from size on -> n.
	for i := 0; i < (m-n)+1; i++ {
		// i == first index of the first square
		// i + n == last square + grey reserved

		// We only need to check for possible combinations on the right.
		// All combinations on the left will be handled by another pass of different
		// size n's.
		// tl;dr: Only check additional possible combinations using the right
		//		remaining squares available.

		// last includes grey reserved
		last := i + n
		right := m - last - 1

		// For each set of blocks we have free on right, find all possible
		// number of combinations we can place blocks starting at size 'on'.
		for rightN := on; rightN <= right; rightN += on {
			extra += BlockCombinations(right, rightN, on)
		}
	}

	// (m - n) + 1 is the number of locations of just 1 set 'n'.
	// extra = number of additional combinations we can make to the right
	// of each possible value in the '(m - n) + 1'
	ans := (m - n) + 1 + extra
	mem[m][n] = ans
	return ans
}
