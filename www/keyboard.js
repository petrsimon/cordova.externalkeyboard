
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var pluginName = 'ExternalKeyboard';

var ExternalKeyboard = function() {
};

ExternalKeyboard.setKeyCommands = function(commands, delimiter){
    var deferred = $.Deferred();
    exec(
        function (result) {
            deferred.resolve(result);
        },
        function (error) {
            deferred.reject(error);
        },
        pluginName, "setKeyCommands", [commands, delimiter]);
    return deferred.promise();
}


module.exports = ExternalKeyboard;
