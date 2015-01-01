



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
SOBA                      = require 'soba-server'
new_db                    = require 'level'


#===========================================================================================================
# INSTANTIATION
#-----------------------------------------------------------------------------------------------------------
@new_db = ->
  ### TAINT make configurable ###
  sb          = SOBA.new_server()
  db          = new_db njs_path.join __dirname, '../../data/mydb'
  #.........................................................................................................
  R           =
    '~isa':           'SOBA-LEVEL/db'
    '%soba-server':   sb
    '%level-db':      db
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@get_socket_router  = ( me ) -> SOBA.get_router     me[ '%soba-server' ]
@get_app            = ( me ) -> SOBA.get_app        me[ '%soba-server' ]
@get_sio_server     = ( me ) -> SOBA.get_sio_server me[ '%soba-server' ]
@get_soba_server    = ( me ) -> me[ '%soba-server'  ]
@get_level_db       = ( me ) -> me[ '%level-db'     ]


#===========================================================================================================
# SERVING
#-----------------------------------------------------------------------------------------------------------
@serve = ->
  # { port: port, origins: '*:*', }
  server = server.listen port, ->
    # debug '©yXWeN', server.address()
    help "server process running on Node v#{process.versions[ 'node' ]}"
    { address: host, port, } = server.address()
    help "ソバ Server listening to http://#{host}:#{port}"


#===========================================================================================================
# PUTTING AND GETTING FACETS
#-----------------------------------------------------------------------------------------------------------
@put = ( me, key, value = null ) ->


#===========================================================================================================
# QUEUE
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
  return null if me[ 'total-count' ] < 1
  R = me[ 'queue' ].unshift event
  me[ 'total-count' ] -= 1
  return me

############################################################################################################
if ( not module.parent? ) or 'serve' in process.argv
  SBLVL       = @

  debug '©hfSqh', db
  db.put '123', '456', ( error ) =>
    throw error if error?
    info "put a value"

  SOBA.serve sb

  sio_server.on 'connection', ( socket ) =>
    debug '©81uDb', 'connected'
    event_buffer = QUEUE.new_queue()

    report_event_buffer = ->
      message = "event buffer for #{SOBA.get_client_id sb, socket}: #{rpr event_buffer}"
      info message
      SOBA.emit_news sb, 'event-buffer', message

    socket.on 'get', ( key ) =>
      SBLVL.get db, socket, key
      report_event_buffer()
      # next()

    socket.on 'put', ( key, value ) =>
      SBLVL.put db, socket, key, value
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




