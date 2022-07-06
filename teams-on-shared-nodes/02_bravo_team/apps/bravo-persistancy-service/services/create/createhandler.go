package create

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/newrelic/go-agent/v3/newrelic"
	"github.com/rs/zerolog"

	"bravo-persistancy-service/commons"
	dto "bravo-persistancy-service/services/create/dtos"

	"bravo-persistancy-service/entities"
)

type CreateHandler struct {
	Nrapp *newrelic.Application
}

func (s CreateHandler) Create(
	ginctx *gin.Context,
) {

	// Log start of method execution
	commons.Log(zerolog.InfoLevel, "Create method is triggered...")

	// Parse request body
	requestBody, err := s.parseRequestBody(ginctx)

	if err != nil {
		return
	}

	commons.CreateSuccessfulHttpResponse(ginctx, http.StatusOK,
		s.createResponseDto(responseDtoFromSecondService))

	// Log end of method execution
	commons.Log(zerolog.InfoLevel, "Create method is executed.")
}

func (CreateHandler) parseRequestBody(
	ginctx *gin.Context,
) (
	*dto.RequestDto,
	error,
) {

	// Parse request body
	var requestDto dto.RequestDto
	err := ginctx.BindJSON(&requestDto)

	// Log error if occurs
	if err != nil {
		commons.CreateFailedHttpResponse(ginctx, http.StatusBadRequest,
			"Request body could not be parsed.")

		return nil, err
	}

	// Log provided values
	commons.Log(zerolog.InfoLevel, "Value provided: "+requestDto.Value)
	commons.Log(zerolog.InfoLevel, "Tag provided: "+requestDto.Tag)

	return &requestDto, nil
}

func (CreateHandler) createResponseDto(
	data *dto.ResponseDto,
) *dto.ResponseDto {
	return &dto.ResponseDto{
		Message: "Succeeded.",
		Data: entities.Entity{
			Id:    "asd",
			Value: data.Value,
			Tag:   data.Tag,
		},
	}
}
