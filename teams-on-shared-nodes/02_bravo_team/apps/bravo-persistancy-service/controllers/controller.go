package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/newrelic/go-agent/v3/integrations/nrgin"
	"github.com/newrelic/go-agent/v3/newrelic"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"bravo-persistancy-service/data"
	"bravo-persistancy-service/services/create"
	"bravo-persistancy-service/services/delete"
	"bravo-persistancy-service/services/list"
)

func CreateHandlers(
	router *gin.Engine,
	nrapp *newrelic.Application,
	dbClient *data.DbClient,
) {

	router.Use(nrgin.Middleware(nrapp))

	createHandler := create.CreateHandler{
		DbClient: dbClient,
	}

	listHandler := list.ListHandler{
		DbClient: dbClient,
	}

	deleteHandler := delete.DeleteHandler{
		DbClient: dbClient,
	}

	persistancy := router.Group("/persistancy")
	{
		// Health check
		persistancy.GET("/health", func(ginctx *gin.Context) {
			ginctx.JSON(http.StatusOK, gin.H{
				"message": "OK!",
			})
		})

		// Prometheus
		persistancy.GET("/metrics", prometheusHandler())

		// Create method
		persistancy.POST("/create", createHandler.Run)

		// List method
		persistancy.GET("/list", listHandler.Run)

		// Delete method
		persistancy.DELETE("/delete", deleteHandler.Run)
	}
}

func prometheusHandler() gin.HandlerFunc {
	h := promhttp.Handler()

	return func(c *gin.Context) {
		h.ServeHTTP(c.Writer, c.Request)
	}
}
