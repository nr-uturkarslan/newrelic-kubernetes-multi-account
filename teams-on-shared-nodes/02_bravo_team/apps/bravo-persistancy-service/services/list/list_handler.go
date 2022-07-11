package list

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"

	"bravo-persistancy-service/commons"
	"bravo-persistancy-service/data"
	dto "bravo-persistancy-service/dtos"

	"bravo-persistancy-service/entities"
)

type ListHandler struct {
	DbClient *data.DbClient
}

func (handler ListHandler) Run(
	ginctx *gin.Context,
) {

	// Log start of method execution
	commons.LogWithContext(ginctx, zerolog.InfoLevel, "Create method is triggered...")

	// Retrieve all values DB
	values, err := handler.DbClient.FindAll()
	if err != nil {
		commons.CreateFailedHttpResponse(ginctx, http.StatusInternalServerError,
			"Entity could not be saved into the DB.")
		return
	}

	commons.CreateSuccessfulHttpResponse(ginctx, http.StatusOK,
		handler.createResponseDto(values))

	// Log end of method execution
	commons.LogWithContext(ginctx, zerolog.InfoLevel, "List method is executed.")
}

func (ListHandler) createResponseDto(
	entities *[]entities.Entity,
) *dto.ResponseDto {

	values := []Value{}
	for _, entity := range *entities {
		values = append(values, Value{
			Id:    entity.Id,
			Value: entity.Value,
			Tag:   entity.Tag,
		})
	}

	data := ListResponseDto{
		Value: &values,
	}
	return &dto.ResponseDto{
		Message: "Values are retrieved successfully.",
		Data:    data,
	}
}
