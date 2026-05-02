const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const dynamodb = new DynamoDB({});
exports.handler = async (event) => {
  const data = await dynamodb.scan({ TableName: process.env.COURSES_TABLE });
  return data.Items.map(item => ({ id: item.id.S, title: item.title.S, watchHref: item.watchHref.S, authorId: item.authorId.S, length: item.length.S, category: item.category.S }));
};
