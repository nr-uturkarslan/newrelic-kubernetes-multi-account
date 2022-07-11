package create

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/rs/zerolog"

	"bravo-persistancy-service/commons"
	"bravo-persistancy-service/data"
	dto "bravo-persistancy-service/dtos"

	"bravo-persistancy-service/entities"
)

type CreateHandler struct {
	DbClient *data.DbClient
}

func (handler CreateHandler) Create(
	ginctx *gin.Context,
) {

	// Log start of method execution
	commons.LogWithContext(ginctx, zerolog.InfoLevel, "Create method is triggered...")

	// Parse request body
	requestBody, err := handler.parseRequestBody(ginctx)
	if err != nil {
		return
	}

	// Create an entity
	entity := handler.createEntity(requestBody)

	// Save entity to DB
	err = handler.DbClient.Insert(entity)
	if err != nil {
		commons.CreateFailedHttpResponse(ginctx, http.StatusInternalServerError,
			"Entity could not be saved into the DB.")
		return
	}

	commons.CreateSuccessfulHttpResponse(ginctx, http.StatusOK,
		handler.createResponseDto(entity))

	// Log end of method execution
	commons.LogWithContext(ginctx, zerolog.InfoLevel, "Create method is executed.")
}

func (CreateHandler) parseRequestBody(
	ginctx *gin.Context,
) (
	*RequestDto,
	error,
) {

	// Parse request body
	var requestDto RequestDto
	err := ginctx.BindJSON(&requestDto)

	// Log error if occurs
	if err != nil {
		commons.CreateFailedHttpResponse(ginctx, http.StatusBadRequest,
			"Request body could not be parsed.")

		return nil, err
	}

	// Log provided values
	commons.LogWithContext(ginctx, zerolog.InfoLevel, "Value provided: "+requestDto.Value)
	commons.LogWithContext(ginctx, zerolog.InfoLevel, "Tag provided: "+requestDto.Tag)

	return &requestDto, nil
}

func (CreateHandler) createEntity(
	requestDto *RequestDto,
) *entities.Entity {
	return &entities.Entity{
		Id:    uuid.New().String(),
		Value: requestDto.Value,
		Tag:   requestDto.Tag,
	}
}

func (CreateHandler) createResponseDto(
	entity *entities.Entity,
) *dto.ResponseDto {
	return &dto.ResponseDto{
		Message: "Entity is successfully created.",
		Data:    entity,
	}
}
