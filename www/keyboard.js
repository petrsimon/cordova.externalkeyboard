var exec = require('cordova/exec');

var pluginName = 'ExternalKeyboard';

var ExternalKeyboard = function() {
};

ExternalKeyboard.redraw = function(){
    var deferred = $.Deferred();
    exec(
        function (result) {
            deferred.resolve(result);
        },
        function (error) {
            deferred.reject(error);
        },
        pluginName, "redraw", []);
    return deferred.promise();
}


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
