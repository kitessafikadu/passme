package infrastructure_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/infrastructure" // Adjust import path
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
	"github.com/stretchr/testify/assert"
)

// --- Test Setup ---

// Helper function to create a test Gin engine with the middleware and a final handler
func setupTestRouterWithMiddleware(t *testing.T) (*gin.Engine, *bool) {
	gin.SetMode(gin.TestMode)
	router := gin.New() // Use gin.New() to avoid default middleware unless needed

	// Flag to check if the next handler was called
	nextHandlerCalled := false

	// Apply the middleware
	router.Use(infrastructure.AuthMiddleware())

	// Define a test route that should only be reached if middleware passes
	router.GET("/test", func(c *gin.Context) {
		nextHandlerCalled = true // Mark that this handler was reached
		// Optionally check context value here too
		userID, exists := c.Get("user_id")
		assert.True(t, exists, "user_id should exist in context after middleware")
		assert.NotEmpty(t, userID, "user_id should not be empty")
		c.JSON(http.StatusOK, gin.H{"message": "passed", "user_id": userID})
	})

	return router, &nextHandlerCalled
}

// --- Test Cases ---

func TestAuthMiddleware(t *testing.T) {

	// Use the actual jwtKey from the package (or redefine if needed for isolation)
	testJwtKey := []byte("secret_key") // Must match jwt_service.go's key

	// --- Generate Tokens for Testing ---
	validEmail := "auth@example.com"
	validUserID := "authUserID123"
	validToken, err := infrastructure.GenerateJWT(validEmail, validUserID) // Assumes GenerateJWT works
	assert.NoError(t, err, "Setup: Failed to generate valid token")

	// Expired Token
	expiredClaims := jwt.MapClaims{
		"email":   validEmail,
		"user_id": validUserID,
		"exp":     time.Now().Add(-1 * time.Hour).Unix(), // Expired
	}
	expiredTokenRaw := jwt.NewWithClaims(jwt.SigningMethodHS256, expiredClaims)
	expiredToken, err := expiredTokenRaw.SignedString(testJwtKey)
	assert.NoError(t, err, "Setup: Failed to generate expired token")

	// Token signed with wrong key
	wrongKeyTokenRaw := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email":   validEmail,
		"user_id": validUserID,
		"exp":     time.Now().Add(1 * time.Hour).Unix(), // Valid time
	})
	// Assume differentJwtKey is defined like in jwt_service_test.go
	wrongKeyToken, err := wrongKeyTokenRaw.SignedString(differentJwtKey)
	assert.NoError(t, err, "Setup: Failed to generate wrong key token")

	// Token missing user_id claim
	missingClaimTokenRaw := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email": validEmail,
		// "user_id": validUserID, // Missing
		"exp": time.Now().Add(1 * time.Hour).Unix(),
	})
	missingClaimToken, err := missingClaimTokenRaw.SignedString(testJwtKey)
	assert.NoError(t, err, "Setup: Failed to generate missing claim token")

	// Token with non-string user_id claim
	badClaimTokenRaw := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email":   validEmail,
		"user_id": 12345, // Not a string
		"exp":     time.Now().Add(1 * time.Hour).Unix(),
	})
	badClaimToken, err := badClaimTokenRaw.SignedString(testJwtKey)
	assert.NoError(t, err, "Setup: Failed to generate bad claim token")

	// --- Run Tests ---

	t.Run("Success - Valid Token", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", "Bearer "+validToken)

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code, "Should return OK status")
		assert.True(t, *nextCalled, "Next handler should have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "passed", respBody["message"])
		assert.Equal(t, validUserID, respBody["user_id"]) // Check user ID from final handler
	})

	t.Run("Fail - No Authorization Header", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		// No Authorization header set

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "Authorization header missing or malformed", respBody["error"])
	})

	t.Run("Fail - Malformed Header (No Bearer prefix)", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", validToken) // Missing "Bearer " prefix

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "Authorization header missing or malformed", respBody["error"])
	})

	t.Run("Fail - Malformed Header (Bearer only)", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", "Bearer ") // Empty token part

		router.ServeHTTP(w, req)

		// Expect failure because ValidateToken receives an empty string
		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		// This error comes from ValidateToken failing on the empty string
		assert.Equal(t, "Invalid token", respBody["error"])
	})

	t.Run("Fail - Expired Token", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", "Bearer "+expiredToken)

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "Invalid token", respBody["error"])
	})

	t.Run("Fail - Invalid Signature (Wrong Key)", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", "Bearer "+wrongKeyToken)

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "Invalid token", respBody["error"])
	})

	t.Run("Fail - Malformed Token String (during ValidateToken)", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", "Bearer "+"this.is.malformed")

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "Invalid token", respBody["error"])
	})

	t.Run("Fail - Missing user_id Claim", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", "Bearer "+missingClaimToken)

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "Invalid token claims", respBody["error"]) // Specific error for this case
	})

	t.Run("Fail - Non-string user_id Claim", func(t *testing.T) {
		router, nextCalled := setupTestRouterWithMiddleware(t)
		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("Authorization", "Bearer "+badClaimToken)

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code, "Should return Unauthorized status")
		assert.False(t, *nextCalled, "Next handler should NOT have been called")

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "Invalid token claims", respBody["error"]) // Specific error for this case
	})
}