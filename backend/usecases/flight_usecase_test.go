package usecases_test

import (
	"errors"
	"testing"
	"time"

	// Adjust import paths if necessary
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/domain"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/usecases"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// --- Mock FlightRepository ---

type MockFlightRepository struct {
	mock.Mock
}

func (m *MockFlightRepository) CreateFlight(flight *domain.Flight) error {
	args := m.Called(flight)
	return args.Error(0)
}

func (m *MockFlightRepository) GetFlightByID(id string) (*domain.Flight, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.Flight), args.Error(1)
}

func (m *MockFlightRepository) DeleteFlight(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockFlightRepository) GetFlightsByUserID(userID string) ([]domain.Flight, error) {
	args := m.Called(userID)
	// Handle potential nil slice return from mock setup
	if ret := args.Get(0); ret != nil {
		return ret.([]domain.Flight), args.Error(1)
	}
	return nil, args.Error(1) // Return nil slice if mock returned nil
}

// --- Test Cases ---

func TestFlightUseCase_AddFlight(t *testing.T) {
	mockRepo := new(MockFlightRepository)
	// Create the use case instance with the mock repository
	uc := usecases.NewFlightUseCase(mockRepo)

	t.Run("Success", func(t *testing.T) {
		// Arrange
		inputFlight := &domain.Flight{
			Title:       "Test Add",
			FromCountry: "From",
			ToCountry:   "To",
			Date:        time.Now(),
			UserID:      "user1",
			Language:    "Eng",
			QA:          []domain.QA{}, // Content doesn't matter for this layer's test
		}
		// Configure the mock to expect the CreateFlight call and return success (nil error)
		mockRepo.On("CreateFlight", inputFlight).Return(nil).Once()

		// Act
		err := uc.AddFlight(inputFlight)

		// Assert
		assert.NoError(t, err)
		// Verify that the mock method was called exactly as expected
		mockRepo.AssertExpectations(t)
	})

	t.Run("Repository Error", func(t *testing.T) {
		// Arrange
		inputFlight := &domain.Flight{ /* ... same as above ... */ }
		expectedError := errors.New("database insertion failed")
		// Configure the mock to expect the call and return an error
		mockRepo.On("CreateFlight", inputFlight).Return(expectedError).Once()

		// Act
		err := uc.AddFlight(inputFlight)

		// Assert
		assert.Error(t, err)
		assert.Equal(t, expectedError, err)
		mockRepo.AssertExpectations(t)
	})
}

func TestFlightUseCase_FetchFlightByID(t *testing.T) {
	mockRepo := new(MockFlightRepository)
	uc := usecases.NewFlightUseCase(mockRepo)
	testID := "flight123"

	t.Run("Success", func(t *testing.T) {
		// Arrange
		expectedFlight := &domain.Flight{
			ID:          testID,
			Title:       "Fetched Flight",
			UserID:      "user2",
			FromCountry: "Test",
			ToCountry:   "Case",
			Date:        time.Now(),
			Language:    "Go",
			QA:          []domain.QA{},
		}
		mockRepo.On("GetFlightByID", testID).Return(expectedFlight, nil).Once()

		// Act
		resultFlight, err := uc.FetchFlightByID(testID)

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, resultFlight)
		assert.Equal(t, expectedFlight, resultFlight)
		mockRepo.AssertExpectations(t)
	})

	t.Run("Not Found Error", func(t *testing.T) {
		// Arrange
		expectedError := errors.New("flight not found in repo")
		mockRepo.On("GetFlightByID", testID).Return(nil, expectedError).Once()

		// Act
		resultFlight, err := uc.FetchFlightByID(testID)

		// Assert
		assert.Error(t, err)
		assert.Nil(t, resultFlight)
		assert.Equal(t, expectedError, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("Other Repository Error", func(t *testing.T) {
		// Arrange
		expectedError := errors.New("repository connection error")
		mockRepo.On("GetFlightByID", testID).Return(nil, expectedError).Once()

		// Act
		resultFlight, err := uc.FetchFlightByID(testID)

		// Assert
		assert.Error(t, err)
		assert.Nil(t, resultFlight)
		assert.Equal(t, expectedError, err)
		mockRepo.AssertExpectations(t)
	})
}

func TestFlightUseCase_DeleteFlight(t *testing.T) {
	mockRepo := new(MockFlightRepository)
	uc := usecases.NewFlightUseCase(mockRepo)
	testID := "flightToDelete456"

	t.Run("Success", func(t *testing.T) {
		// Arrange
		mockRepo.On("DeleteFlight", testID).Return(nil).Once()

		// Act
		err := uc.DeleteFlight(testID)

		// Assert
		assert.NoError(t, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("Repository Error", func(t *testing.T) {
		// Arrange
		expectedError := errors.New("failed to delete from DB")
		mockRepo.On("DeleteFlight", testID).Return(expectedError).Once()

		// Act
		err := uc.DeleteFlight(testID)

		// Assert
		assert.Error(t, err)
		assert.Equal(t, expectedError, err)
		mockRepo.AssertExpectations(t)
	})
}

func TestFlightUseCase_FetchFlightsByUserID(t *testing.T) {
	mockRepo := new(MockFlightRepository)
	uc := usecases.NewFlightUseCase(mockRepo)
	testUserID := "user789"

	t.Run("Success - Flights Found", func(t *testing.T) {
		// Arrange
		expectedFlights := []domain.Flight{
			{ID: "f1", UserID: testUserID, Title: "User Flight 1"},
			{ID: "f2", UserID: testUserID, Title: "User Flight 2"},
		}
		mockRepo.On("GetFlightsByUserID", testUserID).Return(expectedFlights, nil).Once()

		// Act
		resultFlights, err := uc.FetchFlightsByUserID(testUserID)

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, resultFlights)
		assert.Equal(t, expectedFlights, resultFlights)
		assert.Len(t, resultFlights, 2)
		mockRepo.AssertExpectations(t)
	})

	t.Run("Success - No Flights Found", func(t *testing.T) {
		// Arrange
		// Configure mock to return an empty slice and nil error
		mockRepo.On("GetFlightsByUserID", testUserID).Return([]domain.Flight{}, nil).Once()

		// Act
		resultFlights, err := uc.FetchFlightsByUserID(testUserID)

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, resultFlights) // Check if it's non-nil empty slice
		assert.Empty(t, resultFlights)  // Check if the slice is empty
		mockRepo.AssertExpectations(t)
	})

	t.Run("Repository Error", func(t *testing.T) {
		// Arrange
		expectedError := errors.New("database query failed")
		mockRepo.On("GetFlightsByUserID", testUserID).Return(nil, expectedError).Once()

		// Act
		resultFlights, err := uc.FetchFlightsByUserID(testUserID)

		// Assert
		assert.Error(t, err)
		assert.Nil(t, resultFlights)
		assert.Equal(t, expectedError, err)
		mockRepo.AssertExpectations(t)
	})
}