package main

import (
	"fmt"
	"testing"
)

func TestBranches(t *testing.T) {
	state := state{
		bots:      mats{0, 0, 0, 0},
		materials: mats{1, 0, 10, 0},
	}

	b := state.branches(blueprint{
		{1, 0, 0, 0},
		{1, 0, 0, 0},
		{1, 0, 0, 0},
		{0, 0, 10, 0},
	})

	for _, branch := range b {
		fmt.Printf("%v\n", branch)
	}
}
