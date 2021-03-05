# Promise.lua
A class that can create Promises as the Javascript promises in Lua! It's necessary you know Javascript Promises to use this.

- How to use?

You have fistly create a Promise or return in a function (it's more common), like this:
```lua
local promise= Promise.new(...)
----------------------------
local func= function()
  return Promise.new(...)
end
```
The function ``Promise.new`` receives as the unique parameter a callback, that will receive the functions ``resolve`` and ``reject``. You will handle the results or erros with the methods ``:Then``, ``:Catch`` and ``:Finnaly``. Look at the example:
```lua
local players= {
	["Jp_darkuss#4806"]= {points= 12},
	["Noobloops#0000"]= {points= 15}
}
local getPoints= function(name)
	return Promise.new(function(resolve, reject)
		if players[name] then
			resolve(players[name].points, name)
		else
			reject("That player doesn't exist!")
		end
	end)
end
local success= function(points, name)
	print("Pontos de "..name..": "..points)
end
local failure= function(error)
	print("Erro: "..error)
end
getPoints("Noobloops#0000"):Then(success):Catch(failure)
getPoints("Jp_darkuss#4806"):Then(success):Catch(failure)
getPoints("Pigui#5177"):Then(success):Catch(failure)
```

You can use the function ``throw`` to cast a error and set the state of the Promise to "Rejected". You access the function after the parameters of callbacks:
```lua
local promise= Promise.new(...)
promise:Then(function(..., throw)
	throw(...)
end, function(..., throw)
	throw(...)
end):Catch(function(..., throw)
	throw(...)
end):Finnaly(function(throw)
	throw(...)
end)
```

* Tree of the class

```lua
Promise
	new (function): creates a Promise instance
	race (function): works like the Js Promise.race
	all (function): works like the Js Promise.all
	reject (function): returns a rejected Promise
	resolve (function): returns a resolved Promise
Promise instance
	:Then (function)
	:Catch (function)
	:Finnaly (function)
	:setState (function): set the state of Promise (system function)
	.state (string)
	.args (table)
		.res (table): contains the resolved parameters
		.rej (table): contains the rejected paramaters
```

The script includes also the static Methods Promise.all, Promise.race, Promise.resolve and Promise.reject.

DISCLAIMER: Promise.lua doens't work in async mode!!

* #Update

The class now is more similar to the Javascript class
---------------------------------------------------------------------------------------------------------------------------------------------------------------
I hope you enjoyed the class, see you soon! <3
