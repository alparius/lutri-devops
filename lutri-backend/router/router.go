package router

import (
	"lutri/controller"
	"lutri/router/middleware"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	muxlogrus "github.com/pytimer/mux-logrus"
	"github.com/rs/cors"
	"github.com/sirupsen/logrus"
)

// Run sets up the REST API endpoints and starts the router.
func Run(foodCtrl *controller.FoodController, port string) {
	router := mux.NewRouter()

	router.Use(muxlogrus.NewLogger().Middleware)

	phm := middleware.InitPrometheusHttpMetric("lutri")

	router.Handle("/api/metrics", promhttp.Handler())

	router.Handle("/api/food/{id}", phm.WrapHandler("foodCtrl.GetByID", foodCtrl.GetByID)).Methods("GET")
	router.Handle("/api/foods", phm.WrapHandler("foodCtrl.GetAll", foodCtrl.GetAll)).Methods("GET")
	router.Handle("/api/food", phm.WrapHandler("foodCtrl.Insert", foodCtrl.Insert)).Methods("POST")
	router.Handle("/api/food", phm.WrapHandler("foodCtrl.Update", foodCtrl.Update)).Methods("PUT")
	router.Handle("/api/food/{id}", phm.WrapHandler("foodCtrl.Delete", foodCtrl.Delete)).Methods("DELETE")

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
	})

	handler := c.Handler(router)
	logrus.Error(http.ListenAndServe(":"+port, handler))
}
