const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const dynamodb = new DynamoDB({});
exports.handler = async (event) => {
  const params = { TableName: process.env.COURSES_TABLE, Item: { id: { S: event.id }, title: { S: event.title }, watchHref: { S: event.watchHref }, authorId: { S: event.authorId }, length: { S: event.length }, category: { S: event.category } } };
  await dynamodb.putItem(params);
  return { id: params.Item.id.S, title: params.Item.title.S, watchHref: params.Item.watchHref.S, authorId: params.Item.authorId.S, length: params.Item.length.S, category: params.Item.category.S };
};
