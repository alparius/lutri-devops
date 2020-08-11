package router

import (
	"lutri/controller"
	"lutri/router/middleware"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type MyRouter struct {
	foodCtrl *controller.FoodController
	router   *gin.Engine
}

// New returns a custom router with middlewares and controllers injected.
func New(foodCtrl *controller.FoodController) *MyRouter {
	router := gin.New()
	gin.ForceConsoleColor()

	// setting up middlewares
	router.Use(gin.Logger())
	router.Use(gin.Recovery())
	router.Use(middleware.GinCors())

	return &MyRouter{foodCtrl, router}
}

// Run sets up the REST API endpoints and starts the router.
func (myRouter *MyRouter) Run(port string) {
	myRouter.router.GET("/api/food/:id", myRouter.foodCtrl.GetByID)
	myRouter.router.GET("/api/foods", myRouter.foodCtrl.GetAll)
	myRouter.router.POST("/api/food", myRouter.foodCtrl.Insert)
	myRouter.router.PUT("/api/food", myRouter.foodCtrl.Update)
	myRouter.router.DELETE("/api/food/:id", myRouter.foodCtrl.Delete)

	err := myRouter.router.Run(":" + port)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("router startup error")
	}
}
