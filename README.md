# HoshiLe’s Store SPA Client in Elm

`hoshile-elm` is an Elm port of the store client portion of HoshiLe’s Store.

The API server written in Go is at [https://github.com/takapro/hoshile-api](https://github.com/takapro/hoshile-api).

## About HoshiLe’s Store

HoshiLe’s Store is a classroom project written by [Ngoc Tin Le](https://github.com/takint) and [Takanori Hoshi](https://github.com/takapro).
Original was written in PHP and composed of a Rest API server, store front and admin clients.

## How to run

Build the `public/app.js` with `elm make` command (or just `make` may work).

```
$ elm make src/App.elm --output public/app.js
```

The single page application requires a web server to run.

```
$ node server.js
```

Customize the config in `public/index.html`.

```html
  <head>
    <base href="/path/to/hoshile-elm/">   <!-- change the base path here -->
    ...
    <title>The Awesome Store</title>      <!-- change the site name here -->
    ...
  </head>
  <body>
    ...
    <script>
      var config = {
        siteName: document.title,
        basePath: new URL(document.baseURI).pathname,
        apiBase: "http://localhost:3000/" // change the API server URL here
      };
      Elm.App.init({ flags: config });
    </script>
  </body>
```
