LogmeIn web client backend Node.js module
=======
LogmeIn OAuth 2.0 endpoint supports JavaScript-centric application. 
These applications may access the resource owner's data while the user is present by obtaining explicit authorization from it by using the *OAuth2 implicit grant model* from [RFC 6749](http://tools.ietf.org/html/rfc6749#section-4.2).

One important characteristic of these applications is that the cannot keep a secret, which means that the client secret cannot be used to stablish the authentication.

In order to cirnunvent this issue, the implicit grant model involves that the client should provide a callback endpoint on their web infrastructure.

This libray provides with the functionality for performing `access_token` validation from your web app backend as well as for retrieving resources from the authorization server.

Import and initialize the module
------

In order to use this module add it to your dependencies:

```bash
$ npm install logmein-client-validation --save
```

Inside your application code, import the token validator from the module:

```javascript
var logmein = require('logmein-client-validation'),
    client = logmein();
```

>If your client is using its own infrastructure, `host`, `port` and `apiVersion` can be passed to the `logmein` constructor as a configuration object.

Access token validation:
------

One important thing to take into account is that the client should always validate the `access_token` once retrieved from the authorization server. Failure to do so makes your application more vulnerable to the [confused deputy problem](http://en.wikipedia.org/wiki/Confused_deputy_problem).

This module provides with the `validateToken` method that can be used as follows:

```javascript
client.validateToken(access_token,
            function(r) {
               // Save the access token in the session
               session.access_token = access_token;
               response.writeHead(200);
               response.end();
            },
            function(r) {
              // Return a token expired/invalid error
              response.writeHead(498);
              response.end();
            },
            function(e) {
              // An error happened
              response.writeHead(500);
              response.end(e);
            }
        );   
```

Accessing resource owner's data
------------

Once the client has been granted access to the resource owner's resources and the token has been validated, it can access it by means of the `getResource()` method.

As a way of example, here's the JavaScript code in the browser to access the resource owner's profile data:

```javascript
client.getResource(session.access_token, "/profile", undefined,
    function(r) {
        r.on('data', function(chunk) {
            profile = JSON.parse(chunk);
    },
    function(e) {
       // An error happened
    }
);

