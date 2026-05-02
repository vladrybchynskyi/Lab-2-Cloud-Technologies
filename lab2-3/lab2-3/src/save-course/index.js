const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const dynamodb = new DynamoDB({});
const replaceAll = (str, find, replace) => str.replace(new RegExp(find, "g"), replace);
exports.handler = async (event) => {
  const id = replaceAll(event.title, " ", "-").toLowerCase();
  const params = { TableName: process.env.COURSES_TABLE, Item: { id: { S: id }, title: { S: event.title }, watchHref: { S: `http://www.pluralsight.com/courses/${id}` }, authorId: { S: event.authorId }, length: { S: event.length }, category: { S: event.category } } };
  await dynamodb.putItem(params);
  return { id: params.Item.id.S, title: params.Item.title.S, watchHref: params.Item.watchHref.S, authorId: params.Item.authorId.S, length: params.Item.length.S, category: params.Item.category.S };
};
