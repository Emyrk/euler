package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestBouncy(t *testing.T) {
	assert := assert.New(t)

	assert.True(bouncy(155349))
}
