var http = require('http');
var fs = require('fs');

http.createServer(function (req, res) {
  console.log(req.url);
  var path = 'public' + req.url;
  if (!fs.existsSync(path) || !fs.lstatSync(path).isFile()) {
    path = 'public/index.html';
  }
  if (path.endsWith('.html')) {
    res.writeHeader(200, { 'Content-Type': 'text/html' });
  } else if (path.endsWith('.js')) {
    res.writeHeader(200, { 'Content-Type': 'text/javascript' });
  } else if (path.endsWith('.png')) {
    res.writeHeader(200, { 'Content-Type': 'image/png' });
  }
  res.end(fs.readFileSync(path));
}).listen(8000);
