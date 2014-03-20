var express = require('express'),
    http = require('http'),
    fs = require('fs');

var app = express();

app.configure(function(){
  app.use(express.static(__dirname + '/public'));
});

var server = app.listen(3102, function() {
  console.log('Listening on port %d', server.address().port);
});






















