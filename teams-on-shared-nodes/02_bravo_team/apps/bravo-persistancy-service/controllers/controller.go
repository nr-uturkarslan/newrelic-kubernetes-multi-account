package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/newrelic/go-agent/v3/integrations/nrgin"
	"github.com/newrelic/go-agent/v3/newrelic"

	create "bravo-persistancy-service/services/create"
)

func CreateHandlers(
	router *gin.Engine,
	nrapp *newrelic.Application,
) {

	router.Use(nrgin.Middleware(nrapp))

	createHandler := create.CreateHandler{}

	proxy := router.Group("/persistancy")
	{
		// Health check
		proxy.GET("/health", func(ginctx *gin.Context) {
			ginctx.JSON(http.StatusOK, gin.H{
				"message": "OK!",
			})
		})

		// Create method
		proxy.POST("/create", createHandler.Create)
	}
}
