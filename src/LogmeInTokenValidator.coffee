# Using OAuth 2.0 for Client-side Applications
# ============================================
#
# The Gipsy-Danger OAuth 2.0 endpoint supports JavaScript-centric
# applications. 
#
# These applications may access the resource owner's data while 
# the user is present by obtaining explicit authorization from it.
#
# One important characteristic of these applications is that they
# cannot keep a secret, which means that the client secret cannot
# be used to stablish the authentication.
#
# This library provides acess to the authentication server so that
# clients like these can make use of the authentication system. It 
# does so by implementing the OAuth 2.0 *[implicit grant](http://tools.ietf.org/html/rfc6749#section-4.2)*
# authentication model.
#
# > *Note:* The implicit grant model involves that the client should provide a callback endpoint on their web infrastructure as explained below.
#
# Here's an illustration of how the whole authorization process
# works using the implicit grant model:
#
# ```html
# +----------+
# | Resource |
# |  Owner   |
# |          | 
# +----------+
#      ^
#      |
#     (B)
# +----|-----+          Client Identifier     +---------------+
# |         -+----(A)-- & Redirection URI --->|               |
# |  User-   |                                | Authorization |
# |  Agent  -|----(B)-- User authenticates -->|     Server    |
# |          |                                |               |
# |          |<---(C)--- Redirection URI ----<|               |
# |          |          with Access Token     +---------------+
# |          |            in Fragment
# |          |                                +---------------+
# |          |----(D)--- Redirection URI ---->|   Web-Hosted  |
# |          |          without Fragment      |     Client    |
# |          |                                |    Resource   |
# |     (F)  |<---(E)------- Script ---------<|               |
# |          |                                +---------------+
# +-|--------+
#   |    |
#  (A)  (G) Access Token
#   |    |
#   ^    v
# +---------+
# |         |
# |  Client |
# |         |
# +---------+
# ```
#
https = require('https')

# The Client class  
# ----------------
#
# The Client class is the entry point to the authentication
# library.
# It provides with all the necessary functionality to perform 
# the authentication, token validation and access to the resource
# owner's data.
#
class LogmeInTokenValidator
 
  # `DEFAULT_HOST` specifies the default host used by the 
  # client as authentication server if no `host` configuration
  # is specified during the library initialization. By default,
  # the host points to the Gipsy-Danger API web server.
  #
  DEFAULT_HOST : 'api.actisec.com'

  # `DEFAULT_PORT` specifies the default TCP port in the 
  # authentication server used by the client if no `port` configuration
  # is specified during the library initialization.
  #
  DEFAULT_PORT : 443

  # `DEFAULT_API` specifies the default API version used 
  # to interface with the server if no `apiVersion` configuration
  # is specified during the library initialization.
  #
  DEFAULT_API  : "v1"

  # Initializing the client library
  # ----------------------------------------------------
  # 
  # To initialize the library you need to call the constructor,
  # method, which takes as input a configuration object that
  # can contain zero or more of the following fields:
  #
  # |Name|Value|Description|
  # |----|-----|-----------|
  # |`host`|`String`|Authentication server to which the client will connect. Should *NOT* include the URL schema as it should always be `https`. Defaults to `DEFAULT_HOST`.|
  # |`port`|TCP port number|TCP port from the host to which the client will connect. Defaults to `DEFAULT_PORT`|
  # |`apiVersion`|`String`|Identifies the version of the API used. Defaults to `DEFAULT_API`|
  # 
  # Example of initialization from a JavaScript client:
  #
  # ```javascript
  # var client = LogmeInClientAuth();
  # ```
  #
  # For clients with nosting their own authorization infrastructure, a custom
  # settings may be also provided:
  #
  # ```javascript
  # var client = LogmeInClientAuth({ host: "example.com", port: 8000});
  # ```
  #
  # A new client instance is returned that can be used to
  # perform the authentication and acess protected resources.
  #
  constructor: (config) ->
      { @host, @port, @apiVersion } = config if config?
      @host       ?= @DEFAULT_HOST
      @port       ?= @DEFAULT_PORT
      @apiVersion ?= @DEFAULT_API
    

  # Accessing the settings
  # ----------------------------------------------------

  # By calling `getHost()` the caller can retrieve the 
  # configured `host` used by the library
  #
  # ```javascript
  # var host = client.getHost();
  # ```
  #
  getHost: () ->
    return @host

  # By calling `getPort()` the caller can retrieve the 
  # configured `host` used by the library
  #
  # ```javascript
  # var port = client.getPort();
  # ```
  #
  getPort: () ->
    return @port

  # By calling `getApiVersion()` the caller can retrieve the 
  # configured `apiVersion` used by the library
  #
  # ```javascript
  # var api = client.getApiVersion();
  # ```
  #
  getApiVersion: () ->
    return @apiVersion

  _getResourcePath: (resource) ->
    return '/' + @getApiVersion() + '/oauth2/' + resource 

  # Validating your acess token
  # ----------------------------------------------------
  #
  # Upon sucessfull access granted by the resource owner, an 
  # access token will be sent to the client's web server endpont
  # via the `redirect_uri` callback.
  #
  # All tokens *MUST* be explicitly validated. Failuer to verify
  # tokens acquired this way makes your application more vulnerable
  # to the [confused deputy problem](http://en.wikipedia.org/wiki/Confused_deputy_problem)
  #
  # In order to validate a token, the server should instantiate
  # the library as seen above, and invoke the `validateToken()` 
  # method to perform the validation agains the authentication server
  # as follows:
  #
  # ```javascript
  # client.validateToken(myAcessToken, 
  #    function(request) {
  #       alert("Token is valid :)");
  #    },
  #    function(request) {
  #       alert("Token is NOT valid");
  #    },
  #    function(request) {
  #       alert("An error occurred");
  #    }
  #);
  # ```
  #
  validateToken: (accessToken, onValidToken, onInvalidToken, onError) ->
    
    options = { 

        host: @getHost(),
        port: @getPort() 
        path: @_getResourcePath('validatetoken'),
        access_token: accessToken
    }

    https.get(options,
      (response) =>
          response.on 'data', (chunk) =>
            switch response.statusCode
              when 200 then onValidToken(response) if onValidToken?
              when 498 then onInvalidToken(response) if onInvalidToken?
              else onError(new Error("Unexpected response staus code " + response.statusCode)) if onError?
    ).on('error', (e) ->
      onError(e) if onError?
    ).end()
      
exports.LogmeInTokenValidator = LogmeInTokenValidator

module.exports = (config) -> 
     return new LogmeInTokenValidator(config)
