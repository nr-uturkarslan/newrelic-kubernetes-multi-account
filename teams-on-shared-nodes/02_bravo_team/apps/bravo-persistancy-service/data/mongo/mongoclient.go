package mongo

import (
	"bravo-persistancy-service/commons"
	"bravo-persistancy-service/entities"
	"context"
	"errors"
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/newrelic/go-agent/_integrations/nrmongo"
	"github.com/newrelic/go-agent/v3/newrelic"
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

	nrMon := nrmongo.NewCommandMonitor(nil)
	client, err := mongo.Connect(context.Background(),
		options.Client().ApplyURI("mongodb://mongo.bravo.svc.cluster.local:27017").
			SetMonitor(nrMon))

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
	ginctx *gin.Context,
	entity *entities.Entity,
) (
	err error,
) {

	txn := newrelic.FromContext(ginctx)
	ctx := newrelic.NewContext(context.Background(), txn)

	result, err := mdb.valuesCollection.InsertOne(ctx, entity)
	if err != nil {
		commons.Log(zerolog.ErrorLevel, "Insertion to Mongo DB is failed.")
		return errors.New("insertion to mongo db is failed")
	}

	id := fmt.Sprintf("value: %v", result.InsertedID)
	commons.Log(zerolog.InfoLevel, "Document with ID:"+id+"is created successfully")

	return nil
}

func (mdb MongoDbClient) FindAll(
	ginctx *gin.Context,
) (
	*[]entities.Entity,
	error,
) {

	txn := newrelic.FromContext(ginctx)
	ctx := newrelic.NewContext(context.Background(), txn)

	cursor, err := mdb.valuesCollection.Find(ctx, bson.D{{}})
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
