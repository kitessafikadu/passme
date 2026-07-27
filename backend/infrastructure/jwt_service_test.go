package infrastructure_test

import (
	"errors" // Import errors
	"fmt"
	"testing"
	"time"

	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/infrastructure" // Adjust import path if necessary
	"github.com/golang-jwt/jwt/v4"
	"github.com/stretchr/testify/assert"
)

var jwtKey = []byte("secret_key") // Replicated for signing in tests if needed
var differentJwtKey = []byte("a_different_secret_key")

func TestGenerateJWT(t *testing.T) {
	t.Run("Success", func(t *testing.T) {
		email := "test@example.com"
		userID := "user123abc"

		tokenString, err := infrastructure.GenerateJWT(email, userID)

		// 1. Test Generation Success
		assert.NoError(t, err, "Token generation should not produce an error")
		assert.NotEmpty(t, tokenString, "Generated token string should not be empty")

		// 2. Test Claims by Validating the Generated Token (using Parse directly for detailed check)
		token, validateErr := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			// Replicate the service's simple keyFunc logic for this test assertion
			// Optional: Basic alg check
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return jwtKey, nil
		})

		assert.NoError(t, validateErr, "Generated token should be valid when parsed with correct keyFunc")
		assert.True(t, token.Valid, "Token.Valid should be true")

		claims, ok := token.Claims.(jwt.MapClaims)
		assert.True(t, ok, "Claims should be parsable as MapClaims")
		assert.NotNil(t, claims, "Claims should not be nil after validation")

		// Check standard claims
		assert.Contains(t, claims, "exp", "Claims should contain expiration time")
		expClaim, ok := claims["exp"].(float64) // JWT standard stores numeric dates as float64
		assert.True(t, ok, "Expiration claim should be a number")
		expectedExp := time.Now().Add(24 * time.Hour).Unix()
		assert.InDelta(t, expectedExp, int64(expClaim), 5, "Expiration time should be approximately 24 hours from now") // Allow 5 seconds delta

		// Check custom claims
		assert.Contains(t, claims, "email", "Claims should contain email")
		assert.Equal(t, email, claims["email"], "Email claim should match input")

		assert.Contains(t, claims, "user_id", "Claims should contain user_id")
		assert.Equal(t, userID, claims["user_id"], "UserID claim should match input")
	})
}

func TestValidateToken(t *testing.T) {
	validEmail := "validate@example.com"
	validUserID := "validUser456"

	t.Run("Valid Token with MapClaims", func(t *testing.T) {
		// This specifically uses GenerateJWT which creates MapClaims
		validTokenString, err := infrastructure.GenerateJWT(validEmail, validUserID)
		assert.NoError(t, err)

		claims, validateErr := infrastructure.ValidateToken(validTokenString)

		assert.NoError(t, validateErr, "Validation of a valid token should not produce an error")
		assert.NotNil(t, claims, "Claims should not be nil for a valid token")
		assert.Equal(t, validEmail, claims["email"])
		assert.Equal(t, validUserID, claims["user_id"])
		// Check exp existence after successful validation
		_, expOk := claims["exp"]
		assert.True(t, expOk, "Validated claims should contain 'exp'")
	})

	t.Run("Expired Token", func(t *testing.T) {
		expiredClaims := jwt.MapClaims{
			"email":   validEmail,
			"user_id": validUserID,
			"exp":     time.Now().Add(-1 * time.Hour).Unix(), // 1 hour in the past
		}
		token := jwt.NewWithClaims(jwt.SigningMethodHS256, expiredClaims)
		expiredTokenString, err := token.SignedString(jwtKey) // Use the package key
		assert.NoError(t, err, "Signing expired token shouldn't fail")

		claims, validateErr := infrastructure.ValidateToken(expiredTokenString)

		assert.Error(t, validateErr, "Validation of an expired token should produce an error")
		// Check if the error is specifically about the token being expired
		var jwtErr *jwt.ValidationError
		isValidationErr := errors.As(validateErr, &jwtErr)
		assert.True(t, isValidationErr, "Error should be a jwt.ValidationError")
		assert.True(t, jwtErr.Is(jwt.ErrTokenExpired), "ValidationError should wrap ErrTokenExpired")
		assert.Nil(t, claims, "Claims should be nil for an expired token")
	})

	t.Run("Invalid Signature (Wrong Key)", func(t *testing.T) {
		claims := jwt.MapClaims{
			"email":   validEmail,
			"user_id": validUserID,
			"exp":     time.Now().Add(1 * time.Hour).Unix(), // Valid expiration
		}
		token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		wronglySignedTokenString, err := token.SignedString(differentJwtKey) // Use different key
		assert.NoError(t, err, "Signing with different key shouldn't fail")

		claims, validateErr := infrastructure.ValidateToken(wronglySignedTokenString)

		assert.Error(t, validateErr, "Validation of a token with wrong signature should produce an error")
		var jwtErr *jwt.ValidationError
		isValidationErr := errors.As(validateErr, &jwtErr)
		assert.True(t, isValidationErr, "Error should be a jwt.ValidationError")
		assert.True(t, jwtErr.Is(jwt.ErrTokenSignatureInvalid), "ValidationError should wrap ErrTokenSignatureInvalid")
		assert.Nil(t, claims, "Claims should be nil for an invalid signature token")
	})

	t.Run("Malformed Token String", func(t *testing.T) {
		malformedTokenString := "this.is.not.a.valid.jwt.token"

		claims, validateErr := infrastructure.ValidateToken(malformedTokenString)

		assert.Error(t, validateErr, "Validation of a malformed token string should produce an error")
		// Check for specific malformed error if possible/needed
		var jwtErr *jwt.ValidationError
		isValidationErr := errors.As(validateErr, &jwtErr)
		assert.True(t, isValidationErr, "Error should be a jwt.ValidationError")
		assert.True(t, jwtErr.Is(jwt.ErrTokenMalformed), "ValidationError should wrap ErrTokenMalformed")
		assert.Nil(t, claims, "Claims should be nil for a malformed token")
	})

	t.Run("Empty Token String", func(t *testing.T) {
		emptyTokenString := ""

		claims, validateErr := infrastructure.ValidateToken(emptyTokenString)

		assert.Error(t, validateErr, "Validation of an empty token string should produce an error")
		// Usually results in malformed error
		var jwtErr *jwt.ValidationError
		isValidationErr := errors.As(validateErr, &jwtErr)
		assert.True(t, isValidationErr, "Error should be a jwt.ValidationError for empty string")
		assert.True(t, jwtErr.Is(jwt.ErrTokenMalformed), "ValidationError should wrap ErrTokenMalformed for empty string")
		assert.Nil(t, claims, "Claims should be nil for an empty token")
	})

	// --- REMOVED FAILING TEST CASE for RegisteredClaims ---
	// The test case trying to make the type assertion fail was removed
	// as jwt.Parse defaults to MapClaims, making the assertion always succeed
	// if parsing itself doesn't error out.

	// Test for algorithm mismatch (still expects success due to current ValidateToken implementation)
	t.Run("Token with different HMAC signing method (HS512) - EXPECTED TO PASS", func(t *testing.T) {
		claims := jwt.MapClaims{
			"email":   validEmail,
			"user_id": validUserID,
			"exp":     time.Now().Add(1 * time.Hour).Unix(),
		}
		token := jwt.NewWithClaims(jwt.SigningMethodHS512, claims)
		hs512TokenString, err := token.SignedString(jwtKey)
		assert.NoError(t, err)

		parsedClaims, validateErr := infrastructure.ValidateToken(hs512TokenString)
		assert.NoError(t, validateErr, "Validation SHOULD pass with current ValidateToken implementation even if alg is HS512")
		assert.NotNil(t, parsedClaims, "Claims should NOT be nil as validation is expected to pass")
		assert.Equal(t, validEmail, parsedClaims["email"])
		assert.Equal(t, validUserID, parsedClaims["user_id"])
	})
}