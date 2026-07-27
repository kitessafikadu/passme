package controllers_test

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.mongodb.org/mongo-driver/bson/primitive" // Assuming user ID is primitive.ObjectID

	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/controllers"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/domain"       // Assuming usecases is in this path
)

// MockUserUseCase for testing
type MockUserUseCase struct {
	mock.Mock
}

func (m *MockUserUseCase) RegisterUser(user *domain.User) error {
	args := m.Called(user)
	// Simulate setting the user ID upon successful registration
	if args.Error(0) == nil {
		user.ID = primitive.NewObjectID() // Give it a dummy ID
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

// --- Test Functions ---

func TestUserController_Register(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("success", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/register", userController.Register)

		userInput := domain.User{
			Username: "testuser",
			Email:    "test@example.com",
			Password: "password123",
		}

		// Expect RegisterUser to be called and succeed
		// Simulate the use case assigning an ID
		mockUC.On("RegisterUser", mock.MatchedBy(func(u *domain.User) bool {
			return u.Username == userInput.Username && u.Email == userInput.Email
		})).Run(func(args mock.Arguments) {
			userArg := args.Get(0).(*domain.User)
			userArg.ID = primitive.NewObjectID() // Assign dummy ID in mock run
		}).Return(nil)

		// Prepare request
		body, _ := json.Marshal(userInput)
		req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		// Perform request
		router.ServeHTTP(w, req)

		// Assertions
		assert.Equal(t, http.StatusCreated, w.Code)
		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, "User registered successfully", respBody["message"])

		userData, ok := respBody["user"].(map[string]interface{})
		assert.True(t, ok)
		assert.Equal(t, userInput.Username, userData["username"])
		assert.Equal(t, userInput.Email, userData["email"])
		assert.NotEmpty(t, userData["id"]) // Check that an ID was assigned

		mockUC.AssertExpectations(t)
	})

	t.Run("invalid json", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/register", userController.Register)

		req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer([]byte("{invalid")))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var respBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &respBody)
		// Gin's binding error for invalid JSON
		assert.Contains(t, respBody["error"], "invalid character")
		mockUC.AssertNotCalled(t, "RegisterUser", mock.Anything)
	})

	t.Run("missing username", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/register", userController.Register)

		// Send JSON missing the username field
		userInput := map[string]string{
			// "username": "testuser", // Intentionally Missing
			"email":    "test@example.com",
			"password": "password123",
		}
		body, _ := json.Marshal(userInput)
		req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		// Assertions - Expecting Gin's binding validation error
		assert.Equal(t, http.StatusBadRequest, w.Code)
		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)

		// Check for Gin's binding error message format
		errorMsg, ok := respBody["error"].(string)
		assert.True(t, ok, "Error response should be a string")
		assert.Contains(t, errorMsg, "User.Username", "Error message should mention the field 'User.Username'")
		assert.Contains(t, errorMsg, "required", "Error message should mention validation type 'required'")

		// Ensure the use case method was not called because binding failed first
		mockUC.AssertNotCalled(t, "RegisterUser", mock.Anything)
	})

	t.Run("missing email", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/register", userController.Register)

		// Send JSON missing the email field
		userInput := map[string]string{
			"username": "testuser",
			// "email":    "test@example.com", // Intentionally Missing
			"password": "password123",
		}
		body, _ := json.Marshal(userInput)
		req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		// Assertions - Expecting Gin's binding validation error
		assert.Equal(t, http.StatusBadRequest, w.Code)
		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		errorMsg, ok := respBody["error"].(string)
		assert.True(t, ok)
		// Assuming User struct has `binding:"required"` on Email
		assert.Contains(t, errorMsg, "User.Email")
		assert.Contains(t, errorMsg, "required")
		mockUC.AssertNotCalled(t, "RegisterUser", mock.Anything)
	})

	t.Run("missing password", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/register", userController.Register)

		// Send JSON missing the password field
		userInput := map[string]string{
			"username": "testuser",
			"email":    "test@example.com",
			// "password": "password123", // Intentionally Missing
		}
		body, _ := json.Marshal(userInput)
		req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		// Assertions - Expecting Gin's binding validation error
		assert.Equal(t, http.StatusBadRequest, w.Code)
		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		errorMsg, ok := respBody["error"].(string)
		assert.True(t, ok)
		// Assuming User struct has `binding:"required"` on Password
		assert.Contains(t, errorMsg, "User.Password")
		assert.Contains(t, errorMsg, "required")
		mockUC.AssertNotCalled(t, "RegisterUser", mock.Anything)
	})

	t.Run("registration error from use case", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/register", userController.Register)

		// This user data is valid according to binding
		userInput := domain.User{
			Username: "testuser",
			Email:    "test@example.com",
			Password: "password123",
		}
		expectedError := "email already exists"
		// Mock the use case to return an error *after* binding succeeds
		mockUC.On("RegisterUser", mock.AnythingOfType("*domain.User")).Return(errors.New(expectedError))

		body, _ := json.Marshal(userInput)
		req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		// Assertions - Expecting the error from the use case
		assert.Equal(t, http.StatusBadRequest, w.Code) // Or InternalServerError if appropriate
		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Equal(t, expectedError, respBody["error"])

		// Verify the use case method *was* called
		mockUC.AssertExpectations(t)
	})
}

func TestUserController_Login(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// --- Setup infrastructure mock/stub if needed, otherwise call real GenerateJWT ---
	// For this test, we'll call the real GenerateJWT. If it had complex dependencies,
	// you'd ideally inject and mock a JWTGenerator interface.
	// infrastructure.JWTSecret = []byte("test-secret-key") // Ensure a secret is set for testing if needed by GenerateJWT

	t.Run("success", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/login", userController.Login)

		loginCreds := map[string]string{
			"email":    "test@example.com",
			"password": "password123",
		}
		returnedUser := &domain.User{
			ID:       primitive.NewObjectID(),
			Username: "testuser",
			Email:    loginCreds["email"],
			// Password hash would normally be here in a real scenario
		}

		// Expect LoginUser to succeed
		mockUC.On("LoginUser", loginCreds["email"], loginCreds["password"]).Return(returnedUser, nil)

		// Prepare request
		body, _ := json.Marshal(loginCreds)
		req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		// Perform request
		router.ServeHTTP(w, req)

		// Assertions
		assert.Equal(t, http.StatusOK, w.Code)
		var respBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.Equal(t, "Login successful", respBody["message"])
		assert.NotEmpty(t, respBody["token"], "Token should not be empty")
		userData := respBody["user"].(map[string]interface{})
		assert.Equal(t, returnedUser.Username, userData["username"])
		assert.Equal(t, returnedUser.Email, userData["email"])
		// Note: Comparing ObjectID hex strings might be more robust if needed
		// assert.Equal(t, returnedUser.ID.Hex(), userData["id"])

		mockUC.AssertExpectations(t)

		// Optional: Decode token and verify claims if necessary (more involved)
		// claims, err := infrastructure.ValidateJWT(respBody["token"].(string))
		// assert.NoError(t, err)
		// assert.Equal(t, returnedUser.ID.Hex(), claims.UserID)
		// assert.Equal(t, returnedUser.Email, claims.Email)
	})

	t.Run("invalid json", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/login", userController.Login)

		req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer([]byte("{invalid")))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		mockUC.AssertNotCalled(t, "LoginUser", mock.Anything, mock.Anything)
	})

	t.Run("missing email", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/login", userController.Login)

		loginCreds := map[string]string{
			"password": "password123", // Email missing
		}
		body, _ := json.Marshal(loginCreds)
		req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var respBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &respBody)
		// Note: Gin's default binding error might be different, adjust if needed
		assert.Contains(t, respBody["error"], "Email")
		mockUC.AssertNotCalled(t, "LoginUser", mock.Anything, mock.Anything)
	})

    // Add test for missing password

	t.Run("login failure from use case", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.POST("/login", userController.Login)

		loginCreds := map[string]string{
			"email":    "test@example.com",
			"password": "wrongpassword",
		}
		expectedError := "invalid credentials"
		mockUC.On("LoginUser", loginCreds["email"], loginCreds["password"]).Return(nil, errors.New(expectedError))

		body, _ := json.Marshal(loginCreds)
		req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var respBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.Equal(t, expectedError, respBody["error"])
		mockUC.AssertExpectations(t)
	})

	// Optional: Test JWT generation failure (harder without mocking JWT)
	// t.Run("token generation failure", ...)
}

func TestUserController_GetProfile(t *testing.T) {
	gin.SetMode(gin.TestMode)
	testUserID := primitive.NewObjectID().Hex() // Consistent User ID for tests

	t.Run("success", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		// Simulate authentication middleware setting user_id
		router.GET("/profile", func(c *gin.Context) {
			c.Set("user_id", testUserID) // Set the user ID in context
			userController.GetProfile(c)
		})

		expectedUser := &domain.User{
			ID: func() primitive.ObjectID {
				id, err := primitive.ObjectIDFromHex(testUserID)
				if err != nil {
					t.Fatalf("invalid ObjectID: %v", err)
				}
				return id
			}(),
			Username: "profileuser",
			Email:    "profile@example.com",
		}
		mockUC.On("GetProfile", testUserID).Return(expectedUser, nil)

		req, _ := http.NewRequest(http.MethodGet, "/profile", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var respBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.Equal(t, expectedUser.Username, respBody["username"])
		assert.Equal(t, expectedUser.Email, respBody["email"])
		assert.NotEmpty(t, respBody["about"]) // Check the hardcoded about message
		mockUC.AssertExpectations(t)
	})

	t.Run("use case error", func(t *testing.T) {
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		router.GET("/profile", func(c *gin.Context) {
			c.Set("user_id", testUserID)
			userController.GetProfile(c)
		})

		expectedError := "database error"
		mockUC.On("GetProfile", testUserID).Return(nil, errors.New(expectedError))

		req, _ := http.NewRequest(http.MethodGet, "/profile", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		var respBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.Equal(t, "failed to fetch profile", respBody["error"]) // Check controller's specific error message
		mockUC.AssertExpectations(t)
	})

	t.Run("missing user_id in context", func(t *testing.T) {
		// This test assumes auth middleware would prevent access.
		// Here, we test the controller's behavior if middleware FAILS to set user_id.
		// The controller calls GetString which returns "" if key not found.
		mockUC := new(MockUserUseCase)
		userController := controllers.NewUserController(mockUC)
		router := gin.Default()
		// No middleware setting user_id
		router.GET("/profile", userController.GetProfile)

        // We expect GetProfile to be called with an empty string user ID
		expectedError := "user not found with empty ID" // Example error
		mockUC.On("GetProfile", "").Return(nil, errors.New(expectedError))

		req, _ := http.NewRequest(http.MethodGet, "/profile", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

        // Since the use case returns an error, the controller returns 500
		assert.Equal(t, http.StatusInternalServerError, w.Code)
        var respBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.Equal(t, "failed to fetch profile", respBody["error"])
		mockUC.AssertExpectations(t) // Verify GetProfile("") was called
	})
}


func TestUserController_ChangeUsername(t *testing.T) {
    gin.SetMode(gin.TestMode)
    testUserID := primitive.NewObjectID().Hex()

    t.Run("success", func(t *testing.T) {
        mockUC := new(MockUserUseCase)
        userController := controllers.NewUserController(mockUC)
        router := gin.Default()
        router.PATCH("/profile/username", func(c *gin.Context) {
            c.Set("user_id", testUserID)
            userController.ChangeUsername(c)
        })

        newUsername := "newTestUsername"
        payload := map[string]string{"new_username": newUsername}
        mockUC.On("UpdateUsername", testUserID, newUsername).Return(nil)

        body, _ := json.Marshal(payload)
        req, _ := http.NewRequest(http.MethodPatch, "/profile/username", bytes.NewBuffer(body))
        req.Header.Set("Content-Type", "application/json")
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)

        assert.Equal(t, http.StatusOK, w.Code)
        var respBody map[string]interface{}
        json.Unmarshal(w.Body.Bytes(), &respBody)
        assert.Equal(t, "Username updated successfully", respBody["message"])
        mockUC.AssertExpectations(t)
    })

	t.Run("invalid json", func(t *testing.T) {
        mockUC := new(MockUserUseCase)
        userController := controllers.NewUserController(mockUC)
        router := gin.Default()
        router.PATCH("/profile/username", func(c *gin.Context) {
            c.Set("user_id", testUserID)
            userController.ChangeUsername(c)
        })

        req, _ := http.NewRequest(http.MethodPatch, "/profile/username", bytes.NewBuffer([]byte("invalid")))
        req.Header.Set("Content-Type", "application/json")
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		mockUC.AssertNotCalled(t, "UpdateUsername", mock.Anything, mock.Anything)
	})

    t.Run("use case error", func(t *testing.T) {
        mockUC := new(MockUserUseCase)
        userController := controllers.NewUserController(mockUC)
        router := gin.Default()
        router.PATCH("/profile/username", func(c *gin.Context) {
            c.Set("user_id", testUserID)
            userController.ChangeUsername(c)
        })

        newUsername := "takenUsername"
        payload := map[string]string{"new_username": newUsername}
        expectedError := "username already taken"
        mockUC.On("UpdateUsername", testUserID, newUsername).Return(errors.New(expectedError))

        body, _ := json.Marshal(payload)
        req, _ := http.NewRequest(http.MethodPatch, "/profile/username", bytes.NewBuffer(body))
        req.Header.Set("Content-Type", "application/json")
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)

        assert.Equal(t, http.StatusBadRequest, w.Code) // Or appropriate error code
        var respBody map[string]interface{}
        json.Unmarshal(w.Body.Bytes(), &respBody)
        assert.Equal(t, expectedError, respBody["error"])
        mockUC.AssertExpectations(t)
    })

    // Add test for missing user_id context similar to GetProfile
}

func TestUserController_ChangePassword(t *testing.T) {
    gin.SetMode(gin.TestMode)
    testUserID := primitive.NewObjectID().Hex()

    t.Run("success", func(t *testing.T) {
        mockUC := new(MockUserUseCase)
        userController := controllers.NewUserController(mockUC)
        router := gin.Default()
        router.PATCH("/profile/password", func(c *gin.Context) {
            c.Set("user_id", testUserID)
            userController.ChangePassword(c)
        })

        oldPass := "oldPassword123"
        newPass := "newStrongPassword456"
        payload := map[string]string{
            "old_password":     oldPass,
            "new_password":     newPass,
            "confirm_password": newPass,
        }
        mockUC.On("UpdatePassword", testUserID, oldPass, newPass).Return(nil)

        body, _ := json.Marshal(payload)
        req, _ := http.NewRequest(http.MethodPatch, "/profile/password", bytes.NewBuffer(body))
        req.Header.Set("Content-Type", "application/json")
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)

        assert.Equal(t, http.StatusOK, w.Code)
        var respBody map[string]interface{}
        json.Unmarshal(w.Body.Bytes(), &respBody)
        assert.Equal(t, "Password updated successfully", respBody["message"])
        mockUC.AssertExpectations(t)
    })

	t.Run("invalid json", func(t *testing.T) {
        mockUC := new(MockUserUseCase)
        userController := controllers.NewUserController(mockUC)
        router := gin.Default()
        router.PATCH("/profile/password", func(c *gin.Context) {
            c.Set("user_id", testUserID)
            userController.ChangePassword(c)
        })

        req, _ := http.NewRequest(http.MethodPatch, "/profile/password", bytes.NewBuffer([]byte("invalid")))
        req.Header.Set("Content-Type", "application/json")
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		mockUC.AssertNotCalled(t, "UpdatePassword", mock.Anything, mock.Anything, mock.Anything)
	})

    t.Run("password mismatch", func(t *testing.T) {
        mockUC := new(MockUserUseCase)
        userController := controllers.NewUserController(mockUC)
        router := gin.Default()
        router.PATCH("/profile/password", func(c *gin.Context) {
            c.Set("user_id", testUserID)
            userController.ChangePassword(c)
        })

        payload := map[string]string{
            "old_password":     "oldPassword123",
            "new_password":     "newPass1",
            "confirm_password": "newPass2", // Mismatch
        }

        body, _ := json.Marshal(payload)
        req, _ := http.NewRequest(http.MethodPatch, "/profile/password", bytes.NewBuffer(body))
        req.Header.Set("Content-Type", "application/json")
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)

        assert.Equal(t, http.StatusBadRequest, w.Code)
        var respBody map[string]interface{}
        json.Unmarshal(w.Body.Bytes(), &respBody)
        assert.Equal(t, "new password and confirm password do not match", respBody["error"])
        mockUC.AssertNotCalled(t, "UpdatePassword", mock.Anything, mock.Anything, mock.Anything)
    })

    t.Run("use case error", func(t *testing.T) {
        mockUC := new(MockUserUseCase)
        userController := controllers.NewUserController(mockUC)
        router := gin.Default()
        router.PATCH("/profile/password", func(c *gin.Context) {
            c.Set("user_id", testUserID)
            userController.ChangePassword(c)
        })

        oldPass := "wrongOldPassword"
        newPass := "newStrongPassword456"
        payload := map[string]string{
            "old_password":     oldPass,
            "new_password":     newPass,
            "confirm_password": newPass,
        }
        expectedError := "incorrect old password"
        mockUC.On("UpdatePassword", testUserID, oldPass, newPass).Return(errors.New(expectedError))

        body, _ := json.Marshal(payload)
        req, _ := http.NewRequest(http.MethodPatch, "/profile/password", bytes.NewBuffer(body))
        req.Header.Set("Content-Type", "application/json")
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)

        assert.Equal(t, http.StatusBadRequest, w.Code) // Or appropriate error code
        var respBody map[string]interface{}
        json.Unmarshal(w.Body.Bytes(), &respBody)
        assert.Equal(t, expectedError, respBody["error"])
        mockUC.AssertExpectations(t)
    })

    // Add test for missing user_id context similar to GetProfile
}