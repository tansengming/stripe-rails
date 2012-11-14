(function() {
  var _this = this;

  this.Stripe = (function() {

    function Stripe() {}

    Stripe.version = 2;

    Stripe.endpoint = 'https://api.stripe.com/v1';

    Stripe.validateCardNumber = function(num) {
      num = (num + '').replace(/\s+|-/g, '');
      return num.length >= 10 && num.length <= 16 && Stripe.luhnCheck(num);
    };

    Stripe.validateCVC = function(num) {
      num = Stripe.trim(num);
      return /^\d+$/.test(num) && num.length >= 3 && num.length <= 4;
    };

    Stripe.validateExpiry = function(month, year) {
      var currentTime, expiry;
      month = Stripe.trim(month);
      year = Stripe.trim(year);
      if (!/^\d+$/.test(month)) {
        return false;
      }
      if (!/^\d+$/.test(year)) {
        return false;
      }
      if (!(parseInt(month, 10) <= 12)) {
        return false;
      }
      expiry = new Date(year, month);
      currentTime = new Date;
      expiry.setMonth(expiry.getMonth() - 1);
      expiry.setMonth(expiry.getMonth() + 1, 1);
      return expiry > currentTime;
    };

    Stripe.cardType = function(num) {
      return Stripe.cardTypes[num.slice(0, 2)] || 'Unknown';
    };

    Stripe.setPublishableKey = function(key) {
      Stripe.key = key;
    };

    Stripe.createToken = function(card, params, callback) {
      var amount, key, value;
      if (params == null) {
        params = {};
      }
      if (!card) {
        throw 'card required';
      }
      if (typeof card !== 'object') {
        throw 'card invalid';
      }
      if (typeof params === 'function') {
        callback = params;
        params = {};
      } else if (typeof params !== 'object') {
        amount = parseInt(params, 10);
        params = {};
        if (amount > 0) {
          params.amount = amount;
        }
      }
      for (key in card) {
        value = card[key];
        delete card[key];
        card[Stripe.underscore(key)] = value;
      }
      params.card = card;
      params.key || (params.key = Stripe.key || Stripe.publishableKey);
      Stripe.validateKey(params.key);
      return Stripe.ajaxJSONP({
        url: "" + Stripe.endpoint + "/tokens",
        data: params,
        method: 'POST',
        success: function(body, status) {
          return typeof callback === "function" ? callback(status, body) : void 0;
        },
        complete: Stripe.complete(callback),
        timeout: 40000
      });
    };

    Stripe.getToken = function(token, callback) {
      if (!token) {
        throw 'token required';
      }
      Stripe.validateKey(Stripe.key);
      return Stripe.ajaxJSONP({
        url: "" + Stripe.endpoint + "/tokens/" + token,
        data: {
          key: Stripe.key
        },
        success: function(body, status) {
          return typeof callback === "function" ? callback(status, body) : void 0;
        },
        complete: Stripe.complete(callback),
        timeout: 40000
      });
    };

    Stripe.complete = function(callback) {
      return function(type, xhr, options) {
        if (type !== 'success') {
          return typeof callback === "function" ? callback(500, {
            error: {
              code: type,
              type: type,
              message: 'An unexpected error has occured.\nWe have been notified of the problem.'
            }
          }) : void 0;
        }
      };
    };

    Stripe.validateKey = function(key) {
      if (!key || typeof key !== 'string') {
        throw new Error('You did not set a valid publishable key.\nCall Stripe.setPublishableKey() with your publishable key.\nFor more info, see https://stripe.com/docs/stripe.js');
      }
      if (/^sk_/.test(key)) {
        throw new Error('You are using a secret key with Stripe.js, instead of the publishable one.\nFor more info, see https://stripe.com/docs/stripe.js');
      }
    };

    return Stripe;

  }).call(this);

  if (typeof module !== "undefined" && module !== null) {
    module.exports = this.Stripe;
  }

  if (typeof define === "function") {
    define('stripe', [], function() {
      return _this.Stripe;
    });
  }

}).call(this);
(function() {
  var e, requestID, serialize,
    __slice = [].slice;

  e = encodeURIComponent;

  requestID = new Date().getTime();

  serialize = function(object, result, scope) {
    var key, value;
    if (result == null) {
      result = [];
    }
    for (key in object) {
      value = object[key];
      if (scope) {
        key = "" + scope + "[" + key + "]";
      }
      if (typeof value === 'object') {
        serialize(value, result, key);
      } else {
        result.push("" + key + "=" + (e(value)));
      }
    }
    return result.join('&').replace(/%20/g, '+');
  };

  this.Stripe.ajaxJSONP = function(options) {
    var abort, abortTimeout, callbackName, head, script, xhr;
    if (options == null) {
      options = {};
    }
    callbackName = 'sjsonp' + (++requestID);
    script = document.createElement('script');
    abortTimeout = null;
    abort = function() {
      var _ref;
      if ((_ref = script.parentNode) != null) {
        _ref.removeChild(script);
      }
      if (callbackName in window) {
        window[callbackName] = (function() {});
      }
      return typeof options.complete === "function" ? options.complete('abort', xhr, options) : void 0;
    };
    xhr = {
      abort: abort
    };
    script.onerror = function() {
      xhr.abort();
      return typeof options.error === "function" ? options.error(xhr, options) : void 0;
    };
    window[callbackName] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      clearTimeout(abortTimeout);
      script.parentNode.removeChild(script);
      try {
        delete window[callbackName];
      } catch (e) {
        window[callbackName] = void 0;
      }
      if (typeof options.success === "function") {
        options.success.apply(options, args);
      }
      return typeof options.complete === "function" ? options.complete('success', xhr, options) : void 0;
    };
    options.data || (options.data = {});
    options.data.callback = callbackName;
    if (options.method) {
      options.data._method = options.method;
    }
    script.src = options.url + '?' + serialize(options.data);
    head = document.getElementsByTagName('head')[0];
    head.appendChild(script);
    if (options.timeout > 0) {
      abortTimeout = setTimeout(function() {
        xhr.abort();
        return typeof options.complete === "function" ? options.complete('timeout', xhr, options) : void 0;
      }, options.timeout);
    }
    return xhr;
  };

}).call(this);
(function() {

  this.Stripe.trim = function(str) {
    return (str + '').replace(/^\s+|\s+$/g, '');
  };

  this.Stripe.underscore = function(str) {
    return (str + '').replace(/([A-Z])/g, function($1) {
      return "_" + ($1.toLowerCase());
    });
  };

  this.Stripe.luhnCheck = function(num) {
    var digit, digits, odd, sum, _i, _len;
    odd = true;
    sum = 0;
    digits = (num + '').split('').reverse();
    for (_i = 0, _len = digits.length; _i < _len; _i++) {
      digit = digits[_i];
      digit = parseInt(digit, 10);
      if ((odd = !odd)) {
        digit *= 2;
      }
      if (digit > 9) {
        digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 === 0;
  };

  this.Stripe.cardTypes = (function() {
    var num, types, _i, _j;
    types = {};
    for (num = _i = 40; _i <= 49; num = ++_i) {
      types[num] = 'Visa';
    }
    for (num = _j = 50; _j <= 59; num = ++_j) {
      types[num] = 'MasterCard';
    }
    types[34] = types[37] = 'American Express';
    types[60] = types[62] = types[64] = types[65] = 'Discover';
    types[35] = 'JCB';
    types[30] = types[36] = types[38] = types[39] = 'Diners Club';
    return types;
  })();

}).call(this);