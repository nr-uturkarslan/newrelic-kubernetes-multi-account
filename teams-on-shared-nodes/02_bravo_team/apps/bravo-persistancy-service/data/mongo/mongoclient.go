package mongo

import (
	"bravo-persistancy-service/commons"
	"bravo-persistancy-service/entities"
	"context"
	"errors"
	"fmt"

	"github.com/rs/zerolog"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

type MongoDbClient struct {
	valuesCollection *mongo.Collection
}

func CreateMongoDbInstance() (mdb *MongoDbClient) {

	// Connect to Mongo DB
	commons.Log(zerolog.InfoLevel, "Connecting to Mongo DB...")

	client, err := mongo.Connect(context.Background(),
		options.Client().ApplyURI("mongodb://mongo.bravo.svc.cluster.local:27017"))

	// Panic if connection fails
	if err != nil {
		message := "Connecting to Mongo DB is failed."
		commons.Log(zerolog.PanicLevel, message)
		panic(message)
	}

	// Panic if ping fails
	if err := client.Ping(context.Background(), readpref.Primary()); err != nil {
		message := "Ping to Mongo DB is failed."
		commons.Log(zerolog.PanicLevel, message)
		panic(message)
	}

	// Create the Mongo DB instance
	var mongoDb *MongoDbClient = &MongoDbClient{
		valuesCollection: client.Database("mycustomdb").Collection("values"),
	}

	commons.Log(zerolog.InfoLevel, "Connected to Mongo DB successfully.")

	return mongoDb
}

func (mdb MongoDbClient) Insert(
	entity *entities.Entity,
) (
	err error,
) {

	result, err := mdb.valuesCollection.InsertOne(context.Background(), entity)
	if err != nil {
		commons.Log(zerolog.ErrorLevel, "Insertion to Mongo DB is failed.")
		return errors.New("insertion to mongo db is failed")
	}

	id := fmt.Sprintf("value: %v", result.InsertedID)
	commons.Log(zerolog.InfoLevel, "Document with ID:"+id+"is created successfully")

	return nil
}

func (mdb MongoDbClient) FindAll() (
	*[]entities.Entity,
	error,
) {

	cursor, err := mdb.valuesCollection.Find(context.Background(), bson.D{{}})
	if err != nil {
		commons.Log(zerolog.ErrorLevel, "Retrieving from Mongo DB is failed.")
		return nil, errors.New("retrieving from mongo db is failed")
	}

	defer cursor.Close(context.Background())

	var values []entities.Entity
	for cursor.Next(context.Background()) {
		var value entities.Entity
		cursor.Decode(&value)
		values = append(values, value)
	}

	return &values, nil
}
