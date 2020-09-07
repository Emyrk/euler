package main

import (
	"encoding/csv"
	"fmt"
	"io/ioutil"
	"os"
	"sort"
	"strconv"
	"strings"
)

func main() {
	// fast()
	solve([3]byte{101, 120, 112})
}

func solve(p Password) {
	cipher, err := secret("cipher.txt")
	if err != nil {
		panic(err)
	}
	pt := xor(cipher, p[:])
	var sum int
	for _, c := range pt {
		sum += int(c)
	}
	fmt.Println(string(pt))
	// Sum = 107359
	fmt.Println(sum)
}

var words = readDictionary()

func fast() {
	cipher, err := secret("cipher.txt")
	if err != nil {
		panic(err)
	}

	fa := make([][]Freq, 3)
	fa[0] = frequencyAnalysis(cipher, 0)
	fa[1] = frequencyAnalysis(cipher, 1)
	fa[2] = frequencyAnalysis(cipher, 2)

	combos := make([][]byte, 3)
	combos[0] = comboTable(fa[0], 6)
	combos[1] = comboTable(fa[1], 6)
	combos[2] = comboTable(fa[2], 6)

	var total = 0
	l := NewLimitedPassword(combos)
	for {
		p, new := l.Next()
		if !new {
			break
		}
		pt := xor(cipher, p[:])
		// TODO: Was going to use the dictionary, but this method will take too long.
		// Like way too long.
		if strings.Contains(string(pt), " ") &&
			strings.Contains(string(pt), " the ") &&
			strings.Contains(string(pt), " a ") {
			fmt.Println(p, string(pt))
			total++
		}
	}
	fmt.Println(total)
}

// Frequency of letters by most common
var expFreq = []byte{'e', 't', 'a', 'o', 'i', 'n', 's', 'h', 'r', 'd', 'l', 'c', 'u', 'm', 'w', 'f', 'g', 'y', 'p', 'b', 'v', 'k', 'j', 'x', 'q', 'z'}

func hasWords() {

}

func comboTable(freqs []Freq, depth int) []byte {
	possible := make([]byte, depth*depth)
	var c int
	for i := 0; i < depth; i++ {
		for j := 0; j < depth; j++ {
			possible[c] = freqs[i].Char ^ expFreq[j]
			c++
		}
	}
	return possible
}

func freqString(freq []Freq) string {
	var str strings.Builder
	for _, f := range freq {
		str.WriteString(fmt.Sprintf("'%d': %d\n", f.Char, f.Count))
	}
	return str.String()
}

type Freq struct {
	Char  byte
	Count int
}

func frequencyAnalysis(cipher []byte, index int) []Freq {
	freq := make(map[byte]int)
	for i := range cipher {
		if i%3 == index {
			freq[cipher[i]]++
		}
	}

	letters := make([]Freq, len(freq))
	c := 0
	for letter, count := range freq {
		letters[c] = Freq{
			Char:  letter,
			Count: count,
		}
		c++
	}

	sort.Slice(letters, func(i, j int) bool {
		return letters[i].Count > letters[j].Count
	})

	return letters
}

func bruteForce() {
	cipher, err := secret("cipher.txt")
	if err != nil {
		panic(err)
	}

	p := NewPassword()
	for {
		pt := xor(cipher, p[:])
		// TODO: Was going to use the dictionary, but this method will take too long.
		// Like way too long.
		if strings.Contains(string(pt), " ") {
			fmt.Println(string(pt))
		}
	}
}

func xor(input, key []byte) []byte {
	output := make([]byte, len(input))
	for i := range input {
		output[i] = input[i] ^ key[i%len(key)]
	}
	return output
}

func secret(filename string) ([]byte, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	r := csv.NewReader(file)
	chars, err := r.Read()
	// ascii, err :=  ioutil.ReadAll(file)
	if err != nil {
		return nil, err
	}

	data := make([]byte, len(chars))
	for i, c := range chars {
		n, err := strconv.Atoi(c)
		if err != nil {
			return nil, err
		}
		data[i] = byte(n)
	}
	return data, nil
}

func dictListToMap(words []string) map[string]struct{} {
	m := make(map[string]struct{})
	for _, w := range words {
		m[w] = struct{}{}
	}
	return m
}

func readDictionary() (words []string) {
	file, err := os.Open("/usr/share/dict/words")
	if err != nil {
		panic(err)
	}

	bytes, err := ioutil.ReadAll(file)
	if err != nil {
		panic(err)
	}

	words = strings.Split(string(bytes), "\n")
	return
}

type LimitedPassword struct {
	Combos       [][]byte
	CurrentIndex []int
}

func NewLimitedPassword(combos [][]byte) *LimitedPassword {
	l := new(LimitedPassword)
	l.Combos = combos
	l.CurrentIndex = make([]int, len(combos))
	return l
}

// TODO: Only works with 3 char passwords. W/e
func (l *LimitedPassword) Inc() bool {
	l.CurrentIndex[2]++
	if l.CurrentIndex[2] >= len(l.Combos[2]) {
		l.CurrentIndex[1]++
		l.CurrentIndex[2] = 0
		if l.CurrentIndex[1] >= len(l.Combos[1]) {
			l.CurrentIndex[0]++
			l.CurrentIndex[1] = 0
			if l.CurrentIndex[0] >= len(l.Combos[0]) {
				l.CurrentIndex[0] = 0
				return false
			}
		}
	}
	return true
}

func (l *LimitedPassword) Next() (p Password, new bool) {
	new = l.Inc()
	return Password{
		l.Combos[0][l.CurrentIndex[0]],
		l.Combos[1][l.CurrentIndex[1]],
		l.Combos[2][l.CurrentIndex[2]],
	}, new
}

type Password [3]byte

func NewPassword() Password {
	return [3]byte{'a', 'a', 'a'}
}

func (p *Password) Next() Password {
	// 97 -> 122
	// increment the bytes from the right
	p[2]++
	if p[2] > 'z' {
		p[1]++
		p[2] = 'a'
		if p[1] > 'z' {
			p[0]++
			p[1] = 'a'
		}
	}
	return *p
}
