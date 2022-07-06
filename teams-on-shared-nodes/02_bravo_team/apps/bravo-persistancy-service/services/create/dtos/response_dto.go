package dto

import (
	"bravo-persistancy-service/entities"
)

type ResponseData struct {
	Id    string `json:"id"`
	Value string `json:"value"`
	Tag   string `json:"tag"`
}

type ResponseDto struct {
	Message string          `json:"message"`
	Data    entities.Entity `json:"data"`
}
