



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


#-----------------------------------------------------------------------------------------------------------
### TAINT expedient until we have started HOLLERITH2 ###
HOLLERITH = {}

#-----------------------------------------------------------------------------------------------------------
### TAINT should choose more descriptive name ###
HOLLERITH._XXX_lte_from_gte = ( gte ) ->
  length  = Buffer.byteLength gte
  R       = new Buffer 1 + length
  R.write gte
  R[ length ] = 0xff
  return R



############################################################################################################
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
# TEXT                      = require 'coffeenode-text'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'soba-level-server'
info                      = CND.get_logger 'info',    badge
alert                     = CND.get_logger 'alert',   badge
debug                     = CND.get_logger 'debug',   badge
warn                      = CND.get_logger 'warn',    badge
urge                      = CND.get_logger 'urge',    badge
whisper                   = CND.get_logger 'whisper', badge
help                      = CND.get_logger 'help',    badge
#...........................................................................................................
SOBA                      = require 'soba-server'
new_db                    = require 'level'
#...........................................................................................................
### https://github.com/loveencounterflow/pipedreams ###
D                         = require 'pipedreams'
D2                        = require 'pipedreams2'
$                         = D.remit.bind D
#...........................................................................................................
rmrf                      = require 'rimraf'


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
@get_level_db_route = ( me ) -> ( @get_level_db     me )[ 'location' ]
@get_verbose        = ( me ) -> ( @get_soba_server  me )[ 'verbose'  ]


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
@dump = ( me, socket, type_with_id, settings ) ->
  warn '©iPuul', settings
  limit         = settings?[ 'take'   ] ? 10
  skip_count    = settings?[ 'skip'   ] ? 0
  prefix        = settings?[ 'prefix' ] ? ''
  rsvp          = settings?[ 'rsvp'   ] ? null
  # debug '©24THN', me[ '%level-db'     ]
  db            = @get_level_db me
  soba_server   = @get_soba_server me
  query         = gte: prefix, lte: HOLLERITH._XXX_lte_from_gte prefix
  input         = db.createReadStream query
  batch_idx     = -1
  warn '©WUaB1', "skipping first #{skip_count} entries" if skip_count > 0
  #.........................................................................................................
  input
    .pipe D2.$skip_first skip_count
    .pipe D.$take limit
    # .pipe D.$show()
    .pipe $ ( facet, send, end ) =>
      #.....................................................................................................
      if facet?
        batch_idx  += 1
        debug '©cGwQe', type_with_id, batch_idx, facet[ 'key' ]
        socket.emit type_with_id, [ 'batch', batch_idx, facet, rsvp, ]
      #.....................................................................................................
      if end?
        socket.emit type_with_id, null
        end()


############################################################################################################
@demo = ( db_route ) ->
  db          = SBLVL.new_db db_route
  level_db    = SBLVL.get_level_db db
  router      = SBLVL.get_socket_router db

  #---------------------------------------------------------------------------------------------------------
  router.on '*', ( socket, P, next ) =>
    [ type_with_id, data, rsvp, ] = P
    # debug '©9kKtv', socket[ 'id' ], type_with_id, ( rpr data ), rsvp?, rpr rsvp
    # rsvp 'XXXXX' if rsvp?
    [ type, id, ]   = type_with_id.split '#'
    id             ?= null
    # help '©l3ARP', type, id
    switch type
      when 'dump'
        if CND.isa_function P
          P 'hello there'
        else
          @dump db, socket, type_with_id, data
    next()

  ##########################################################################################################
  SOBA.serve db
  ##########################################################################################################

  sio_server = SBLVL.get_sio_server db
  sio_server.on 'connection', ( socket ) =>
    debug '©81uDb', 'connected'
    sb = SBLVL.get_soba_server db

    #-------------------------------------------------------------------------------------------------------
    ### OBS: we're using pipedreams-style method signatures here where payload is always single argument ###
    socket.on 'get', ( [ key, ] ) =>
      SBLVL.get db, socket, key, ( error ) =>
        throw error if error?
        urge 'ready:', 'get', key if @get_verbose db

    #-------------------------------------------------------------------------------------------------------
    ### OBS: we're using pipedreams-style method signatures here where payload is always single argument ###
    socket.on 'put', ( [ key, value, ] ) =>
      SBLVL.put db, socket, key, value, ( error ) =>
        throw error if error?
        urge 'ready:', 'put', key if @get_verbose db

    #-------------------------------------------------------------------------------------------------------
    socket.on 'remove-db', =>
      SBLVL.dump db, socket, settings, ( error ) =>
        throw error if error?
        urge 'ready:', 'remove-db'


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





