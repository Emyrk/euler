package main

import (
	"github.com/stretchr/testify/assert"
	"math/rand"
	"testing"
)

func TestXor(t *testing.T) {
	assert := assert.New(t)
	t.Run("test pt -> ci -> pt", func(t *testing.T) {
		for i := 0; i < 1000; i++ {
			plain := make([]byte, rand.Intn(1000)+1)
			key := make([]byte, rand.Intn(20)+1)
			rand.Read(plain)
			rand.Read(key)

			ct := xor(plain, key)
			assert.Equal(plain, xor(ct, key))
		}
	})
}
