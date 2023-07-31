var fs = require('fs');
/**
 * Protect your license information.
 * In your license information, encrypt your license information and add domain name restrictions.
 * Make your license more secure.
 * Make your license only accessible under restricted domain names
 */
/**
 * A class that encrypts passwords
 * @param locateDirPath You can access the folder path to gsdk.js.
 * @constructor
 */
function LicenseProtect (locateDirPath) {
    var wasmModule = require(locateDirPath + 'gsdk.js');
    var wasmReadyDeferred = createDeferred();
    var wasmReadyPromies = wasmReadyDeferred.promise;

    var Module = wasmModule({
        onRuntimeInitialized: function () {
            // gsdk.js initialization is complete
            wasmReadyDeferred.resolve();
        },
        onAbort: function () {
            // gsdk.js initialization is fail
            wasmReadyDeferred.reject();
        },
        locateFile: function (filename) {
            // The main thing is access to gsdk.wasm
            return locateDirPath + filename;
        },
        // Print log
        print:function(){}
    });
    if (Module instanceof Promise) {
        Module.then(function () {
            wasmReadyDeferred.resolve();
        }, function () {
            wasmReadyDeferred.reject(Module);
        });
    }

    /**
     * Encrypt the password
     * @param sn {String} license sn
     * @param key {String} license key
     * @param protect {Object} Some necessary parameters for license protection.
     * @param protect.hosts {Array<String|RegExp>} hosts  The whitelist of the domain name will be resolved into a regular match
     * @param protect.begin {Number} The time stamp at the beginning of the validity period
     * @param protect.end {Number} The time stamp at the end of the validity period
     * @returns {Promise.<String>} Encrypted password
     */
    this.encrypt = function (sn, key, protect) {
        return wasmReadyPromies.then(function () {
            protect = protect || {};
            let hosts = protect.hosts;
            if (hosts instanceof Array) {
                var host;
                for (var i = hosts.length; i--;) {
                    host = hosts[i];
                    if (host instanceof RegExp) {
                        hosts[i] = host.source;
                    }
                }
            }
            let _protect = {};
            let keys = {hosts:'h',begin:'b',end:'e'};
            for (let i in keys) {
                let value = protect[i];
                if (value) {
                    _protect[keys[i]] = value;
                }
            }
            return Module.then(gsdk=>{
                return gsdk.Library.EncryptLicense(sn, key, JSON.stringify(_protect)).toString()
            });
        });
    };
}

module.exports = LicenseProtect;

function createDeferred () {
    var deferred = {};
    var promise = new Promise(function (resolve, reject) {
        deferred.resolve = resolve;
        deferred.reject = reject;
    });
    deferred.promise = promise;
    return deferred;
}