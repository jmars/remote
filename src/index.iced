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
    if data is 'A' then @emit 'data', JSON.stringify Object.keys @local
    message = JSON.parse data
    switch message.length
      when 1
        for k in message then do =>
          key = k
          @remote[key] = (args..., cb) ->
            uid = uuid.generate()
            @waiting[uid] = cb
            message = JSON.stringify [uid, key, args]
            @emit 'data', message
            return
        @emit 'remote', @remote
      when 2
        [uid, results] = message
        @waiting[uid] results...
        delete waiting[uid]
      when 3
        [uid, key, args] = message
        local[key].apply local, [args].concat (args...) ->
          port.send JSON.stringify [uid, args]

  pipe: ->
    super
    @emit 'data', 'A'

  pause: ->

  resume: ->

  end: (data) ->

module.exports = RPC