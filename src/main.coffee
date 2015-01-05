



###
#===========================================================================================================



888      8888888888 888     888 8888888888 888         .d8888b.  8888888888 8888888b.  888     888 8888888888 8888888b.
888      888        888     888 888        888        d88P  Y88b 888        888   Y88b 888     888 888        888   Y88b
888      888        888     888 888        888        Y88b.      888        888    888 888     888 888        888    888
888      8888888    Y88b   d88P 8888888    888         "Y888b.   8888888    888   d88P Y88b   d88P 8888888    888   d88P
888      888         Y88b d88P  888        888            "Y88b. 888        8888888P"   Y88b d88P  888        8888888P"
888      888          Y88o88P   888        888              "888 888        888 T88b     Y88o88P   888        888 T88b
888      888           Y888P    888        888        Y88b  d88P 888        888  T88b     Y888P    888        888  T88b
88888888 8888888888     Y8P     8888888888 88888888    "Y8888P"  8888888888 888   T88b     Y8P     8888888888 888   T88b



#===========================================================================================================
###



############################################################################################################
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
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
range                     = require 'level-range'
#...........................................................................................................
### https://github.com/loveencounterflow/pipedreams ###
D                         = require 'pipedreams'
$                         = D.remit.bind D
#...........................................................................................................
rmrf                      = require 'rimraf'
#...........................................................................................................
### https://github.com/nkzawa/socket.io-stream ###
wrap_as_socket_stream     = require 'socket.io-stream'


#===========================================================================================================
# INSTANTIATION
#-----------------------------------------------------------------------------------------------------------
@new_db = ( db_route ) ->
  ### TAINT make configurable ###
  sb          = SOBA.new_server()
  db          = new_db db_route
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
#...........................................................................................................
@get_soba_server    = ( me ) -> me[ '%soba-server'  ]
@get_level_db       = ( me ) -> me[ '%level-db'     ]
#...........................................................................................................
@get_level_db_route = ( me ) -> ( @get_level_db me )[ 'location' ]


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
# REMOVING DB OR (RANGES OF) RECORDS
#-----------------------------------------------------------------------------------------------------------
### TAINT not a SOBA-triggerable method for now; must deal with new DB connection without touching
  `%level-db` object in `me` ###
# @remove_db = ( me, socket = null, handler ) ->
#   ### TAINT must we ensure there are no current connections? ###
#   switch arity = arguments.length
#     when 2
#       [ socket, handler, ] = [ null, socket, ]
#     when 3
#       null
#     else
#       throw new Error "expected 2 or 3 arguments, got #{arity}"
#   db_route = @get_level_db_route me
@_remove_db = ( db_route, handler ) ->
  warn "erasing database at #{db_route}"
  rmrf.sync db_route
  warn "erased database at #{db_route}"
  # @emit me, socket, 'remove-db', [ db_route, ] if socket?
  handler null


#===========================================================================================================
# PUTTING AND GETTING FACETS
#-----------------------------------------------------------------------------------------------------------
@put = ( me, socket, key, value, handler ) ->
  [ value, handler, ] = [ null, value, ] unless handler?
  # debug '©MQfO5', ( rpr key ), ( rpr value )
  me[ '%level-db' ].put key, value, handler

#-----------------------------------------------------------------------------------------------------------
@get = ( me, socket, key, handler ) ->
  throw new Error 'not implemented'

#-----------------------------------------------------------------------------------------------------------
@dump = ( me, settings, handler ) ->
  format      = settings?[ 'format' ] ? 'one-by-one'
  limit       = settings?[ 'take'   ] ? 10
  prefix      = settings?[ 'prefix' ] ? ''
  db          = @get_level_db me
  soba_server = @get_soba_server me
  input       = range db, prefix
  #.........................................................................................................
  switch format
    when 'list'
      Z = []
    when 'one-by-one'
      null
    else
      return handler new Error "unknown format #{rpr format}"
  #.........................................................................................................
  ### TAINT how to signal end of stream when `format is 'one-by-one'`? ###
  ### TAINT should we identify response with a request ID?
    how do clients sort out responses from overlapping requests` ###
  input
    .pipe D.$take limit
    .pipe D.$show()
    .pipe $ ( facet, send, end ) =>
      #.....................................................................................................
      if facet?
        #...................................................................................................
        switch format
          when 'list'
            Z.push facet
          when 'one-by-one'
            handler null, facet
        #...................................................................................................
        send 1
      #.....................................................................................................
      if end?
        #...................................................................................................
        switch format
          when 'list'
            handler null, Z
          when 'one-by-one'
            handler null, null
        end()



############################################################################################################
@demo = ( db_route ) ->
  db          = SBLVL.new_db db_route
  level_db    = SBLVL.get_level_db db
  router      = SBLVL.get_socket_router db

  # debug '©hfSqh', level_db
  # level_db.put '123', '456', ( error ) =>
  #   throw error if error?
  #   info "put a value"

  # #---------------------------------------------------------------------------------------------------------
  # router.on '*', ( socket, P, next ) =>
  #   [ type, data, rsvp, ] = P
  #   debug '©9kKtv', socket[ 'id' ], type, ( rpr data ), rsvp?, rpr rsvp
  #   # rsvp 'XXXXX' if rsvp?
  #   next()

  SOBA.serve db

  sio_server = SBLVL.get_sio_server db
  sio_server.on 'connection', ( socket ) =>
    debug '©81uDb', 'connected'
    sb = SBLVL.get_soba_server db

    #-------------------------------------------------------------------------------------------------------
    ### OBS: we're using pipedreams-style method signatures here where payload is always single argument ###
    socket.on 'get', ( [ key, ] ) =>
      SBLVL.get db, socket, key, ( error ) ->
        throw error if error?
        urge 'ready:', 'get', key

    #-------------------------------------------------------------------------------------------------------
    ### OBS: we're using pipedreams-style method signatures here where payload is always single argument ###
    socket.on 'put', ( [ key, value, ] ) =>
      SBLVL.put db, socket, key, value, ( error ) ->
        throw error if error?
        urge 'ready:', 'put', key

    #-------------------------------------------------------------------------------------------------------
    ### TAINT not sure about that `rsvp` name; it shouldn't be `handler`, as there's no initial error
      argument, just payload. ###
    # socket.on 'dump', ( stream, settings, rsvp ) =>
    ( wrap_as_socket_stream socket ).on 'dump', { encoding: 'utf-8', }, ( output, settings ) =>
      # debug '©iFT1I', arguments
      # input = njs_fs.createReadStream '/vagrant/package.json', encoding: 'utf-8'
      # input.pipe output
      # TRM.dir output
      ### TAINT using `output,write()` directly doesn't work, using through stream as arbiter ###
      through = D.create_throughstream()
      through.pipe output
      batch_idx = 0
      format    = settings?[ 'format' ] ? 'one-by-one'
      #.....................................................................................................
      SBLVL.dump db, settings, ( error, data ) =>
        throw error if error?
        urge 'ready:', 'dump'
        if data?
          switch format
            when 'one-by-one', 'list'
              event       = [ 'batch', batch_idx, data, ]
              batch_idx  += 1
            # when 'list'
            #   event       = [ ]
            else
              ### TAINT pass error on ###
              throw new Error "unknown format #{rpr format}"
          through.write ( JSON.stringify event ) + '\n'
        else
          through.end()

    #-------------------------------------------------------------------------------------------------------
    socket.on 'remove-db', =>
      SBLVL.dump db, socket, settings, ( error ) ->
        throw error if error?
        urge 'ready:', 'remove-db'

  ###
  router.on 'get', ( socket, P, next ) =>
    debug 'get', P
    next()

  router.on 'put', ( socket, P, next ) =>
    debug 'put', P
    next()
  ###


############################################################################################################
if ( not module.parent? ) or 'serve' in process.argv
  SBLVL       = @
  # db_route    = njs_path.join __dirname, '../../data/mydb'
  db_route    = njs_path.join __dirname, '../../data/jizura-mojikura'
  remove_db   = no
  if remove_db
    SBLVL._remove_db db_route, -> SBLVL.demo db_route
  else
    SBLVL.demo db_route





