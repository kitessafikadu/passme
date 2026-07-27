package routers

import (
	"github.com/A2SV/A2SV-2025-Internship-Pass-Me/delivery/controllers"
	Infrastructure "github.com/A2SV/A2SV-2025-Internship-Pass-Me/infrastructure"
	"github.com/gin-gonic/gin"
)

func SetupUserRoutes(router *gin.Engine, controller *controllers.UserController) {
	router.POST("/register", controller.Register)
	router.POST("/login", controller.Login)

	auth := router.Group("/profile")
	auth.Use(Infrastructure.AuthMiddleware())
	{
		auth.GET("/", controller.GetProfile)
		auth.PUT("/username", controller.ChangeUsername)
		auth.PUT("/password", controller.ChangePassword)
	}
}
