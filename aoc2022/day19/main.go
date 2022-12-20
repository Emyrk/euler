package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type mats [4]int

func (m mats) more(b mats) bool {
	for i := range m {
		if m[i] < b[i] {
			return false
		}
	}
	return true
}

func (m mats) add(b mats) mats {
	cpy := mats{}
	for i := range cpy {
		cpy[i] = m[i] + b[i]
	}
	return cpy
}

func (m mats) sub(b mats) mats {
	cpy := mats{}
	for i := range cpy {
		cpy[i] = m[i] - b[i]
	}
	return cpy
}

type blueprint [4]mats

type state struct {
	bots      mats
	materials mats
}

func (s state) equal(b state) bool {
	return s.bots == b.bots && s.materials == b.materials
}

//var skip int

// excessiveBots returns true if there is more bots than the blueprint can
// even use in 1 minute. If we have say 5 ore bots, and all blueprints need
// at most 5, then 6 ore bots is useless.
func (s state) excessiveBots(i int, print blueprint, remaining int) bool {
	// Geode bots are never useless!
	if i == 3 {
		return true
	}
	needed := 0
	for _, p := range print {
		if p[i] > needed {
			needed = p[i]
		}
	}

	if s.bots[i] >= needed {
		return false
	}

	// Crafting bot [i] will increase the amount of materials[i]. Do we even
	// need more materials?
	if s.materials[i] >= needed*remaining {
		//skip++
		//if skip%1000 == 0 {
		//	fmt.Printf("Skipping %d\n", skip)
		//}
		return false
	}

	return true
}

func (s state) branches(print blueprint, exists map[state]bool, remaining int) []state {
	collect := s.bots
	branches := []state{
		{
			bots:      s.bots,
			materials: s.materials.add(collect),
		},
	}
	for i := range print {
		// newBot[i] costs print[i] and produces newBot[i].
		// we should check if we even need this newBot.
		// If we have more bots producing mat[i] than we need, we can skip this.
		if !s.excessiveBots(i, print, remaining) {
			continue
		}

		newBot := mats{}
		newBot[i] += 1

		// If we have enough materials to make this new bot,
		// add a new state to the branches
		if s.materials.more(print[i]) {
			newState := state{
				bots:      s.bots.add(newBot),
				materials: s.materials.sub(print[i]).add(collect),
			}
			if !exists[newState] {
				branches = append(branches, newState)
				exists[newState] = true
			}
			//fmt.Println("Adding branch", i)
		}
	}

	return branches
}

var exp = regexp.MustCompile(`Blueprint .*:\s+` +
	`Each ore robot costs ([^.]*).\s+` +
	`Each clay robot costs ([^.]*).\s+` +
	`Each obsidian robot costs ([^.]*).\s+` +
	`Each geode robot costs ([^.]*).`)

func main() {
	input := must(os.ReadFile("/home/steven/go/src/github.com/Emyrk/euler/aoc2022/day19/input.txt"))
	lines := strings.Split(string(input), "\n")
	blueprints := make([]blueprint, 0, len(lines))
	for _, line := range lines {
		print := blueprint{}
		strings.Trim(line, " \n\t")
		matches := exp.FindStringSubmatch(line)
		for i, match := range matches[1:] {
			bots := mats{}
			costs := strings.Split(match, "and")
			for i := range costs {
				costs[i] = strings.Trim(costs[i], " \n\t")
				ores := strings.Split(costs[i], " ")
				amt := must(strconv.Atoi(ores[0]))
				switch ores[1] {
				case "ore":
					bots[0] = amt
				case "clay":
					bots[1] = amt
				case "obsidian":
					bots[2] = amt
				case "geode":
					bots[3] = amt
				}
			}
			print[i] = bots
		}
		blueprints = append(blueprints, print)
	}

	start := state{
		bots:      mats{1, 0, 0, 0},
		materials: mats{0, 0, 0, 0},
	}

	minutes := 24
	printScores := make([]int, 0, len(blueprints))
	for i, blueprint := range blueprints {
		duplicate := make(map[state]bool)
		branches := []state{start}
		for minute := 0; minute < minutes; minute++ {
			newBranches := make([]state, 0)
			for _, b := range branches {
				newBranches = append(newBranches, b.branches(blueprint, duplicate, minutes-minute)...)
			}
			branches = newBranches
			fmt.Printf("Minute %d: %d branches\n", minute+1, len(branches))
		}

		bestGeode := state{}
		for _, b := range branches {
			b := b
			if b.materials[3] > bestGeode.materials[3] {
				bestGeode = b
			}
		}
		score := (i + 1) * bestGeode.materials[3]
		fmt.Printf("Best geode score=%d: %v\n", score, bestGeode)
		printScores = append(printScores, score)
	}

	total := 0
	for _, score := range printScores {
		total += score
	}
	fmt.Printf("Total score: %d\n", total)
}

func must[V any](value V, err error) V {
	if err != nil {
		panic(err)
	}
	return value
}
