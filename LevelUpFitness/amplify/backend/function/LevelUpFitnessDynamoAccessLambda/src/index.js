const AWS = require('aws-sdk');
const { DocumentClient } = require('aws-sdk/clients/dynamodb');
const { json } = require('stream/consumers');
const { v4: uuidv4 } = require('uuid');

const { DateTime } = require('luxon');

const dynamoDb = new AWS.DynamoDB.DocumentClient();

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
    if (event.path === "/getExercises" && event.httpMethod === "GET") {
        const params = {
            TableName: "exercises-db-dev"
        };

        try {
            const data = await dynamoDb.scan(params).promise();

            if (data.Items.length > 0) {
                return {
                    statusCode: 200,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify(data.Items)
                };
            } else {
                return {
                    statusCode: 404,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify({ message: "No workouts found for the given UserID" })
                };
            }
        } catch (error) {
            console.log(error);
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    } else if (event.path === "/addUserProgram" && event.httpMethod === "PUT") {
        try {
            const UserID = event.queryStringParameters.UserID;
            const Program = event.queryStringParameters.Program;
            const StartDate = event.queryStringParameters.StartDate;

            const params = {
                TableName: "user-programs-db-dev",
                Item: {
                    UserID: UserID,
                    Program: Program,
                    StartDate: StartDate
                }
            };

            const response = await dynamoDb.put(params).promise();

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(response)
            };
        } catch (error) {
            console.log(error);
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    } else if (event.path === "/getUserProgramInfo" && event.httpMethod === "GET") {
        const UserID = event.queryStringParameters.UserID;

        const params = {
            TableName: "user-programs-db-dev",
            KeyConditionExpression: "UserID = :userID",
            ExpressionAttributeValues: {
                ":userID": UserID
            }
        };

        try {
            const data = await dynamoDb.query(params).promise();

            if (data.Items.length > 0) {
                return {
                    statusCode: 200,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify(data.Items[0])
                };
            } else {
                return {
                    statusCode: 404,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify({ message: "No Program found for the given UserID" })
                };
            }
        } catch (error) {
            console.log(error);
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    } else if (event.triggerSource === "PostConfirmation_ConfirmSignUp" && event.userName != null) {
        console.log("here");
        console.log("username: " + event.userName);
        const UserID = event.userName;

        const badgeParams = {
            TableName: "user-badge-info-db-dev",
            Item: {
                UserID: UserID,
                BadgesEarned: [],
                Weeks: 0
            }
        };
        try {
            await dynamoDb.put(badgeParams).promise();
            console.log("success");
        } catch (error) {
            console.log(error);
        }

        const xpParams = {
            TableName: "user-xp-info-db-dev",
            Item: {
                UserID: UserID,
                Level: 1,
                XP: 0,
                XPNeeded: 50,
                Sublevels: {
                    "Lower Body Compound": {
                        Level: 1,
                        XP: 0,
                        XPNeeded: 25
                    },
                    "Lower Body Isolation": {
                        Level: 1,
                        XP: 0,
                        XPNeeded: 25
                    },
                    "Upper Body Compound": {
                        Level: 1,
                        XP: 0,
                        XPNeeded: 25
                    },
                    "Upper Body Isolation": {
                        Level: 1,
                        XP: 0,
                        XPNeeded: 25
                    }
                }
            }
        };
        try {
            await dynamoDb.put(xpParams).promise();
            console.log("success");
        } catch (error) {
            console.log(error);
        }

        return event;

    } else if (event.path === "/getUserBadgeInfo" && event.httpMethod === "GET") {
        const UserID = event.queryStringParameters.UserID;

        console.log(`UserID: ${UserID}`);

        const params = {
            TableName: "user-badge-info-db-dev",
            Key: {
                UserID: UserID
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
    } else if (event.path === "/modifyUserBadgeInfo" && event.httpMethod === "PUT") {
        const body = JSON.parse(event.body);
        console.log("Weeks: " + body.Weeks);

        let updateParts = [];

        if (body.Weeks) {
            console.log("Weeks");
            updateParts.push("Weeks = if_not_exists(Weeks, :numberDefault) + :increment");
        }

        updateParts.push("BadgesEarned = list_append(if_not_exists(BadgesEarned, :badgeDefault), :badges)");

        let updateExpression = "SET " + updateParts.join(", ");
        console.log(updateExpression);

        const params = {
            TableName: "user-badge-info-db-dev",
            Key: {
                UserID: body.UserID
            },
            UpdateExpression: updateExpression,
            ExpressionAttributeValues: {
                ":numberDefault": 0,
                ":increment": 1,
                ":badgeDefault": [],
                ":badges": body.Badges
            }
        };

        try {
            const data = await dynamoDb.update(params).promise();
            console.log("updated");
            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify("Successfully Updated! " + data)
            };
        } catch (error) {
            console.log(error);
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }

    } else if (event.path === "/getBadges" && event.httpMethod === "GET") {
        const params = {
            TableName: "badges-db-dev"
        };

        console.log("heres");

        try {
            const data = await dynamoDb.scan(params).promise();

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(data.Items)
            };
        } catch (error) {
            console.log(error);
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                }
            };

        }
    } else if (event.path === "/getUserXP" && event.httpMethod === "GET") {
        const UserID = event.queryStringParameters.UserID;

        const params = {
            TableName: "user-xp-info-db-dev",
            Key: {
                UserID: UserID
            }
        };

        try {
            const response = await dynamoDb.get(params).promise();

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(response)
            };
        } catch (error) {
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    } else if (event.path === "/updateUserXP" && event.httpMethod === "PUT") {
        const body = JSON.parse(event.body)
        const UserID = body.UserID
        const Level = body.Level;
        const Sublevels = body.Sublevels;
        const XP = body.XP;
        const XPNeeded = body.XPNeeded;
    
        const params = {
            TableName: "user-xp-info-db-dev",
            Key: {
                UserID: UserID
            },
            UpdateExpression: "set #lvl = :lvl, #sub = :sub, #xp = :xp, #xpNeeded = :xpNeeded",
            ExpressionAttributeNames: {
                "#lvl": "Level",
                "#sub": "Sublevels",
                "#xp": "XP",
                "#xpNeeded": "XPNeeded"
            },
            ExpressionAttributeValues: {
                ":lvl": Level,
                ":sub": Sublevels,
                ":xp": XP,
                ":xpNeeded": XPNeeded
            }
        }

        try {
            await dynamoDb.update(params).promise()

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify("Successfully added XP")
            };

        } catch (error) {
            console.log(error)

            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    } else if (event.path == "/leaveProgram" && event.httpMethod == "DELETE") {
        const UserID = event.queryStringParameters.UserID;
        const ProgramName = event.queryStringParameters.ProgramName;

        const params = {
            TableName: "user-programs-db-dev",
            Key: {
                UserID: UserID,
                Program: ProgramName
            }
        };

        try {
            const response = await dynamoDb.delete(params).promise();

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify("Successfully Left Program")
            };

        } catch (error) {
            console.log(error);
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    } else if (event.path === "/getChallengeTemplates" && event.httpMethod === "GET") {
        const params = {
            TableName: "challenge-templates-db-dev"
        }

        try {
            const challengeTemplates = await dynamoDb.scan(params).promise()

            if (challengeTemplates.Items.length > 0) {
                return {
                    statusCode: 200,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify(challengeTemplates.Items)
                };
            } else {
                return {
                    statusCode: 404,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify("No Challenge Templates Found")
                };
            }
        } catch (error) {
            console.log(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(`${error}`)
            };
        }
    } else if (event.path == "/getActiveUserChallenges" && event.httpMethod == "GET") {
        const UserID = event.queryStringParameters.UserID

        const params = {
            TableName: "user-challenges-db-dev",
            KeyConditionExpression: "#userID = :userID",
            FilterExpression: "#isActive = :isActive",
            ExpressionAttributeValues: {
                ":userID": UserID,
                ":isActive": true
            },
            ExpressionAttributeNames: {
                "#userID": "UserID",
                "#isActive": "IsActive"
            }
        };

        try {
            const userChallenges = await dynamoDb.query(params).promise()

            if (userChallenges.Items.length > 0) {
                return {
                    statusCode: 200,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify(userChallenges.Items)
                };
            } else {
                return {
                    statusCode: 404,
                    headers: {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*"
                    },
                    body: JSON.stringify("No Challenge Templates Found")
                };
            }
        } catch (error) {
            console.log(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(`${error}`)
            };
        }
    }
    else if (event.path == "/updateChallenge" && event.httpMethod == "PUT") {
        const body = JSON.parse(event.body)
        const UserID = body.UserID
        const ID = body.ID
        const Name = body.Name
        const ChallengeTemplateID =  body.ChallengeTemplateID
        const StartDate = body.StartDate
        const EndDate = body.EndDate
        const StartValue = body.StartValue
        const TargetValue = body.TargetValue
        const Field = body.Field
        const IsFailed = body.IsFailed
        const IsActive = body.IsActive

        const params = {
            TableName: "user-challenges-db-dev",
            Key: {
                UserID: UserID
            },
            UpdateExpression: "set #id = :id, #challengeTemplateID = :challengeTemplateID, #name = :name, #startDate = :startDate, #endDate = :endDate, #startValue = :startValue, #targetValue = :targetValue, #field = :field, #isFailed = :isFailed, #isActive = :isActive",
            ExpressionAttributeNames: {
                "#id": "ID",
                "#challengeTemplateID": "ChallengeTemplateID",
                "#name": "Name",
                "#startDate": "StartDate",
                "#endDate": "EndDate",
                "#startValue": "StartValue",
                "#targetValue": "TargetValue",
                "#field": "Field",
                "#isFailed": "IsFailed",
                "#isActive": "IsActive"
            },
            ExpressionAttributeValues: {
                ":id": ID,
                ":challengeTemplateID": ChallengeTemplateID,
                ":name": Name,
                ":startDate": StartDate,
                ":endDate": EndDate,
                ":startValue": StartValue,
                ":targetValue": TargetValue,
                ":field": Field,
                ":isFailed": IsFailed,
                ":isActive": IsActive
            }
        }

        try {
            await dynamoDb.update(params).promise()

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify("Successfully started Challenge")
            };
        } catch (error) {
            console.log(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(`${error}`)
            };
        }
    } else if (event.path == "/challengesCompleted" && event.httpMethod == "DELETE") {
        const UserID = event.queryStringParameters.UserID
        const CompletedChallenges = JSON.parse(event.queryStringParameters.CompletedChallenges)

        for (challenge of CompletedChallenges) {
            const params = {
                TableName: "user-challenges-db-dev",
                Key: UserID,
                ConditionExpression: "#challengeID = :challengeID AND #isActive = :isActive",
                ExpressionAttributeNames: {
                    "#challengeID": "ChallengeID",
                    "#isActive": "IsActive"
                },
                ExpressionAttributeValues: {
                    "challengeID": challenge,
                    ":isActive": true
                }
            }

            try {
                const response = await dynamoDb.delete(params).promise();
            } catch (error) {
                console.log(error)
                continue
            }
        }

        return {
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*"
            },
            body: JSON.stringify("Successfully Completed Challenges")
        };
        
    }
    else if (event.path == "/addWeightEntry" && event.httpMethod == "PUT") {
        const UserID = event.queryStringParameters.UserID
        const Weight = event.queryStringParameters.Weight

        const Timestamp = DateTime.utc().toISOString();
        try {
            const params = {
                TableName: "weight-trend-db-dev",
                Item: {
                    "UserID": UserID,
                    "Timestamp": Timestamp,
                    "Weight": Weight
                }
            }

            const response = await dynamoDb.put(params).promise()

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(`Successfully Added Weight ${response}`)
            };
        } catch (error) {
            console.log(error)
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(`${error}`)
            };
        }
    }
    else if (event.path == "/getUserWeightTrend" && event.httpMethod == "GET") {
        const UserID = event.queryStringParameters.UserID
        const Days = event.queryStringParameters.Days

        const currentDate = new Date();
        const startDate = new Date(currentDate);
        startDate.setDate(currentDate.getDate() - Days);

        const startDateString = startDate.toISOString();
        const endDateString = currentDate.toISOString();

        try {
            const params = {
                TableName: 'WeightTrends', 
                KeyConditionExpression: '#userID = :userID AND #timestamp BETWEEN :start AND :end',
                ExpressionAttributeNames: {
                    '#userID': 'UserID',
                    '#timestamp': 'Timestamp'
                },
                ExpressionAttributeValues: {
                    ':userID': UserID,
                    ':start': startDateString,
                    ':end': endDateString
                }
            };
    
            const result = await dynamoDb.query(params).promise();

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(result.Items)
            };
        } catch (error) {

        }
    }

    return {
        statusCode: 200,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*"
        },
        body: JSON.stringify('Hello from Lambda!')
    };
};
