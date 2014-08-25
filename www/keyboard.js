
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var ExternalKeyboard = function() {
};

ExternalKeyboard.init = function(commands){
    var deferred = $.Deferred();
    exec(
        function (result) {
            deferred.resolve(result);
        },
        function (error) {
            deferred.reject(error);
        },
        pluginName, "setKeyCommands", [commands]);
    return deferred.promise();
}


module.exports = ExternalKeyboard;
