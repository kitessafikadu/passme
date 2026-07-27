package infrastructure_test

import (
	"testing"

	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/infrastructure" // Adjust import path if necessary
	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/bcrypt"
)

func TestHashPassword(t *testing.T) {
	password := "mysecretpassword"

	t.Run("Success", func(t *testing.T) {
		hash, err := infrastructure.HashPassword(password)

		// 1. Check for errors during hashing
		assert.NoError(t, err, "Hashing should not produce an error for valid input")

		// 2. Check if hash is generated (not empty)
		assert.NotEmpty(t, hash, "Generated hash should not be empty")

		// 3. Check if hash is different from the original password
		assert.NotEqual(t, password, hash, "Hash should be different from the original password")

		// 4. Optional: Check if the generated hash is a valid bcrypt hash
		// This verifies the cost factor and format implicitly
		cost, err := bcrypt.Cost([]byte(hash))
		assert.NoError(t, err, "Generated hash should be parseable by bcrypt")
		// Your code uses cost 14
		assert.Equal(t, 14, cost, "Bcrypt cost factor should match the one used in HashPassword")
	})

	t.Run("Empty Password", func(t *testing.T) {
		// Hashing an empty password should still work
		emptyPassword := ""
		hash, err := infrastructure.HashPassword(emptyPassword)

		assert.NoError(t, err, "Hashing an empty password should not produce an error")
		assert.NotEmpty(t, hash, "Hash of empty password should not be empty")
		assert.NotEqual(t, emptyPassword, hash, "Hash should be different from the empty password")
	})

	// Note: It's hard to force bcrypt.GenerateFromPassword to error with standard usage
	// unless there's a system issue or an extremely high cost factor (which isn't the case here).
	// Testing the error return path is less critical for this specific function under normal conditions.
}

func TestCheckPasswordHash(t *testing.T) {
	password := "checkThisPassword123"
	// Generate a hash for the password *once* for the tests
	hash, err := infrastructure.HashPassword(password)
	assert.NoError(t, err, "Setup: Failed to hash password for checking tests")
	assert.NotEmpty(t, hash)

	t.Run("Correct Password", func(t *testing.T) {
		match := infrastructure.CheckPasswordHash(password, hash)
		assert.True(t, match, "Correct password should match its generated hash")
	})

	t.Run("Incorrect Password", func(t *testing.T) {
		wrongPassword := "wrongPasswordXYZ"
		match := infrastructure.CheckPasswordHash(wrongPassword, hash)
		assert.False(t, match, "Incorrect password should not match the hash")
	})

	t.Run("Empty Password Check against Valid Hash", func(t *testing.T) {
		emptyPassword := ""
		match := infrastructure.CheckPasswordHash(emptyPassword, hash) // Hash is for "checkThisPassword123"
		assert.False(t, match, "Empty password should not match a hash for a non-empty password")
	})

	t.Run("Valid Password Check against Empty Hash", func(t *testing.T) {
		emptyHash := ""
		// bcrypt.CompareHashAndPassword will error on an empty/invalid hash string
		match := infrastructure.CheckPasswordHash(password, emptyHash)
		assert.False(t, match, "Valid password should not match an empty hash string (comparison should fail)")
	})

	t.Run("Valid Password Check against Invalid Hash Format", func(t *testing.T) {
		invalidHash := "this-is-not-bcrypt"
		// bcrypt.CompareHashAndPassword will error on an invalid hash string
		match := infrastructure.CheckPasswordHash(password, invalidHash)
		assert.False(t, match, "Valid password should not match an invalid hash string (comparison should fail)")
	})

	t.Run("Empty Password Check against Empty Hash", func(t *testing.T) {
		emptyPassword := ""
		emptyHash := ""
		// bcrypt.CompareHashAndPassword will error on an empty/invalid hash string
		match := infrastructure.CheckPasswordHash(emptyPassword, emptyHash)
		assert.False(t, match, "Empty password should not match an empty hash string (comparison should fail)")
	})
}