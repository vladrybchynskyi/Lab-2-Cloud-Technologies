const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const dynamodb = new DynamoDB({});
exports.handler = async (event) => {
  const data = await dynamodb.getItem({ TableName: process.env.COURSES_TABLE, Key: { id: { S: event.id } } });
  if (!data.Item) return {};
  return { id: data.Item.id.S, title: data.Item.title.S, watchHref: data.Item.watchHref.S, authorId: data.Item.authorId.S, length: data.Item.length.S, category: data.Item.category.S };
};
