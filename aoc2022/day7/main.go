package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

type File struct {
	Name string
	Size int64
}

type Directory struct {
	Parent      *Directory
	Directories map[string]*Directory
	Files       map[string]File
	Name        string

	size int64
}

func (d *Directory) Size() int64 {
	if d.size != 0 {
		return d.size
	}

	var size int64
	for _, f := range d.Files {
		size += f.Size
	}
	for _, dir := range d.Directories {
		size += dir.Size()
	}

	// Cache it
	d.size = size
	return size
}

func (d *Directory) AllDirs() []*Directory {
	dirs := make([]*Directory, 0, len(d.Directories))
	for _, dir := range d.Directories {
		dirs = append(dirs, dir.AllDirs()...)
	}
	return append(dirs, d)
}

type Tree struct {
	Root *Directory
}

func BuildTree(file io.Reader) *Tree {
	root := &Tree{Root: &Directory{
		Parent:      nil,
		Directories: make(map[string]*Directory),
		Files:       make(map[string]File),
		Name:        "/",
	}}
	pointer := root.Root

	rd := bufio.NewReader(file)
	line, ok := nextLine(rd)
	if !ok {
		return root
	}

OuterLoop:
	for {
		split := strings.Split(line, " ")
		if split[0] != "$" {
			panic(fmt.Sprintf("expected $, got %q", split[0]))
		}

		// A command
		switch split[1] {
		case "cd":
			// Change directory
			dir := split[2]
			switch dir {
			case "..":
				pointer = pointer.Parent
			case "/":
				pointer = root.Root
			default:
				pointer = pointer.Directories[dir]
			}
			line, ok = nextLine(rd)
			if !ok {
				break OuterLoop
			}
		case "ls":
		ListLoop:
			for {
				line, ok = nextLine(rd)
				if !ok {
					break OuterLoop
				}
				split := strings.Split(line, " ")
				switch split[0] {
				case "$":
					line = line
					break ListLoop
				case "dir":
					pointer.Directories[split[1]] = &Directory{
						Parent:      pointer,
						Name:        split[1],
						Directories: make(map[string]*Directory),
						Files:       make(map[string]File),
					}
				default:
					size := must(strconv.ParseInt(split[0], 10, 64))
					pointer.Files[split[1]] = File{
						Name: split[1],
						Size: size,
					}
				}
			}
		}
	}

	return root
}

func main() {
	file := must(os.OpenFile("/home/steven/go/src/github.com/Emyrk/euler/aoc2022/day7/input.txt", os.O_RDONLY, 0))
	defer file.Close()

	tree := BuildTree(file)
	fmt.Printf("Part 1: %d\n", partOne(tree))
	fmt.Printf("Part 2: %d\n", partTwo(tree))
}

func partOne(t *Tree) int64 {
	dirs := t.Root.AllDirs()
	var total int64
	for _, d := range dirs {
		if d.Size() < 100000 {
			total += d.Size()
		}
	}
	return total
}

func partTwo(t *Tree) int64 {
	dirs := t.Root.AllDirs()
	unused := 70000000 - t.Root.Size()
	need := 30000000 - unused
	var lowest *Directory

	for _, d := range dirs {
		if d.Size() > need {
			if lowest == nil || d.Size() < lowest.Size() {
				lowest = d
			}
		}
	}
	return lowest.Size()
}

func must[V any](value V, err error) V {
	if err != nil {
		panic(err)
	}
	return value
}

func nextLine(rd *bufio.Reader) (string, bool) {
	line, _, err := rd.ReadLine()
	if errors.Is(err, io.EOF) {
		return "", false
	}
	if err != nil {
		panic(err)
	}
	return string(line), true
}
