



###
#===========================================================================================================



 .d8888b.  8888888888 8888888b.  888     888 8888888888 8888888b.
d88P  Y88b 888        888   Y88b 888     888 888        888   Y88b
Y88b.      888        888    888 888     888 888        888    888
 "Y888b.   8888888    888   d88P Y88b   d88P 8888888    888   d88P
    "Y88b. 888        8888888P"   Y88b d88P  888        8888888P"
      "888 888        888 T88b     Y88o88P   888        888 T88b
Y88b  d88P 888        888  T88b     Y888P    888        888  T88b
 "Y8888P"  8888888888 888   T88b     Y8P     8888888888 888   T88b



#===========================================================================================================
###



############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TEXT                      = require 'coffeenode-text'
TYPES                     = require 'coffeenode-types'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'soba-level-server'
info                      = TRM.get_logger 'info',    badge
alert                     = TRM.get_logger 'alert',   badge
debug                     = TRM.get_logger 'debug',   badge
warn                      = TRM.get_logger 'warn',    badge
urge                      = TRM.get_logger 'urge',    badge
whisper                   = TRM.get_logger 'whisper', badge
help                      = TRM.get_logger 'help',    badge
#...........................................................................................................
# RMY                       = require 'remarkably'
# Htmlparser                = ( require 'htmlparser2' ).Parser
# XNCHR                     = require './XNCHR'
#...........................................................................................................
# MKTS                      = require './main'
# TEMPLATES                 = require './TEMPLATES'
#...........................................................................................................
# app                       = ( require 'express'   )()
# server                    = ( require 'http'      ).Server app
# SIO                       = ( require 'socket.io' ) server
# port                      = 3000
# client_count              = 0
# layout                    = TEMPLATES.layout()
# [ preamble, postscript, ] = layout.split '<!--#{content}-->'
#...........................................................................................................
# suspend                   = require 'coffeenode-suspend'
# step                      = suspend.step
# after                     = suspend.after
SOBA                      = require 'soba-server'
new_db                    = require 'level'

# debug '©LAyLl', require.resolve 'soba-server'
# debug '©epd4S', not module.parent?
# debug '©5M1it',  ( not module.parent? ) or 'serve' in process.argv
# process.exit()

#-----------------------------------------------------------------------------------------------------------
@serve = ->
  # { port: port, origins: '*:*', }
  server = server.listen port, ->
    # debug '©yXWeN', server.address()
    help "server process running on Node v#{process.versions[ 'node' ]}"
    { address: host, port, } = server.address()
    help "ソバ Server listening to http://#{host}:#{port}"

#-----------------------------------------------------------------------------------------------------------
QUEUE = {}

#-----------------------------------------------------------------------------------------------------------
QUEUE.new_queue = ->
  R =
    'queue':                []
    'first-idx':            null
    'total-count':          0
    'pending-count':        0
  return R

#-----------------------------------------------------------------------------------------------------------
QUEUE.push = ( me, event ) ->
  me[ 'queue' ].push event
  me[ 'total-count'   ] += 1
  me[ 'pending-count' ] += 1
  return me

#-----------------------------------------------------------------------------------------------------------
QUEUE.pull = ( me, handler ) ->
  return null if me[ 'first-idx' ] is null
  R = me[ 'queue' ].unsh event
  me[ 'total-count' ] += 1
  return me

############################################################################################################
if ( not module.parent? ) or 'serve' in process.argv
  sb          = SOBA.new_server()
  app         = SOBA.get_app sb
  router      = SOBA.get_router sb
  sio_server  = SOBA.get_sio_server sb
  db          = new_db njs_path.join __dirname, '../../data/mydb'
  debug '©hfSqh', db
  db.put '123', '456', ( error ) =>
    throw error if error?
    info "put a value"

  SOBA.serve sb

  sio_server.on 'connection', ( socket ) =>
    debug '©81uDb', 'connected'
    event_buffer = []

    report_event_buffer = ->
      message = "event buffer for #{SOBA.get_client_id sb, socket}: #{rpr event_buffer}"
      info message
      SOBA.emit_news sb, 'event-buffer', message

    socket.on 'get', ( P ) =>
      debug 'get', P
      event_buffer.push [ 'get', P, ]
      report_event_buffer()
      # next()

    socket.on 'put', ( P ) =>
      debug 'put', P
      event_buffer.push [ 'put', P, ]
      report_event_buffer()
      # next()

  ###
  router.on 'get', ( socket, P, next ) =>
    debug 'get', P
    next()

  router.on 'put', ( socket, P, next ) =>
    debug 'put', P
    next()
  ###




