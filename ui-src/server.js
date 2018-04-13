var express = require('express');
var app = express();

app.get('/', function (req, res) {
  res.sendFile(__dirname+'/dist/index.html');
});

app.use('/_nuxt', express.static(__dirname + '/dist/_nuxt'));

app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});