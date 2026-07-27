package routers

import (
	"github.com/gin-gonic/gin"
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/controllers"
	Infrastructure "github.com/A2SV/A2SV-2025-Internship-Pass-Me/infrastructure"
)

func SetupFlightRoutes(router *gin.Engine, controller *controllers.FlightController) {
	flights := router.Group("/flights")
	flights.Use(Infrastructure.AuthMiddleware())
	{
		flights.POST("", controller.CreateFlight)

		flights.GET("", controller.GetUserFlights)

		flights.GET("/:id", controller.GetFlightByID)

		flights.DELETE("/:id", controller.DeleteFlight)
	}
}
