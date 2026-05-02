const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const dynamodb = new DynamoDB({});
exports.handler = async (event) => {
  await dynamodb.deleteItem({ TableName: process.env.COURSES_TABLE, Key: { id: { S: event.id } } });
  return {};
};
