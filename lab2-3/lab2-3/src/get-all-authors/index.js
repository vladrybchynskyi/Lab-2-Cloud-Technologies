const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const dynamodb = new DynamoDB({});
exports.handler = async (event) => {
  const data = await dynamodb.scan({ TableName: process.env.AUTHORS_TABLE });
  return data.Items.map(item => ({ id: item.id.S, firstName: item.firstName.S, lastName: item.lastName.S }));
};
