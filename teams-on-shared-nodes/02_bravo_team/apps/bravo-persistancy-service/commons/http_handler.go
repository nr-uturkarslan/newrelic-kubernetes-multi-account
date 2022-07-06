package commons

import (
	dto "bravo-persistancy-service/dtos"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"
)

func CreateSuccessfulHttpResponse(
	ginctx *gin.Context,
	httpStatusCode int,
	responseDto *dto.ResponseDto,
) {
	ginctx.JSON(httpStatusCode, responseDto)
}

func CreateFailedHttpResponse(
	ginctx *gin.Context,
	httpStatusCode int,
	message string,
) {
	Log(zerolog.ErrorLevel, message)

	responseDto := dto.ResponseDto{
		Message: message,
	}

	ginctx.JSON(httpStatusCode, responseDto)
}
