package controllers_test

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/controllers"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/domain"
)

// MockFlightUseCase for testing
type MockFlightUseCase struct {
	mock.Mock
}

func (m *MockFlightUseCase) AddFlight(flight *domain.Flight) error {
	args := m.Called(flight)
	return args.Error(0)
}

func (m *MockFlightUseCase) FetchFlightByID(id string) (*domain.Flight, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.Flight), args.Error(1)
}

// --- FIX 2: Modify Mock Implementation ---
func (m *MockFlightUseCase) FetchFlightsByUserID(userID string) ([]domain.Flight, error) {
	args := m.Called(userID)
	// Check if the first argument (the slice) is nil before asserting type
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.Flight), args.Error(1)
}
// --- End FIX 2 ---

func (m *MockFlightUseCase) DeleteFlight(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

// Helper for dummy QA data
func getDummyQAData() []domain.QA {
	return []domain.QA{
		{Question: "q1", Answer: "a1"},
		{Question: "q2", Answer: "a2"},
		{Question: "q3", Answer: "a3"},
		{Question: "q4", Answer: "a4"},
		{Question: "q5", Answer: "a5"},
	}
}



func TestFlightController_CreateFlight(t *testing.T) {
	gin.SetMode(gin.TestMode) // Set Gin to test mode

	t.Run("success", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()

		router.POST("/flights", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.CreateFlight(c)
		})

		expectedFlight := &domain.Flight{
			Title:       "Flight to Paris",
			FromCountry: "USA",
			ToCountry:   "France",
			Language:    "English",
			// QA will be populated by binding, but the input needs 5
			UserID:      "user123",
		}
		// --- FIX 1: Provide 5 QA pairs in mock expectation if needed for matching, though AddFlight likely modifies it ---
		// Let's refine the expectation to match any flight with the correct user ID and allow QA to vary slightly due to binding
		mockUC.On("AddFlight", mock.MatchedBy(func(f *domain.Flight) bool {
				return f.Title == expectedFlight.Title &&
					f.FromCountry == expectedFlight.FromCountry &&
					f.ToCountry == expectedFlight.ToCountry &&
					f.Language == expectedFlight.Language &&
					f.UserID == expectedFlight.UserID && // Check UserID is set
					len(f.QA) == 5 && // Ensure QA length is correct after binding
					!f.Date.IsZero() // Ensure date is set
		})).Return(nil)


		// --- FIX 1: Provide 5 QA pairs in request ---
		flightJSON, _ := json.Marshal(map[string]interface{}{
			"title":        "Flight to Paris",
			"from_country": "USA",
			"to_country":   "France",
			"language":     "English",
			"qa":           getDummyQAData(), // Use helper
		})
		req, _ := http.NewRequest(http.MethodPost, "/flights", bytes.NewBuffer(flightJSON))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "Flight created successfully", responseBody["message"])
		// Optionally assert parts of the returned flight data
		flightData := responseBody["flight"].(map[string]interface{})
		assert.Equal(t, "Flight to Paris", flightData["title"])
		assert.Equal(t, "user123", flightData["user_id"])
		assert.Len(t, flightData["qa"], 5)

		mockUC.AssertExpectations(t)
	})

	t.Run("missing required fields", func(t *testing.T) {
		// This test is okay as it should fail before QA check
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.POST("/flights", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.CreateFlight(c)
		})

		flightJSON, _ := json.Marshal(map[string]interface{}{
			"from_country": "USA",
			"to_country":   "France",
			"language":     "English",
			"qa":           getDummyQAData(), // Provide valid QA here to ensure the OTHER field is the cause
		})
		req, _ := http.NewRequest(http.MethodPost, "/flights", bytes.NewBuffer(flightJSON))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "Missing required flight fields", responseBody["error"])
		mockUC.AssertNotCalled(t, "AddFlight", mock.Anything)
	})

	t.Run("invalid JSON", func(t *testing.T) {
		// This test is okay as it fails during binding
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.POST("/flights", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.CreateFlight(c)
		})

		req, _ := http.NewRequest(http.MethodPost, "/flights", bytes.NewBuffer([]byte("invalid json")))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Contains(t, responseBody["error"], "invalid character")
		mockUC.AssertNotCalled(t, "AddFlight", mock.Anything)
	})

	t.Run("use case error", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()

		router.POST("/flights", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.CreateFlight(c)
		})

		// Expect AddFlight to be called, *then* return an error
		mockUC.On("AddFlight", mock.AnythingOfType("*domain.Flight")).Return(errors.New("internal server error"))

		// --- FIX 1: Provide 5 QA pairs in request ---
		flightJSON, _ := json.Marshal(map[string]interface{}{
			"title":        "Flight to Paris",
			"from_country": "USA",
			"to_country":   "France",
			"language":     "English",
			"qa":           getDummyQAData(), // Use helper
		})
		req, _ := http.NewRequest(http.MethodPost, "/flights", bytes.NewBuffer(flightJSON))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		// Now we expect 500 because validation passes, but use case fails
		assert.Equal(t, http.StatusInternalServerError, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "internal server error", responseBody["error"])
		mockUC.AssertExpectations(t) // Verify AddFlight was called
	})

	t.Run("missing user_id", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()

		// Route without the middleware setting user_id
		router.POST("/flights", flightController.CreateFlight)

		// --- FIX 1: Provide 5 QA pairs in request ---
		// Make sure the request *would* be valid if authenticated
		flightJSON, _ := json.Marshal(map[string]interface{}{
			"title":        "Flight to Paris",
			"from_country": "USA",
			"to_country":   "France",
			"language":     "English",
			"qa":           getDummyQAData(), // Use helper
		})
		req, _ := http.NewRequest(http.MethodPost, "/flights", bytes.NewBuffer(flightJSON))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		// Now we expect 401 because validation passes, but auth fails
		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "User not authenticated", responseBody["error"])
		mockUC.AssertNotCalled(t, "AddFlight", mock.Anything)
	})

	t.Run("incorrect number of QA pairs", func(t *testing.T) {
		// This test case is already correctly testing the QA validation
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.POST("/flights", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.CreateFlight(c)
		})

		flightJSON, _ := json.Marshal(map[string]interface{}{
			"title":        "Flight to Paris",
			"from_country": "USA",
			"to_country":   "France",
			"language":     "English",
			"qa": []interface{}{ // Intentionally wrong number
				map[string]string{"question": "q1", "answer": "a1"},
				map[string]string{"question": "q2", "answer": "a2"},
			},
		})
		req, _ := http.NewRequest(http.MethodPost, "/flights", bytes.NewBuffer(flightJSON))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "Exactly 5 question-answer pairs are required", responseBody["error"])
		mockUC.AssertNotCalled(t, "AddFlight", mock.Anything)
	})
}

// --- No changes needed below this line for the described failures ---
// --- But the FIX 2 in the mock definition above is crucial ---

func TestFlightController_GetFlightByID(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("success", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.GET("/flights/:id", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.GetFlightByID(c)
		})

		expectedFlight := &domain.Flight{
			ID:          "flight123",
			Title:       "Flight to Paris",
			FromCountry: "USA",
			ToCountry:   "France",
			Date:        time.Now(),
			UserID:      "user123",
			Language:    "English",
			QA:          getDummyQAData(), // Use helper for consistency
		}
		mockUC.On("FetchFlightByID", "flight123").Return(expectedFlight, nil)

		req, _ := http.NewRequest(http.MethodGet, "/flights/flight123", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, expectedFlight.ID, responseBody["id"])
		assert.Equal(t, expectedFlight.Title, responseBody["title"])
		assert.Equal(t, expectedFlight.FromCountry, responseBody["from_country"])
		assert.Equal(t, expectedFlight.ToCountry, responseBody["to_country"])
		assert.Equal(t, expectedFlight.UserID, responseBody["user_id"])
		assert.Equal(t, expectedFlight.Language, responseBody["language"])
		assert.Len(t, responseBody["qa"], 5) // Check QA in response
		mockUC.AssertExpectations(t)
	})

	t.Run("flight not found", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.GET("/flights/:id", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.GetFlightByID(c)
		})

		mockUC.On("FetchFlightByID", "flight404").Return(nil, errors.New("flight not found"))

		req, _ := http.NewRequest(http.MethodGet, "/flights/flight404", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "Flight not found", responseBody["error"])
		mockUC.AssertExpectations(t)
	})

	t.Run("user not authenticated", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.GET("/flights/:id", flightController.GetFlightByID)

		req, _ := http.NewRequest(http.MethodGet, "/flights/flight123", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "User not authenticated", responseBody["error"])
		mockUC.AssertNotCalled(t, "FetchFlightByID", mock.Anything)
	})

	t.Run("forbidden - flight belongs to another user", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.GET("/flights/:id", func(c *gin.Context) {
			c.Set("user_id", "user123") // Authenticated user
			flightController.GetFlightByID(c)
		})

		flight := &domain.Flight{ID: "flight123", UserID: "user456"} // Belongs to different user
		mockUC.On("FetchFlightByID", "flight123").Return(flight, nil)

		req, _ := http.NewRequest(http.MethodGet, "/flights/flight123", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusForbidden, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "You don't have permission to access this flight", responseBody["error"])
		mockUC.AssertExpectations(t)
	})
}

func TestFlightController_GetUserFlights(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("success", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		// Use Recovery middleware to catch potential panics during debugging,
		// though the fix to the mock should prevent the previous panic.
		router := gin.New()
		router.Use(gin.Recovery())
		router.GET("/flights", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.GetUserFlights(c)
		})

		expectedFlights := []domain.Flight{
			{ID: "flight1", Title: "Flight 1", FromCountry: "USA", ToCountry: "France", Date: time.Now(), UserID: "user123", Language: "English", QA: getDummyQAData()},
			{ID: "flight2", Title: "Flight 2", FromCountry: "UK", ToCountry: "Germany", Date: time.Now(), UserID: "user123", Language: "German", QA: getDummyQAData()},
		}
		mockUC.On("FetchFlightsByUserID", "user123").Return(expectedFlights, nil)

		req, _ := http.NewRequest(http.MethodGet, "/flights", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var responseBody []map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.NoError(t, err, "Failed to unmarshal response body") // Add check for unmarshal error
		if err == nil { // Proceed only if unmarshal succeeded
			assert.Len(t, responseBody, 2)
			if len(responseBody) > 0 {
				assert.Equal(t, "flight1", responseBody[0]["id"])
				assert.Equal(t, "Flight 1", responseBody[0]["title"])
				assert.Len(t, responseBody[0]["qa"], 5) // Check QA length
			}
			if len(responseBody) > 1 {
				assert.Equal(t, "flight2", responseBody[1]["id"])
				assert.Equal(t, "German", responseBody[1]["language"])
				assert.Len(t, responseBody[1]["qa"], 5) // Check QA length
			}
		}
		mockUC.AssertExpectations(t)
	})

	t.Run("use case error", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		// Use Recovery middleware
		router := gin.New()
		router.Use(gin.Recovery())
		router.GET("/flights", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.GetUserFlights(c)
		})

		// Mock returns nil slice and an error
		mockUC.On("FetchFlightsByUserID", "user123").Return(nil, errors.New("internal server error"))

		req, _ := http.NewRequest(http.MethodGet, "/flights", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		var responseBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.NoError(t, err, "Failed to unmarshal error response body")
		if err == nil {
			assert.Equal(t, "internal server error", responseBody["error"])
		}
		mockUC.AssertExpectations(t)
	})

	t.Run("user not authenticated", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default() // Or gin.New() + gin.Recovery()
		router.GET("/flights", flightController.GetUserFlights)

		req, _ := http.NewRequest(http.MethodGet, "/flights", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "User not authenticated", responseBody["error"])
		mockUC.AssertNotCalled(t, "FetchFlightsByUserID", mock.Anything)
	})
}

func TestFlightController_DeleteFlight(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("success", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.DELETE("/flights/:id", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.DeleteFlight(c)
		})

		flightID := "flight123"
		userID := "user123"
		flight := &domain.Flight{ID: flightID, UserID: userID}
		mockUC.On("FetchFlightByID", flightID).Return(flight, nil)
		mockUC.On("DeleteFlight", flightID).Return(nil)

		req, _ := http.NewRequest(http.MethodDelete, "/flights/"+flightID, nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "Flight deleted successfully", responseBody["message"])
		mockUC.AssertExpectations(t)
	})

	t.Run("flight not found", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.DELETE("/flights/:id", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.DeleteFlight(c)
		})

		flightID := "flight404"
		mockUC.On("FetchFlightByID", flightID).Return(nil, errors.New("flight not found"))

		req, _ := http.NewRequest(http.MethodDelete, "/flights/"+flightID, nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "Flight not found", responseBody["error"])
		mockUC.AssertExpectations(t) // FetchFlightByID was called
		mockUC.AssertNotCalled(t, "DeleteFlight", mock.Anything) // Delete should not be called if not found
	})

	t.Run("user not authenticated", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.DELETE("/flights/:id", flightController.DeleteFlight)

		req, _ := http.NewRequest(http.MethodDelete, "/flights/flight123", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "User not authenticated", responseBody["error"])
		mockUC.AssertNotCalled(t, "FetchFlightByID", mock.Anything)
		mockUC.AssertNotCalled(t, "DeleteFlight", mock.Anything)
	})

	t.Run("forbidden - delete flight of another user", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.DELETE("/flights/:id", func(c *gin.Context) {
			c.Set("user_id", "user123") // Authenticated user
			flightController.DeleteFlight(c)
		})

		flightID := "flight123"
		flight := &domain.Flight{ID: flightID, UserID: "user456"} // Different owner
		mockUC.On("FetchFlightByID", flightID).Return(flight, nil)

		req, _ := http.NewRequest(http.MethodDelete, "/flights/"+flightID, nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusForbidden, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "You don't have permission to delete this flight", responseBody["error"])
		mockUC.AssertExpectations(t) // FetchFlightByID was called
		mockUC.AssertNotCalled(t, "DeleteFlight", mock.Anything) // Delete should not be called if forbidden
	})

	t.Run("delete flight use case error", func(t *testing.T) {
		mockUC := new(MockFlightUseCase)
		flightController := controllers.NewFlightController(mockUC)
		router := gin.Default()
		router.DELETE("/flights/:id", func(c *gin.Context) {
			c.Set("user_id", "user123")
			flightController.DeleteFlight(c)
		})

		flightID := "flight123"
		userID := "user123"
		flight := &domain.Flight{ID: flightID, UserID: userID}
		mockUC.On("FetchFlightByID", flightID).Return(flight, nil)
		// Mock the DeleteFlight call to return an error
		mockUC.On("DeleteFlight", flightID).Return(errors.New("delete error"))

		req, _ := http.NewRequest(http.MethodDelete, "/flights/"+flightID, nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		var responseBody map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.Equal(t, "delete error", responseBody["error"])
		mockUC.AssertExpectations(t) // Both FetchFlightByID and DeleteFlight should have been called
	})
}