package main

import (
	"fmt"
	"math"
)

//
// # A) 9 4 sided (1-4); min = 9, max = 36
// # vs
// # B) 6 6 sided (1-6): min = 6, max = 24
//
// # ? = Prob A > B
// # P(A>B) + P(B<A) + P(B=A) = 1
//
// # Possible permutation of A is: 4^9 = 262144
// # Possible perumations of B is: 6^6 = 46656
//
//
// # One way to do it is build a table of all permutations
// #    A1  A2 ...
// # B1 =   >
// # B2 <   =
// # ...

func main() {
	aAmt, aHigh := 1, 2
	bAmt, bHigh := 1, 2

	aAmt, aHigh = 9, 4
	bAmt, bHigh = 6, 6

	a := Rolls(aAmt, aHigh)
	b := Rolls(bAmt, bHigh)

	aMax, bMax := aAmt*aHigh, bAmt*bHigh
	max := aMax
	if bMax > aMax {
		max = aMax
	}

	var sum int
	for i := 1; i <= max; i++ {
		for j := i + 1; j <= max; j++ {
			aM, bM := b[i], a[j]
			sum += aM * bM
		}
	}

	aExp := int(math.Pow(float64(aHigh), float64(aAmt)))
	bExp := int(math.Pow(float64(bHigh), float64(bAmt)))
	fmt.Printf("Exp    : %d\n", aExp*bExp)
	fmt.Printf("%.7f\n", float64(sum)/float64(aExp*bExp))
}

func Rolls(amt, high int) map[int]int {
	var perms map[int]int
	for i := 1; i <= amt; i++ {
		perms = rolls(high, perms)
	}

	exp := int(math.Pow(float64(high), float64(amt)))
	f := total(perms)
	if f != exp {
		fmt.Printf("Found %d, exp %d\n", f, exp)
	}

	return perms
}

func total(perms map[int]int) int {
	var sum int
	for _, amt := range perms {
		sum += amt
	}
	return sum
}

func rolls(high int, rest map[int]int) map[int]int {
	new := make(map[int]int)
	for i := 1; i <= high; i++ {
		if rest == nil {
			new[i] += 1
		}
		for existing, amt := range rest {
			var _ = amt
			new[existing+i] += amt + 1 - 1
		}
	}
	return new
}
