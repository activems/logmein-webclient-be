(function() {
  var LogmeInTokenValidator, http;

  http = require('http');

  LogmeInTokenValidator = (function() {
    LogmeInTokenValidator.prototype.DEFAULT_HOST = 'api.actisec.com';

    LogmeInTokenValidator.prototype.DEFAULT_PORT = 443;

    LogmeInTokenValidator.prototype.DEFAULT_API = "v1";

    function LogmeInTokenValidator(config) {
      if (config != null) {
        this.host = config.host, this.port = config.port, this.apiVersion = config.apiVersion;
      }
      if (this.host == null) {
        this.host = this.DEFAULT_HOST;
      }
      if (this.port == null) {
        this.port = this.DEFAULT_PORT;
      }
      if (this.apiVersion == null) {
        this.apiVersion = this.DEFAULT_API;
      }
    }

    LogmeInTokenValidator.prototype.getHost = function() {
      return this.host;
    };

    LogmeInTokenValidator.prototype.getPort = function() {
      return this.port;
    };

    LogmeInTokenValidator.prototype.getApiVersion = function() {
      return this.apiVersion;
    };

    return LogmeInTokenValidator;

  })();

  ({
    _getResourcePath: function(resource) {
      return '/' + this.getApiVersion() + '/oauth2/' + resource;
    },
    validateToken: function(accessToken, onValidToken, onInvalidToken, onError) {
      var options;
      options = {
        host: this.getHost(),
        port: this.getPort(),
        path: this._getResourcePath('validatetoken'),
        access_token: accessToken
      };
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
    }
  });

  exports.LogmeInTokenValidator = LogmeInTokenValidator;

  module.exports = function(config) {
    return new LogmeInTokenValidator(config);
  };

}).call(this);