package main

import (
	"context"
	"log"
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/controllers"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/routers"
	repositories "github.com/A2SV/A2SV-2025-Internship-Pass-Me/repositories"
	usecases "github.com/A2SV/A2SV-2025-Internship-Pass-Me/usecases"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	// Try to load .env file from parent directory
	err := godotenv.Load("./.env")
	if err != nil {
		log.Printf("Warning: Could not load .env file: %v", err)
	}

	// Get MongoDB URI from environment variables
	mongoURI := os.Getenv("MONGO_URI")
	if mongoURI == "" {
		// Default to MongoDB in docker-compose
		mongoURI = "mongodb://mongodb:27017/passme"
		log.Printf("Using default MongoDB URI: %s", mongoURI)
	}

	log.Printf("Attempting to connect to MongoDB at: %s", mongoURI)

	// Connect to MongoDB
	client, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}

	// Check the connection
	err = client.Ping(context.Background(), nil)
	if err != nil {
		log.Fatalf("Failed to ping MongoDB: %v", err)
	}
	log.Println("Successfully connected to MongoDB!")

	defer client.Disconnect(context.Background())

	// Select the database
	db := client.Database("passme")
	log.Printf("Using database: %s", db.Name())

	// Initialize repositories
	flightRepo := repositories.NewFlightRepository(db)
	userRepo := repositories.NewUserRepository(db)

	// Initialize use cases
	flightUC := usecases.NewFlightUseCase(flightRepo)
	userUC := usecases.NewUserUseCase(userRepo)

	// Initialize controllers
	flightController := controllers.NewFlightController(flightUC)
	userController := controllers.NewUserController(userUC)

	// Set up the Gin router
	r := gin.Default()

	// Apply CORS middleware
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
	}))


	// Set up the routes
	routers.SetupUserRoutes(r, userController)
	routers.SetupFlightRoutes(r, flightController)

	// Start the server
	log.Println("Server is running at :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
