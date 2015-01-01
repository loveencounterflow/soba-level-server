

# ( require 'app-module-path' ).addPath '/Volumes/Storage/cnd/node_modules'

############################################################################################################
njs_util                  = require 'util'
njs_path                  = require 'path'
njs_fs                    = require 'fs'
njs_http                  = require 'http'
#...........................................................................................................
BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'scratch'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
urge                      = TRM.get_logger 'urge',      badge
echo                      = TRM.echo.bind TRM
rainbow                   = TRM.rainbow.bind TRM
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
after                     = suspend.after
eventually                = suspend.eventually
immediately               = suspend.immediately
every                     = suspend.every
TEXT                      = require 'coffeenode-text'
#...........................................................................................................
url                       = 'http://localhost:3000/restart'

#-----------------------------------------------------------------------------------------------------------
send_request = ->
  requester = http.get url, ( response ) ->
    log "status of #{url}: #{response.statusCode}"

  requester.on 'error', ( error ) ->
    log "error: #{error.message}"


detect_changes()



