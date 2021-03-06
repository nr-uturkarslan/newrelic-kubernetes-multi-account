package commons

import (
	dto "bravo-persistence-service/dtos"
	"bytes"
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/newrelic/go-agent/v3/newrelic"
	"github.com/rs/zerolog"
)

func PerformPostRequest(
	url string,
	ginctx *gin.Context,
	requestDto *dto.ResponseDto,
	customAttributes map[string]string,
) (
	*http.Response,
	error,
) {
	requestDtoInBytes, _ := json.Marshal(requestDto)

	client := &http.Client{}
	client.Transport = newrelic.NewRoundTripper(client.Transport)

	request, _ := http.NewRequest(http.MethodPost, url,
		bytes.NewBufferString(string(requestDtoInBytes)),
	)
	request.Header.Add("Content-Type", "application/json")

	txn := newrelic.FromContext(ginctx)
	for key, value := range customAttributes {
		txn.AddAttribute(key, value)
	}

	request = newrelic.RequestWithTransactionContext(request, txn)
	return client.Do(request)
}

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
