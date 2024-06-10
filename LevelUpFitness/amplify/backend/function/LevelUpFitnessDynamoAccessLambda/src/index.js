const AWS = require('aws-sdk')
const { DocumentClient } =  require('aws-sdk/clients/dynamodb')
const { json } = require('stream/consumers')

const dynamoDb = new AWS.DynamoDB.DocumentClient()

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {

    if (event.path == "/getWorkouts" && event.httpMethod == "GET") {
        const UserID = event.queryStringParameters.UserID
    
        const params = {
            TableName: "workouts-db-dev",
            KeyConditionExpression: "UserID = :userID",
            ExpressionAttributeValues: {
                ":userID": UserID
            }
        }
    
        try {
            const data = await dynamoDb.query(params).promise()
    
            if (data.Items.length > 0) {
                return {
                    statusCode: 200,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify(data.Items)
                }
            } else {
                return {
                    statusCode: 404,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify({ message: "No workouts found for the given UserID" })
                }
            }
        } catch (error) {
            console.log(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            }
        }
    }
    else if (event.path == "/addUserProgram" && event.httpMethod == "PUT") {
        try {
            const UserID = event.queryStringParameters.UserID
            const Program = event.queryStringParameters.Program
    
            const params = {
                TableName: "user-programs-db-dev",
                Item: {
                    UserID: UserID,
                    Program: Program
                }
            }
    
            const response = await dynamoDb.put(params).promise()
    
            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(response)
            }
        } catch (error) {
            console.log(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            }
        }
    }
    else if (event.path = "/getUserProgramInfo" && event.httpMethod == "GET") {
        const UserID = event.queryStringParameters.UserID

        const params = {
            TableName: "user-programs-db-dev",
            KeyConditionExpression: "UserID = :userID",
            ExpressionAttributeValues: {
                ":userID": UserID
            }
        }

        try {
            const data = await dynamoDb.query(params).promise()

            if (data.Items.length > 0) {
                return {
                    statusCode: 200,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify(data.Items[0])
                }
            } else {
                return {
                    statusCode: 404,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify({ message: "No Program found for the given UserID" })
                }
            }
        } catch (error) {
            print(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            }
        }
    }
    

    return {
        statusCode: 200,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*"
        },
        body: JSON.stringify('Hello from Lambda!')
    }
}
