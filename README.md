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
The script includes also the static Methods Promise.all and Promise.race.

This class doesn't have all the characteristics of the Javascript Promise, so pay attention on differences:

- Differences between Promise Lua and Promise Javascript

1) Promise Lua doesn't work in async mode;
2) The static methods ``Promise.all`` and ``Promise.race`` cannot return "Settled" or "Pending" Promises;
3) The methods ``Promise.resolve`` and ``Promise.reject`` doesn't return Promises;

I hope you enjoyed the class, see you soon! <3
