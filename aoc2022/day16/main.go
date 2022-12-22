package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Room struct {
	Name     string
	FlowRate int
	tunnels  []string
	Tunnels  []*Room

	Open bool
}

// Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
var room = regexp.MustCompile(
	`Valve ([A-Z][A-Z]) has flow rate=(\d+);\s+` +
		`tunnels? leads? to valves? (.*)`)

func main() {
	fp := "/home/steven/go/src/github.com/Emyrk/euler/aoc2022/day16/easy.txt"
	rooms := parseRooms(fp)
	fmt.Println(rooms)
}

func walk(rooms map[string]*Room, start string, time int) {
	room := rooms[start]

}

type next func() *Room

func options(room *Room, time int) []string {

	if room.FlowRate == 0 {
		return room.tunnels
	}
	return nil
}

func parseRooms(fp string) map[string]*Room {
	data := must(os.ReadFile(fp))
	lines := strings.Split(string(data), "\n")

	rooms := make(map[string]*Room)
	for _, line := range lines {
		room := parseRoom(line)
		rooms[room.Name] = room
	}

	for _, room := range rooms {
		for _, tunnel := range room.tunnels {
			room.Tunnels = append(room.Tunnels, rooms[tunnel])
		}
	}
	rooms["AA"].Open = true
	return rooms
}

func parseRoom(line string) *Room {
	matches := room.FindStringSubmatch(line)
	tunnels := strings.Split(matches[3], ",")
	for i := range tunnels {
		tunnels[i] = strings.TrimSpace(tunnels[i])
	}

	room := &Room{
		Name:     matches[1],
		FlowRate: must(strconv.Atoi(matches[2])),
		tunnels:  tunnels,
		Tunnels:  make([]*Room, 0, len(tunnels)),
	}
	return room
}

func must[V any](value V, err error) V {
	if err != nil {
		panic(err)
	}
	return value
}
