package redis

import (
	"bravo-persistancy-service/commons"
	"bravo-persistancy-service/entities"
	"encoding/json"
	"errors"

	"github.com/go-redis/redis"
	"github.com/rs/zerolog"
)

type RedisClient struct {
	RedisClient *redis.Client
}

func CreateRedisInstance() *RedisClient {
	client := redis.NewClient(&redis.Options{
		Addr:     "redis.bravo.svc.cluster.local:6379",
		Password: "",
		DB:       0,
	})

	_, err := client.Ping().Result()
	if err != nil {
		message := "Connecting to Redis is failed."
		commons.Log(zerolog.PanicLevel, message)
		panic(message)
	}

	// Create the Mongo DB instance
	var redis *RedisClient = &RedisClient{
		RedisClient: client,
	}
	return redis
}

func (redisClient RedisClient) Insert(
	entity *entities.Entity,
) (
	err error,
) {

	// Serialize the entity
	entityAsBytes, err := json.Marshal(entity)
	if err != nil {
		commons.Log(zerolog.ErrorLevel, "Connecting to Redis is failed.")
		return errors.New("connecting to redis is failed")
	}

	// Set entity to cache
	err = redisClient.RedisClient.Set(entity.Id, entityAsBytes, 0).Err()
	if err != nil {
		commons.Log(zerolog.ErrorLevel, "Inserting entity with ID"+entity.Id+"is failed.")
		return errors.New("inserting entity with id" + entity.Id + "is failed")
	}

	return nil
}

func (redisClient RedisClient) Get(
	id string,
) *entities.Entity {

	// Get entity from cache
	entityAsString, err := redisClient.RedisClient.Get(id).Bytes()
	if err != nil {
		commons.Log(zerolog.InfoLevel, "Entity with ID"+id+"does not exist in the cache.")
	}

	var entity *entities.Entity
	json.Unmarshal(entityAsString, entity)

	return entity
}
