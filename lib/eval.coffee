(->
	vm = undefined
	__slice_ = [].slice
	vm = require("vm")
	exports.allowUnsafeEval = (fn) ->
		previousEval = undefined
		previousEval = global["eval"]
		try
			global["eval"] = (source) ->
				vm.runInThisContext source

			return fn()
		finally
			global["eval"] = previousEval
		return

	exports.allowUnsafeNewFunction = (fn) ->
		previousFunction = undefined
		previousFunction = global.Function
		try
			global.Function = exports.Function
			return fn()
		finally
			global.Function = previousFunction
		return

	exports.allowUnsafe = (fn) ->
		previousEval = undefined
		previousFunction = undefined
		previousFunction = global.Function
		previousEval = global["eval"]
		try
			global.Function = exports.Function
			global["eval"] = (source) ->
				vm.runInThisContext source

			return fn()
		finally
			global["eval"] = previousEval
			global.Function = previousFunction
		return

	exports.Function = ->
		body = undefined
		paramList = undefined
		paramLists = undefined
		params = undefined
		_i = undefined
		_j = undefined
		_len = undefined
		paramLists = (if 2 <= arguments.length then __slice_.call(arguments, 0, _i = arguments.length - 1) else (_i = 0
		[]
		))
		body = arguments[_i++]

		params = []
		_j = 0
		_len = paramLists.length

		while _j < _len
			paramList = paramLists[_j]
			paramList = paramList.split(/\s*,\s*/)	if typeof paramList is "string"
			params.push.apply params, paramList
			_j++
		vm.runInThisContext "(function(" + (params.join(", ")) + ") {\n  " + body + "\n})"

	return
).call this
