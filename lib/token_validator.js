(function() {
  var TokenValidator, http;

  http = require('http');

  TokenValidator = (function() {
    TokenValidator.DEFAULT_HOST = 'https://api.actisec.com';

    TokenValidator.DEFAULT_PORT = 80;

    TokenValidator.DEFAULT_API = "v1";

    function TokenValidator(config) {
      this.config = config;
    }

    TokenValidator.prototype.getHost = function() {
      if ((this.config != null) && (this.config.host != null)) {
        return this.config.host;
      } else {
        return this.DEFAULT_HOST;
      }
    };

    TokenValidator.prototype.getPort = function() {
      if ((this.config != null) && (this.config.port != null)) {
        return this.config.port;
      } else {
        return this.DEFAULT_PORT;
      }
    };

    TokenValidator.prototype.getApiVersion = function() {
      if ((this.config != null) && (this.config.apiVersion != null)) {
        return this.config.apiVersion;
      } else {
        return this.DEFAULT_API;
      }
    };

    TokenValidator.prototype._getResourcePath = function(resource) {
      return '/' + this.getApiVersion() + '/oauth2/' + resource;
    };

    TokenValidator.prototype.validateToken = function(accessToken, onValidToken, onInvalidToken, onError) {
      var options;
      options = {
        host: this.getHost(),
        port: this.getPort(),
        path: this._getResourcePath('validatetoken'),
        access_token: accessToken
      };
      console.log(this.getHost() + this._getResourcePath('validatetoken'));
      return http.request(options, (function(_this) {
        return function(response) {
          if (typeof onSuccess !== "undefined" && onSuccess !== null) {
            return response.on('data', function(chunk) {
              switch (response.statusCode) {
                case 200:
                  if (onValidToken != null) {
                    return onValidToken(response);
                  }
                  break;
                case 498:
                  if (onInvalidToken != null) {
                    return onInvalidToken(response);
                  }
                  break;
                default:
                  if (onError != null) {
                    return onError(new Error("Unexpected response staus code " + response.statusCode));
                  }
              }
            });
          }
        };
      })(this)).on('error', function(e) {
        if (onError != null) {
          return onError(e);
        }
      }).end();
    };

    return TokenValidator;

  })();

  exports.TokenValidator = TokenValidator;

  module.exports = function(config) {
    return new TokenValidator(config);
  };

}).call(this);
