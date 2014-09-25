LogmeIn OAuth2.0 token validation Node.js module
=====================

This project contains a Node.js module that can be used by LogmeIn clients to validate the `access_token` upon a resource owner's confirmation for granting access to its resources or a set of them.

In order to use this module add it to your dependencies:

```bash
$ npm install logmein-client-validation --save
```

Inside your application code, import the token validator from the module:

```javascript
var validator = require('logmein-client-validation').TokenValidator();
```

>If your client is using its own infrastructure, `host`, `port` and `apiVersion` can be passed to the validator as a configuration object.

Example of `access_token` validation:

```javascript
validator.validateToken(request.query.access_token,
    function(request) {
        // Just return a success code to the client
        response.writeHead(200);
        response.end();
    },
    function(request) {
        // Return a token expired/invalid error
        response.writeHead(498);
        response.end();
    }
);  
```
A working example of token validation using this module can be found at [logmein-client-app-sample](https://github.com/activems/logmein-client-app-sample).


