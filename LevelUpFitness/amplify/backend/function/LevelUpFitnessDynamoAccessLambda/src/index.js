const AWS = require('aws-sdk')
const { DocumentClient } =  require('aws-sdk/clients/dynamodb')
const { json } = require('stream/consumers')

const dynamoDb = new AWS.DynamoDB.DocumentClient()

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {

    if (event.path == "/getExercises" && event.httpMethod == "GET") {
        const params = {
            TableName: "exercises-db-dev",
        }
    
        try {
            const data = await dynamoDb.scan(params).promise()
    
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
    else if (event.path == "/getUserProgramInfo" && event.httpMethod == "GET") {
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
    else if (event.triggerSource == "PostConfirmation_ConfirmSignUp" && event.userName != null) {
        console.log("here")
        console.log("username: " + event.userName)
        const UserID = event.userName

        const params = {
            TableName: "user-badge-info-db-dev",
            Item: {
                "UserID": UserID,
                "BadgesEarned": [],
                "Weeks": 0
            }
        }

        try {
            await dynamoDb.put(params).promise()
            console.log("success")
            return event
        } catch (error) {
            console.log(error)
            return event
        }
    }
    else if (event.path === "/getUserBadgeInfo" && event.httpMethod === "GET") {
        const UserID = event.queryStringParameters.UserID;

        console.log(`UserID: ${UserID}`);

        const params = {
            TableName: "user-badge-info-db-dev",
            Key: {
                "UserID": UserID
            }
        };

        try {
            const data = await dynamoDb.get(params).promise();
            console.log(`Data retrieved: ${JSON.stringify(data)}`);
            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(data.Item)
            };
        } catch (error) {
            console.error(`Error retrieving data: ${JSON.stringify(error, null, 2)}`);
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify({
                    errorMessage: "Error retrieving user badge info",
                    errorDetails: error.message
                })
            };
        }
    }
    else if (event.path == "/modifyUserBadgeInfo" && event.httpMethod == "PUT") {
        const body = JSON.parse(event.body)
        console.log("Weeks: " + body.Weeks)

        let updateParts = [];

        if (body.Weeks == true) {
            console.log("Weeks")
            updateParts.push("Weeks = if_not_exists(Weeks, :numberDefault) + :increment");
        }

        updateParts.push("BadgesEarned = list_append(if_not_exists(BadgesEarned, :badgeDefault), :badges)");

        let updateExpression = "SET " + updateParts.join(", ");
        console.log(updateExpression)
        
        const params = {
            TableName: "user-badge-info-db-dev",
            Key: {
                "UserID": body.UserID
            },
            UpdateExpression: updateExpression,
            ExpressionAttributeValues: {
                ":numberDefault": 0,
                ":increment": 1,
                ":badgeDefault": [],
                ":badges": body.Badges
            }
        }

        try {
            const data = await dynamoDb.update(params).promise()
            console.log("updated")
            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify("Successfully Updated! " + data)
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
    else if (event.path == "/getBadges" && event.httpMethod == "GET") {
        const params = {
            TableName: "badges-db-dev",
        }

        console.log("heres")

        try {
            const data = await dynamoDb.scan(params).promise()

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(data.Items)
            }
        } catch (error) {
            console.log(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                }
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
