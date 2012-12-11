uuid = require 'uuid'
Stream = require 'stream'

class RPC extends Stream
  constructor: (@local) ->
    super
    @readable = true
    @writable = true
    @waiting = {}
    @remote = {}
    @paused = false

  write: (data) ->
    message = JSON.parse data
    switch message.type
      when 'keys'
        for k in message.keys then do =>
          key = k
          @remote[key] = (args..., cb) ->
            uid = uuid.generate()
            @waiting[uid] = cb
            message = JSON.stringify
              uid: uid
              key: key
              args: args
              type: 'call'
            @emit 'data', message
        @emit 'remote', @remote
      when 'handshake'
        @emit 'data', JSON.stringify
          type: 'keys'
          keys: Object.keys @local
      when 'return'
        {uid, result} = message
        @waiting[uid] result...
        delete waiting[uid]
      when 'call'
        {uid, key, args} = message
        local[key].apply local, [args].concat (args...) ->
          @emit 'data', JSON.stringify
            uid: uid
            result: args
            type: 'return'

  pipe: ->
    super
    @emit 'data', JSON.stringify {type: 'handshake'}

  pause: ->

  resume: ->

  end: (data) ->

module.exports = RPC