package data

import (
	"bravo-persistancy-service/data/mongo"
	"bravo-persistancy-service/data/redis"
	"bravo-persistancy-service/entities"
)

type DbClient struct {
	MongoDbClient *mongo.MongoDbClient
	RedisClient   *redis.RedisClient
}

func CreateDbClient() *DbClient {

	var dbClient *DbClient = &DbClient{
		MongoDbClient: mongo.CreateMongoDbInstance(),
		RedisClient:   redis.CreateRedisInstance(),
	}
	return dbClient
}

func (dbClient DbClient) Insert(
	entity *entities.Entity,
) error {

	// Save entity to DB
	err := dbClient.MongoDbClient.Insert(entity)
	if err != nil {
		return err
	}

	err = dbClient.RedisClient.Insert(entity)
	return err
}
