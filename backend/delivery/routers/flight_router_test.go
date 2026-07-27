package routers_test

import (
	"bytes" // Import bytes for POST body if needed later
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	// Adjust import paths as necessary
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/controllers"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/routers"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/domain"       // Import domain
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/infrastructure" // Import infrastructure

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// --- Mock FlightUseCase ---
// (This should be similar to the one used in flight_controller_test.go)
type MockFlightUseCase struct {
	mock.Mock
}

func (m *MockFlightUseCase) AddFlight(flight *domain.Flight) error {
	args := m.Called(flight)
	// Simulate setting ID if successful, like in controller test
	if args.Error(0) == nil && flight != nil {
		flight.ID = "mockFlightID" // Assign a dummy ID
	}
	return args.Error(0)
}

func (m *MockFlightUseCase) FetchFlightByID(id string) (*domain.Flight, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.Flight), args.Error(1)
}

func (m *MockFlightUseCase) FetchFlightsByUserID(userID string) ([]domain.Flight, error) {
	args := m.Called(userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	// Handle potential nil slice before assertion
	if flights, ok := args.Get(0).([]domain.Flight); ok {
		return flights, args.Error(1)
	}
	// Return nil slice if the mock was set up to return nil for the slice
	return nil, args.Error(1)
}


func (m *MockFlightUseCase) DeleteFlight(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

// --- Test Function ---

func TestSetupFlightRoutes(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// Generate a valid token
	testUserID := "routerTestUser123"
	validToken, tokenErr := infrastructure.GenerateJWT("router@test.com", testUserID)
	assert.NoError(t, tokenErr, "Setup: failed to generate test token")
	authHeader := "Bearer " + validToken

	// --- Helper to create setup for each test ---
	setupTest := func() (*gin.Engine, *MockFlightUseCase) {
		router := gin.New() // Use gin.New()
		mockUseCase := new(MockFlightUseCase)
		// Create REAL controller with MOCK use case
		realController := controllers.NewFlightController(mockUseCase)
		// Setup routes with the REAL controller
		routers.SetupFlightRoutes(router, realController)
		return router, mockUseCase
	}

	// --- Test Cases ---

	t.Run("Middleware Applied - Unauthorized", func(t *testing.T) {
		router, mockUseCase := setupTest() // Use helper

		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/flights", nil) // No Auth header
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		// Ensure no use case methods were called
		mockUseCase.AssertNotCalled(t, "FetchFlightsByUserID", mock.Anything)

		var respBody map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &respBody)
		assert.NoError(t, err)
		assert.Contains(t, respBody["error"], "Authorization header missing")
	})

	t.Run("POST /flights calls use case AddFlight", func(t *testing.T) {
		router, mockUseCase := setupTest()

		// Expect the underlying use case method to be called
		mockUseCase.On("AddFlight", mock.AnythingOfType("*domain.Flight")).Return(nil).Run(func(args mock.Arguments) {
			// Check if UserID was set correctly by the controller before reaching use case
			flightArg := args.Get(0).(*domain.Flight)
			assert.Equal(t, testUserID, flightArg.UserID)
			// Ensure default date is set if applicable (matching controller logic)
			assert.False(t, flightArg.Date.IsZero(), "Date should be set by controller")
		})

		w := httptest.NewRecorder()
		// Need a valid body that passes controller validation
		flightData := gin.H{
			"title":        "Test Flight via Router",
			"from_country": "TestFrom",
			"to_country":   "TestTo",
			"language":     "TestLang",
			"qa": []gin.H{ // Need 5 QA pairs for validation
				{"question": "q1", "answer": "a1"},
				{"question": "q2", "answer": "a2"},
				{"question": "q3", "answer": "a3"},
				{"question": "q4", "answer": "a4"},
				{"question": "q5", "answer": "a5"},
			},
		}
		bodyBytes, _ := json.Marshal(flightData)
		req, _ := http.NewRequest(http.MethodPost, "/flights", bytes.NewBuffer(bodyBytes))
		req.Header.Set("Authorization", authHeader)
		req.Header.Set("Content-Type", "application/json") // Important for ShouldBindJSON

		router.ServeHTTP(w, req)

		// Check if the request reached the controller (which returns OK on success)
		assert.Equal(t, http.StatusOK, w.Code)
		// Assert that the expected use case method was called
		mockUseCase.AssertCalled(t, "AddFlight", mock.AnythingOfType("*domain.Flight"))
		mockUseCase.AssertExpectations(t)
	})

	t.Run("GET /flights calls use case FetchFlightsByUserID", func(t *testing.T) {
		router, mockUseCase := setupTest()

		// Expect use case call with the correct user ID from context
		mockUseCase.On("FetchFlightsByUserID", testUserID).Return([]domain.Flight{}, nil) // Return empty slice for simplicity

		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/flights", nil)
		req.Header.Set("Authorization", authHeader)
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockUseCase.AssertCalled(t, "FetchFlightsByUserID", testUserID)
		mockUseCase.AssertExpectations(t)
	})

	t.Run("GET /flights/:id calls use case FetchFlightByID", func(t *testing.T) {
		router, mockUseCase := setupTest()
		testFlightID := "flight-abc-123"

		// Mock use case to return a flight owned by the test user
		mockUseCase.On("FetchFlightByID", testFlightID).Return(&domain.Flight{
			ID:     testFlightID,
			UserID: testUserID, // Ensure ownership matches for controller check
			Title:  "Fetched Flight",
			// Add other required fields if controller checks them
		}, nil)

		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodGet, "/flights/"+testFlightID, nil)
		req.Header.Set("Authorization", authHeader)
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockUseCase.AssertCalled(t, "FetchFlightByID", testFlightID)
		mockUseCase.AssertExpectations(t)
	})

	t.Run("DELETE /flights/:id calls use case DeleteFlight", func(t *testing.T) {
		router, mockUseCase := setupTest()
		testFlightID := "flight-to-delete-456"

		// Need to mock FetchFlightByID first, as the controller checks ownership before deleting
		mockUseCase.On("FetchFlightByID", testFlightID).Return(&domain.Flight{
			ID:     testFlightID,
			UserID: testUserID, // Match authenticated user
		}, nil).Once() // Expect this call once

		// Expect DeleteFlight call after ownership check passes
		mockUseCase.On("DeleteFlight", testFlightID).Return(nil).Once() // Expect this call once

		w := httptest.NewRecorder()
		req, _ := http.NewRequest(http.MethodDelete, "/flights/"+testFlightID, nil)
		req.Header.Set("Authorization", authHeader)
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		// Assertions are implicitly checked by AssertExpectations
		mockUseCase.AssertExpectations(t) // Verifies both Fetch and Delete were called as expected
	})
}