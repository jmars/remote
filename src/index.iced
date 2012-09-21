uuid = require 'uuid'
Future = require 'future'

Remote = (port, local, api) ->
	waiting = {}
	remote = {}
	queue = []
	connected = false

	for k in api then do ->
		key = k
		remote[key] = (args...) ->
			future = Future()
			uid = uuid.generate()
			waiting[uid] = future
			message = JSON.stringify [uid, key, args]
			if connected
				port.send message
			else
				queue.push message
			return future

	port.open = ->
		connected = true
		for message in queue
			port.send message
		queue = []
		return
		
	port.close = ->
		connected = false
		return

	local.Future = Future

	port.recieve = (message) ->
		message = JSON.parse message
		switch message.length
			when 2
				[uid, result] = message
				waiting[uid].resolve result
				delete waiting[uid]
			when 3
				[uid, key, args] = message
				future = local[key].apply local, args
				if future.toString() isnt '[Future]'
					throw new TypeError 'API functions must return a Future.'
				future (result) -> port.send JSON.stringify [uid, result]

	return remote

module.exports = Remote