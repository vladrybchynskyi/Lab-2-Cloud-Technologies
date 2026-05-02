exports.handler = async (event) => { console.log("Lambda works! Table:", process.env.TABLE_NAME); return { statusCode: 200, body: "Hello from Lambda!" }; };
