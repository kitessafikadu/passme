package routers_test // Or package routers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	// Adjust import paths as necessary
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/controllers"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/routers"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/domain"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/infrastructure"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.mongodb.org/mongo-driver/bson/primitive" // Assuming user ID is primitive.ObjectID
)

// --- Mock UserUseCase ---
// (This should be similar to the one used in user_controller_test.go)
type MockUserUseCase struct {
	mock.Mock
}

func (m *MockUserUseCase) RegisterUser(user *domain.User) error {
	args := m.Called(user)
	if args.Error(0) == nil && user != nil {
		user.ID = primitive.NewObjectID() // Simulate ID assignment
	}
	return args.Error(0)
}

func (m *MockUserUseCase) LoginUser(email, password string) (*domain.User, error) {
	args := m.Called(email, password)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserUseCase) GetProfile(userID string) (*domain.User, error) {
	args := m.Called(userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserUseCase) UpdateUsername(userID, newUsername string) error {
	args := m.Called(userID, newUsername)
	return args.Error(0)
}

func (m *MockUserUseCase) UpdatePassword(userID, oldPassword, newPassword string) error {
	args := m.Called(userID, oldPassword, newPassword)
	return args.Error(0)
}

// --- Test Function ---

func TestSetupUserRoutes(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// Generate a valid token
	testUserID := primitive.NewObjectID().Hex() // Use hex representation consistent with JWT
	validToken, tokenErr := infrastructure.GenerateJWT("user-router@test.com", testUserID)
	assert.NoError(t, tokenErr, "Setup: failed to generate test token")
	authHeader := "Bearer " + validToken

	// --- Helper to create setup for each test ---
	setupTest := func() (*gin.Engine, *MockUserUseCase) {
		router := gin.New()
		mockUseCase := new(MockUserUseCase)
		// Create REAL controller with MOCK use case
		realController := controllers.NewUserController(mockUseCase)
		// Setup routes with the REAL controller
		routers.SetupUserRoutes(router, realController)
		return router, mockUseCase
	}

	// --- Test Cases ---

	t.Run("POST /register calls use case RegisterUser", func(t *testing.T) {
		router, mockUseCase := setupTest()

		mockUseCase.On("RegisterUser", mock.AnythingOfType("*domain.User")).Return(nil)

		w := httptest.NewRecorder()
		userData := gin.H{
			"username": "regRouterUser",
			"email":    "regRouter@test.com",
			"password": "password123",
		}
		bodyBytes, _ := json.Marshal(userData)
		// No Auth needed for register
		req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(bodyBytes))
		req.Header.Set("Content-Type", "application/json")

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code) // Controller returns 201
		mockUseCase.AssertCalled(t, "RegisterUser", mock.AnythingOfType("*domain.User"))
		mockUseCase.AssertExpectations(t)
	})

	t.Run("POST /login calls use case LoginUser", func(t *testing.T) {
		router, mockUseCase := setupTest()

		loginEmail := "loginRouter@test.com"
		loginPassword := "password123"
		mockUserID := primitive.NewObjectID()

		// LoginUser mock returns a user so the controller can generate JWT
		mockUseCase.On("LoginUser", loginEmail, loginPassword).Return(&domain.User{
			ID:       mockUserID, // Need ID for token generation
			Email:    loginEmail,
			Username: "loginTest",
		}, nil)

		w := httptest.NewRecorder()
		loginData := gin.H{
			"email":    loginEmail,
			"password": loginPassword,
		}
		bodyBytes, _ := json.Marshal(loginData)
		// No Auth needed for login
		req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(bodyBytes))
		req.Header.Set("Content-Type", "application/json")

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockUseCase.AssertCalled(t, "LoginUser", loginEmail, loginPassword)
		mockUseCase.AssertExpectations(t)

		// Check if response contains a token
		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.NotEmpty(t, respBody["token"], "Login response should contain a token")
	})

	t.Run("Profile Routes Middleware Applied - Unauthorized", func(t *testing.T) {
		router, mockUseCase := setupTest()

		// Test multiple protected routes
		testCases := []struct {
			method string
			path   string
		}{
			{http.MethodGet, "/profile/"},
			{http.MethodPut, "/profile/username"},
			{http.MethodPut, "/profile/password"},
		}

		for _, tc := range testCases {
			t.Run(tc.method+" "+tc.path, func(t *testing.T) {
				w := httptest.NewRecorder()
				req, _ := http.NewRequest(tc.method, tc.path, nil) // No Auth header
				router.ServeHTTP(w, req)

				assert.Equal(t, http.StatusUnauthorized, w.Code)
			})
		}

		// Ensure no profile-related use case methods were called
		mockUseCase.AssertNotCalled(t, "GetProfile", mock.Anything)
		mockUseCase.AssertNotCalled(t, "UpdateUsername", mock.Anything, mock.Anything)
		mockUseCase.AssertNotCalled(t, "UpdatePassword", mock.Anything, mock.Anything, mock.Anything)
	})

	t.Run("GET /profile calls use case GetProfile", func(t *testing.T) {
		router, mockUseCase := setupTest()

		// Expect GetProfile call with the userID from the token
		mockUseCase.On("GetProfile", testUserID).Return(&domain.User{
			ID: func() primitive.ObjectID {
				id, _ := primitive.ObjectIDFromHex(testUserID)
				return id
			}(),
			Username: "profileUser",
			Email:    "user-router@test.com",
		}, nil)

		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/profile/", nil)
		req.Header.Set("Authorization", authHeader) // Valid Auth needed

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockUseCase.AssertCalled(t, "GetProfile", testUserID)
		mockUseCase.AssertExpectations(t)
	})

	t.Run("PUT /profile/username calls use case UpdateUsername", func(t *testing.T) {
		router, mockUseCase := setupTest()
		newUsername := "updatedRouterUser"

		// Expect UpdateUsername call with userID from token and new username from body
		mockUseCase.On("UpdateUsername", testUserID, newUsername).Return(nil)

		w := httptest.NewRecorder()
		usernameData := gin.H{"new_username": newUsername}
		bodyBytes, _ := json.Marshal(usernameData)

		req, _ := http.NewRequest(http.MethodPut, "/profile/username", bytes.NewBuffer(bodyBytes))
		req.Header.Set("Authorization", authHeader) // Valid Auth needed
		req.Header.Set("Content-Type", "application/json")

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockUseCase.AssertCalled(t, "UpdateUsername", testUserID, newUsername)
		mockUseCase.AssertExpectations(t)
	})

	t.Run("PUT /profile/password calls use case UpdatePassword", func(t *testing.T) {
		router, mockUseCase := setupTest()
		oldPassword := "oldPass123"
		newPassword := "newPass456"

		// Expect UpdatePassword call with userID from token and passwords from body
		mockUseCase.On("UpdatePassword", testUserID, oldPassword, newPassword).Return(nil)

		w := httptest.NewRecorder()
		passwordData := gin.H{
			"old_password":     oldPassword,
			"new_password":     newPassword,
			"confirm_password": newPassword, // Assuming controller checks this match
		}
		bodyBytes, _ := json.Marshal(passwordData)

		req, _ := http.NewRequest(http.MethodPut, "/profile/password", bytes.NewBuffer(bodyBytes))
		req.Header.Set("Authorization", authHeader) // Valid Auth needed
		req.Header.Set("Content-Type", "application/json")

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockUseCase.AssertCalled(t, "UpdatePassword", testUserID, oldPassword, newPassword)
		mockUseCase.AssertExpectations(t)
	})
}