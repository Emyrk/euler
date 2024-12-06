package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	parsed := parse("input.txt")
	fmt.Println("Part One:", partOne(parsed))
	fmt.Println("Part Two:", partTwo(parsed))

}

func partTwo(parsed Parsed) int {
	sum := 0
	for i := range parsed.Updates {
		u := parsed.Updates[i]

		if !updateOk(parsed, u) {
			// Fix the order, then add sum
			ng := parsed.Nodes.trim(u)
			//ng.Print()
			fixed := ng.topologicalSort()
			if !updateOk(parsed, fixed) {
				panic(fmt.Sprintf("%v is not ok", fixed))
			}

			sum += fixed[len(u)/2]
		}
	}
	return sum
}

func partOne(parsed Parsed) int {
	sum := 0
	for _, u := range parsed.Updates {
		if updateOk(parsed, u) {
			sum += u[len(u)/2]
		}
	}
	return sum
}

func updateOk(parsed Parsed, update []int) bool {
	notAllowed := make(map[int]struct{}, 0)
	for _, v := range update {
		if _, ok := notAllowed[v]; ok {
			return false
		}
		for na := range parsed.NotAllowedAfter[v] {
			notAllowed[na] = struct{}{}
		}
	}
	return true
}

type Parsed struct {
	Rules   [][2]int
	Updates [][]int

	NotAllowedAfter map[int]map[int]struct{}
	Nodes           Graph
}

type Graph map[int]*Node

func (g Graph) copy() Graph {
	cpy := make(map[int]*Node)
	gn := func(v int) *Node {
		if n, ok := cpy[v]; ok {
			return n
		}
		cpy[v] = &Node{
			Value:  v,
			Parent: make(map[int]*Node),
			Next:   make(map[int]*Node),
		}
		return cpy[v]
	}

	for k, v := range g {
		cpy[k] = &Node{
			Value:  v.Value,
			Parent: make(map[int]*Node),
			Next:   make(map[int]*Node),
		}

		for _, p := range v.Parent {
			cpy[k].Parent[p.Value] = gn(p.Value)
		}
		for _, c := range v.Next {
			cpy[k].Next[c.Value] = gn(c.Value)
		}
	}

	return cpy
}

func (g Graph) Print() {
	var str strings.Builder
	have := make(map[int]string)
	for k, node := range g {
		have[k] += "r"
		for _, p := range node.Parent {
			str.WriteString(fmt.Sprintf("%d -> %d\n", p.Value, node.Value))
			have[p.Value] += "p"
		}
		for _, c := range node.Next {
			//str.WriteString(fmt.Sprintf("%d -> %d\n", node.Value, c.Value))
			have[c.Value] += "c"
		}
	}
	fmt.Println(have)
	fmt.Println(str.String())
}

func (g Graph) trim(keep []int) Graph {
	cpy := g.copy()

	keepMap := make(map[int]struct{})
	for _, v := range keep {
		keepMap[v] = struct{}{}
	}

	for _, node := range cpy {
		if _, ok := keepMap[node.Value]; ok {
			continue
		}
		// Delete the node
		delete(cpy, node.Value)
	}

	// Remove the node from all next/parents
	for _, n := range cpy {
		for _, p := range n.Parent {
			if _, ok := keepMap[p.Value]; !ok {
				delete(n.Parent, p.Value)
			}
		}
		for _, next := range n.Next {
			if _, ok := keepMap[next.Value]; !ok {
				delete(n.Next, next.Value)
			}
		}
	}
	return cpy
}

type topSort struct {
	list    []int
	visited map[int]rune
	graph   Graph
}

func (t *topSort) visit(n int) {
	v, _ := t.visited[n]
	if v == 'p' {
		return
	}
	if v == 't' {
		panic("cycle")
	}
	t.visited[n] = 't'

	for _, next := range t.graph[n].Next {
		t.visit(next.Value)
	}
	t.visited[n] = 'p'
	t.list = append([]int{n}, t.list...)
}

func (p Graph) topologicalSort() []int {
	marked := topSort{
		visited: make(map[int]rune),
		graph:   p,
		list:    make([]int, 0),
	}
	for _, n := range p {
		if marked.visited[n.Value] != 'p' {
			marked.visit(n.Value)
		}
	}

	return marked.list
}

func (p Parsed) notLess(a, b int) bool {
	return !p.less(a, b)
}

func (p Parsed) less(a, b int) bool {
	if naa, ok := p.NotAllowedAfter[a]; ok {
		if _, notAfter := naa[b]; notAfter {
			// b not allowed after, so a is "greater"
			return false
		}
	}

	if nab, ok := p.NotAllowedAfter[b]; ok {
		if _, notAfter := nab[a]; notAfter {
			// a not allowed after, so b is "greater"
			return true
		}
	}

	// Does this matter?
	return false
}

func parse(filename string) Parsed {
	f, err := os.Open(filename)
	if err != nil {
		panic(err)
	}

	parsed := Parsed{
		Rules:           make([][2]int, 0),
		Updates:         make([][]int, 0),
		NotAllowedAfter: make(map[int]map[int]struct{}),
		Nodes:           make(map[int]*Node, 0),
	}

	getNode := func(v int) *Node {
		if node, ok := parsed.Nodes[v]; ok {
			return node
		}

		node := &Node{
			Value:  v,
			Next:   make(map[int]*Node),
			Parent: make(map[int]*Node),
		}
		parsed.Nodes[v] = node
		return node
	}

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if parts := strings.Split(line, "|"); len(parts) == 2 {
			first := must(strconv.Atoi(parts[0]))
			second := must(strconv.Atoi(parts[1]))
			parsed.Rules = append(parsed.Rules, [2]int{
				first, second,
			})

			if _, ok := parsed.NotAllowedAfter[second]; !ok {
				parsed.NotAllowedAfter[second] = make(map[int]struct{})
			}
			parsed.NotAllowedAfter[second][first] = struct{}{}

			// graph
			firstNode := getNode(first)
			firstNode.Next[second] = getNode(second)

			secondNode := getNode(second)
			firstNode.Parent[second] = secondNode
			continue
		}

		if line == "" {
			continue
		}

		update := []int{}
		parts := strings.Split(line, ",")
		for _, p := range parts {
			update = append(update, must(strconv.Atoi(p)))
		}
		parsed.Updates = append(parsed.Updates, update)
	}
	return parsed
}

type Node struct {
	Value int

	// Must come after these
	Parent map[int]*Node
	// Must come before these
	Next map[int]*Node
}

func must[V any](value V, err error) V {
	if err != nil {
		panic(err)
	}
	return value
}
