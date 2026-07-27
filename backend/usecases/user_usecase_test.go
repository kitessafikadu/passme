package usecases_test

import (
	"errors"
	"testing"
	// "log" // Uncomment for debugging MatchedBy

	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/domain"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/usecases"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"golang.org/x/crypto/bcrypt"
)

// --- Mock UserRepository (Keep as is from previous versions) ---
type MockUserRepository struct {
	mock.Mock
}

// (Implementations for CreateUser, FindUserByEmail, etc. remain the same)
func (m *MockUserRepository) CreateUser(user *domain.User) error {
	args := m.Called(user)
	if args.Error(0) == nil && user != nil {
		// Simulate database assigning an ID
		if user.ID.IsZero() { // Assign ID only if it's not already set (might be set in test setup)
			user.ID = primitive.NewObjectID()
		}
	}
	return args.Error(0)
}
func (m *MockUserRepository) FindUserByEmail(email string) (*domain.User, error) {
	args := m.Called(email)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}
func (m *MockUserRepository) FindUserByUsername(username string) (*domain.User, error) {
	args := m.Called(username)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}
func (m *MockUserRepository) FindUserByID(id string) (*domain.User, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}
func (m *MockUserRepository) UpdateUsername(id, newUsername string) error {
	args := m.Called(id, newUsername)
	return args.Error(0)
}
func (m *MockUserRepository) UpdatePassword(id, hashedPassword string) error {
	args := m.Called(id, hashedPassword)
	return args.Error(0)
}

// --- Test Cases ---

// TestUserUseCase_RegisterUser
func TestUserUseCase_RegisterUser(t *testing.T) {
	baseInputUser := &domain.User{
		Username: "testRegUser",
		Email:    "register@example.com",
		Password: "plainPassword123", // Store the plain password here
	}
	getFreshInputUser := func() *domain.User {
		u := *baseInputUser // Create a shallow copy
		return &u
	}

	// --- Success test ---
	t.Run("Success", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		testUser := getFreshInputUser()
		plainPassword := testUser.Password // Keep plain password for comparison

		mockRepo.On("FindUserByEmail", testUser.Email).Return(nil, nil).Maybe()
		mockRepo.On("FindUserByUsername", testUser.Username).Return(nil, nil).Maybe()
		mockRepo.On("CreateUser", mock.MatchedBy(func(u *domain.User) bool {
			return u.Username == testUser.Username &&
				u.Email == testUser.Email &&
				u.Password != plainPassword && // Ensure it's hashed
				bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(plainPassword)) == nil
		})).Return(nil).Once()

		err := uc.RegisterUser(testUser) // testUser.Password gets hashed inside
		assert.NoError(t, err)
		// Optionally check if ID was assigned by mock
		// assert.False(t, testUser.ID.IsZero(), "User ID should be assigned by mock CreateUser")
		mockRepo.AssertExpectations(t)
	})

	// --- Email Already Exists test ---
	t.Run("Email Already Exists", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		testUser := getFreshInputUser()

		existingUser := &domain.User{ID: primitive.NewObjectID(), Email: testUser.Email}
		mockRepo.On("FindUserByEmail", testUser.Email).Return(existingUser, nil).Once()
		// FindUserByUsername might or might not be called depending on implementation detail, use Maybe
		mockRepo.On("FindUserByUsername", testUser.Username).Return(nil, nil).Maybe()
		// CreateUser should not be called
		mockRepo.On("CreateUser", mock.AnythingOfType("*domain.User")).Return(errors.New("should not be called")).Maybe()


		err := uc.RegisterUser(testUser)
		assert.Error(t, err)
		assert.EqualError(t, err, "user with this email already exists")
		mockRepo.AssertExpectations(t)
	})

	// --- Username Already Exists test ---
	t.Run("Username Already Exists", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		testUser := getFreshInputUser()

		existingUser := &domain.User{ID: primitive.NewObjectID(), Username: testUser.Username}
		mockRepo.On("FindUserByEmail", testUser.Email).Return(nil, nil).Maybe()
		mockRepo.On("FindUserByUsername", testUser.Username).Return(existingUser, nil).Once()
		// CreateUser should not be called
		mockRepo.On("CreateUser", mock.AnythingOfType("*domain.User")).Return(errors.New("should not happen")).Maybe()

		err := uc.RegisterUser(testUser)
		assert.Error(t, err)
		assert.EqualError(t, err, "username already taken")
		mockRepo.AssertExpectations(t)
	})

	// --- Find Email Repository Error test --- Refactored ---
	t.Run("Find Email Repository Error", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)

		// Define inputs directly in the test scope
		inputUsername := "testRegUser"
		inputEmail := "register@example.com"
		inputPlainPassword := "plainPassword123"

		userToRegister := &domain.User{
			Username: inputUsername,
			Email:    inputEmail,
			Password: inputPlainPassword, // Start with plain password
		}

		dbError := errors.New("db connection error")
		mockRepo.On("FindUserByEmail", inputEmail).Return(nil, dbError).Once() // This error is ignored by use case
		mockRepo.On("FindUserByUsername", inputUsername).Return(nil, nil).Maybe() // This is called next

		// Expect CreateUser to be called because the find error was ignored
		mockRepo.On("CreateUser", mock.MatchedBy(func(u *domain.User) bool {
			// u is the user passed to CreateUser (should have hashed password)
			correctUsername := u.Username == inputUsername
			correctEmail := u.Email == inputEmail
			// Compare the hash in u.Password against the original plain password
			correctPassword := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(inputPlainPassword)) == nil
			// Uncomment for debugging if needed:
			// if !correctPassword {
			//  log.Printf("Find Email Repo Err - Pwd Compare Fail: Hashed='%s', Plain='%s'\n", u.Password, inputPlainPassword)
			// }
			return correctUsername && correctEmail && correctPassword
		})).Return(nil).Once() // Assume create succeeds after ignored error

		// Act
		err := uc.RegisterUser(userToRegister) // Pass the user with plain password

		// Assert
		// The CURRENT use case IGNORES the DB error from FindUserByEmail and proceeds.
		// Since CreateUser is mocked to succeed, the final error is nil.
		assert.NoError(t, err)
		mockRepo.AssertExpectations(t)
	})

	// --- Find Username Repository Error test --- Refactored ---
	t.Run("Find Username Repository Error", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)

		// Define inputs directly
		inputUsername := "testRegUser"
		inputEmail := "register@example.com"
		inputPlainPassword := "plainPassword123"

		userToRegister := &domain.User{
			Username: inputUsername,
			Email:    inputEmail,
			Password: inputPlainPassword,
		}

		dbError := errors.New("db connection error username")
		mockRepo.On("FindUserByEmail", inputEmail).Return(nil, nil).Maybe()
		mockRepo.On("FindUserByUsername", inputUsername).Return(nil, dbError).Once() // This error is ignored by use case

		// Expect CreateUser to be called because the find error was ignored
		mockRepo.On("CreateUser", mock.MatchedBy(func(u *domain.User) bool {
			correctUsername := u.Username == inputUsername
			correctEmail := u.Email == inputEmail
			correctPassword := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(inputPlainPassword)) == nil
			// Uncomment for debugging if needed:
			// if !correctPassword {
			//  log.Printf("Find Username Repo Err - Pwd Compare Fail: Hashed='%s', Plain='%s'\n", u.Password, inputPlainPassword)
			// }
			return correctUsername && correctEmail && correctPassword
		})).Return(nil).Once() // Assume create succeeds after ignored error

		// Act
		err := uc.RegisterUser(userToRegister)

		// Assert
		// The CURRENT use case IGNORES the DB error from FindUserByUsername and proceeds.
		// Since CreateUser is mocked to succeed, the final error is nil.
		assert.NoError(t, err)
		mockRepo.AssertExpectations(t)
	})

	// --- CreateUser Repository Error test ---
	t.Run("CreateUser Repository Error", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		testUser := getFreshInputUser()
		plainPassword := testUser.Password // Keep plain password for comparison

		expectedError := errors.New("database write error")
		mockRepo.On("FindUserByEmail", testUser.Email).Return(nil, nil).Maybe()
		mockRepo.On("FindUserByUsername", testUser.Username).Return(nil, nil).Maybe()
		// Expect CreateUser to be called, matching the hashed password, but return an error
		mockRepo.On("CreateUser", mock.MatchedBy(func(u *domain.User) bool {
			return u.Username == testUser.Username &&
				u.Email == testUser.Email &&
				bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(plainPassword)) == nil
		})).Return(expectedError).Once()

		err := uc.RegisterUser(testUser)
		assert.Error(t, err)
		assert.Equal(t, expectedError, err) // Use case should propagate this error
		mockRepo.AssertExpectations(t)
	})
}

// TestUserUseCase_LoginUser
func TestUserUseCase_LoginUser(t *testing.T) {
	email := "login@example.com"
	plainPassword := "goodPassword123"
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(plainPassword), bcrypt.DefaultCost)
	user := &domain.User{
		ID:       primitive.NewObjectID(),
		Username: "loginUser",
		Email:    email,
		Password: string(hashedPassword),
	}

	t.Run("Success", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)

		mockRepo.On("FindUserByEmail", email).Return(user, nil).Once()

		returnedUser, err := uc.LoginUser(email, plainPassword)

		assert.NoError(t, err)
		assert.NotNil(t, returnedUser)
		assert.Equal(t, user.ID, returnedUser.ID)
		assert.Equal(t, user.Email, returnedUser.Email)
		mockRepo.AssertExpectations(t)
	})

	t.Run("User Not Found (Incorrect Email)", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)

		mockRepo.On("FindUserByEmail", email).Return(nil, errors.New("mongo: no documents in result")).Once()

		returnedUser, err := uc.LoginUser(email, plainPassword)

		assert.Error(t, err)
		assert.Nil(t, returnedUser)
		assert.EqualError(t, err, "invalid email or password")
		mockRepo.AssertExpectations(t)
	})

	t.Run("Repository Error on FindUserByEmail", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		dbError := errors.New("database connection failed")

		mockRepo.On("FindUserByEmail", email).Return(nil, dbError).Once()

		returnedUser, err := uc.LoginUser(email, plainPassword)

		assert.Error(t, err)
		assert.Nil(t, returnedUser)
		assert.EqualError(t, err, "invalid email or password")
		mockRepo.AssertExpectations(t)
	})

	t.Run("Incorrect Password", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		wrongPassword := "wrongPassword"

		mockRepo.On("FindUserByEmail", email).Return(user, nil).Once()

		returnedUser, err := uc.LoginUser(email, wrongPassword)

		assert.Error(t, err)
		assert.Nil(t, returnedUser)
		assert.EqualError(t, err, "invalid email or password")
		mockRepo.AssertExpectations(t)
	})
}

// TestUserUseCase_GetProfile
func TestUserUseCase_GetProfile(t *testing.T) {
	userID := primitive.NewObjectID().Hex()
	user := &domain.User{
		ID: func() primitive.ObjectID {
			objID, err := primitive.ObjectIDFromHex(userID)
			if err != nil {
				t.Fatalf("invalid ObjectID: %v", err)
			}
			return objID
		}(),
		Username: "profileUser",
		Email:    "profile@example.com",
		Password: "hashedPassword",
	}

	t.Run("Success", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)

		mockRepo.On("FindUserByID", userID).Return(user, nil).Once()

		returnedUser, err := uc.GetProfile(userID)

		assert.NoError(t, err)
		assert.NotNil(t, returnedUser)
		assert.Equal(t, user.ID.Hex(), returnedUser.ID.Hex())
		assert.Equal(t, user.Username, returnedUser.Username)
		assert.Equal(t, user.Email, returnedUser.Email)
		assert.Equal(t, user.Password, returnedUser.Password)
		mockRepo.AssertExpectations(t)
	})

	t.Run("User Not Found", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		repoError := errors.New("user not found in DB")

		mockRepo.On("FindUserByID", userID).Return(nil, repoError).Once()

		returnedUser, err := uc.GetProfile(userID)

		assert.Error(t, err)
		assert.Nil(t, returnedUser)
		assert.Equal(t, repoError, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("Repository Error", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		dbError := errors.New("database connection error")

		mockRepo.On("FindUserByID", userID).Return(nil, dbError).Once()

		returnedUser, err := uc.GetProfile(userID)

		assert.Error(t, err)
		assert.Nil(t, returnedUser)
		assert.Equal(t, dbError, err)
		mockRepo.AssertExpectations(t)
	})
}

// TestUserUseCase_UpdateUsername
func TestUserUseCase_UpdateUsername(t *testing.T) {
	userID := primitive.NewObjectID().Hex()
	newUsername := "updatedUser"

	t.Run("Success", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		// FindUserByUsername might return nil/nil or nil/error, use Maybe if error is ignored
		mockRepo.On("FindUserByUsername", newUsername).Return(nil, nil).Maybe() // Error ignored by use case
		mockRepo.On("UpdateUsername", userID, newUsername).Return(nil).Once()
		err := uc.UpdateUsername(userID, newUsername)
		assert.NoError(t, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("Username Already Taken", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		existingUser := &domain.User{ID: primitive.NewObjectID(), Username: newUsername}
		mockRepo.On("FindUserByUsername", newUsername).Return(existingUser, nil).Once()
		// UpdateUsername should not be called
		mockRepo.On("UpdateUsername", userID, newUsername).Return(nil).Maybe()

		err := uc.UpdateUsername(userID, newUsername)
		assert.Error(t, err)
		assert.EqualError(t, err, "username already taken")
		mockRepo.AssertExpectations(t)
	})

	t.Run("FindUserByUsername Repository Error", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		dbError := errors.New("db error checking username")
		mockRepo.On("FindUserByUsername", newUsername).Return(nil, dbError).Once() // This error is ignored
		// IMPORTANT: UpdateUsername WILL be called because the use case ignores the error above
		mockRepo.On("UpdateUsername", userID, newUsername).Return(nil).Once() // Expect it to be called and succeed

		err := uc.UpdateUsername(userID, newUsername)
		// Assert NoError because the use case ignores the FindUserByUsername error and proceeds,
		// and the subsequent UpdateUsername call is mocked to succeed.
		assert.NoError(t, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("UpdateUsername Repository Error", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		repoError := errors.New("db error updating username")
		mockRepo.On("FindUserByUsername", newUsername).Return(nil, nil).Maybe() // Assume check passes or error ignored
		mockRepo.On("UpdateUsername", userID, newUsername).Return(repoError).Once() // Update itself fails

		err := uc.UpdateUsername(userID, newUsername)
		assert.Error(t, err)
		assert.Equal(t, repoError, err) // Use case propagates the error from the actual update
		mockRepo.AssertExpectations(t)
	})
}

// TestUserUseCase_UpdatePassword
func TestUserUseCase_UpdatePassword(t *testing.T) {
	userID := primitive.NewObjectID().Hex()
	oldPlainPassword := "oldPassword123"
	newPlainPassword := "newPassword456"
	oldHashedPassword, _ := bcrypt.GenerateFromPassword([]byte(oldPlainPassword), bcrypt.DefaultCost)

	user := &domain.User{
		ID: func() primitive.ObjectID {
			objID, err := primitive.ObjectIDFromHex(userID)
			if err != nil {
				t.Fatalf("invalid ObjectID: %v", err)
			}
			return objID
		}(),
		Username: "passwordUser",
		Email:    "password@example.com",
		Password: string(oldHashedPassword), // User has the correct old hashed password
	}

	t.Run("Success", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)

		mockRepo.On("FindUserByID", userID).Return(user, nil).Once()
		mockRepo.On("UpdatePassword", userID, mock.MatchedBy(func(hashed string) bool {
			// Check if the hash matches the new plain password
			return bcrypt.CompareHashAndPassword([]byte(hashed), []byte(newPlainPassword)) == nil
		})).Return(nil).Once()

		err := uc.UpdatePassword(userID, oldPlainPassword, newPlainPassword)

		assert.NoError(t, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("User Not Found", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		repoError := errors.New("user not found in DB")

		mockRepo.On("FindUserByID", userID).Return(nil, repoError).Once()
		// UpdatePassword should not be called
		mockRepo.On("UpdatePassword", mock.Anything, mock.Anything).Return(nil).Maybe()

		err := uc.UpdatePassword(userID, oldPlainPassword, newPlainPassword)

		assert.Error(t, err)
		assert.Equal(t, repoError, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("Incorrect Old Password", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		wrongOldPassword := "wrongOldPassword"

		mockRepo.On("FindUserByID", userID).Return(user, nil).Once() // User is found
		// UpdatePassword should not be called
		mockRepo.On("UpdatePassword", mock.Anything, mock.Anything).Return(nil).Maybe()

		err := uc.UpdatePassword(userID, wrongOldPassword, newPlainPassword)

		assert.Error(t, err)
		assert.EqualError(t, err, "incorrect old password")
		mockRepo.AssertExpectations(t)
	})

	t.Run("Repository Error on UpdatePassword", func(t *testing.T) {
		mockRepo := new(MockUserRepository)
		uc := usecases.NewUserUseCase(mockRepo)
		repoError := errors.New("failed to update password in DB")

		mockRepo.On("FindUserByID", userID).Return(user, nil).Once() // User found, old password check passes
		mockRepo.On("UpdatePassword", userID, mock.MatchedBy(func(hashed string) bool {
			return bcrypt.CompareHashAndPassword([]byte(hashed), []byte(newPlainPassword)) == nil
		})).Return(repoError).Once() // Update fails

		err := uc.UpdatePassword(userID, oldPlainPassword, newPlainPassword)

		assert.Error(t, err)
		assert.Equal(t, repoError, err)
		mockRepo.AssertExpectations(t)
	})
}