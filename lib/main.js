(function() {
  var LogmeInTokenValidator, https, _;

  https = require('https');

  _ = require('underscore');

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

    LogmeInTokenValidator.prototype._getResourcePath = function(resource) {
      return '/' + this.getApiVersion() + '/oauth2/' + resource;
    };

    LogmeInTokenValidator.prototype.validateToken = function(accessToken, onValidToken, onInvalidToken, onError) {
      var options;
      options = {
        host: this.getHost(),
        port: this.getPort(),
        path: this._getResourcePath('validatetoken'),
        access_token: accessToken
      };
      return https.get(options, (function(_this) {
        return function(response) {
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
        };
      })(this)).on('error', function(e) {
        if (onError != null) {
          return onError(e);
        }
      }).end();
    };

    LogmeInTokenValidator.prototype.getResource = function(accessToken, resourcePath, params, onSuccess, onError) {
      var options;
      if (accessToken == null) {
        throw 'Access token is undefined';
      }
      if (resourcePath == null) {
        throw 'Resource path is undefined';
      }
      options = {
        host: this.getHost(),
        port: this.getPort(),
        path: "/" + this.getApiVersion() + "/res" + resourcePath,
        acess_token: accessToken
      };
      if (params == null) {
        _.extend(options, {
          header: params
        });
      }
      console.log(options);
      return https.request(options, (function(_this) {
        return function(response) {
          if (onSuccess != null) {
            return response.on('data', function(chunk) {
              if (onSuccess != null) {
                return onSuccess(chunk);
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

    return LogmeInTokenValidator;

  })();

  exports.LogmeInTokenValidator = LogmeInTokenValidator;

  module.exports = function(config) {
    return new LogmeInTokenValidator(config);
  };

}).call(this);
