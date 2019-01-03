var bunyan = require('bunyan');
module.exports.init = function() {
 var log = bunyan.createLogger({
   name: "bunyan-logger-plugin",
   streams: [
     {
       level: 'error',
       stream: process.stdout
     },
     {
       level: 'info',
       path: '/var/tmp/edgemicrogateway-bunyan-info.log'
     }
   ]
 });
 return {
   onrequest: function(req, res, next) {
     log.info('ONREQUEST');
     next();
   },
   onend_request: function(req, res, data, next) {
     log.info("ONEND_REQUEST");
     next(null, data);
   },
   ondata_response: function(req, res, data, next) {
     log.info("ONDATA_RESPONSE");
     next(null, data);
   },
   onend_response: function(req, res, data, next) {
     log.info("ONEND_RESPONSE");

     log.info("ONDATA_DATA");
     log.info(JSON.stringify(data));
     log.info(data.toString('utf8'));
     next(null, data);
   }
 };
}
