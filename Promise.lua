local Promise= {} --Main var
local _promise= {} --class var
---------------------------------------------------------------------------
--Promise class config
do
	_promise.__index= _promise
    ------------------------------------------------------------------------
	function _promise:new(callback)
		local p= {
			state="Pending",
			args= {
				res= {},
				rej= {}
			}
		}
		local exec= false
		--Resolve and reject
		function resolve(...)
			if not exec then
				p.state="Fulfilled"
				p.args.res= {...}
				exec= true
			end
		end
		function reject(...)
			if not exec then
				p.state="Rejected"
				p.args.rej= {...}
				exec= true
			end
		end
		callback(resolve, reject)
		return setmetatable(p, self)
	end
	--system
	function _promise:setState(state) --Set the promise state
		self.state= state
	end
	------------------------------------------------------------------------
	function _promise:Then(onResolve, onReject) --Function that is called when the Promise state is "Fulfilled", running onResolve, or onReject, if the state is "Rejected" and if the callback was declared
		local data, params= {}, {}
		local exec, throwed= false, false
		function throw(...)
			self:setState("Rejected")
			self.args.rej= {...}
			throwed= true
		end
		if self.state=="Fulfilled" then
			params= self.args.res
			params[#params + 1]= throw
			data= table.pack(onResolve(table.unpack(params)))
			exec= true
		elseif self.state=="Rejected" and onReject then
			params= self.args.rej
			params[#params + 1]= throw
			data= table.pack(onReject(table.unpack(params)))
			exec= true
		end
		if #data> 0 and not throwed then
			self:setState("Fulfilled")
			self.args.res= data
		end
		if exec and #data== 0 and not throwed then
			self:setState("Settled")
		end
		return self
	end
	function _promise:Catch(onReject) --Function that is calle when Promise state is "Rejected", running onReject
		local data, params= {}, {}
		local exec, throwed= false, false
		function throw(...)
			self:setState("Rejected")
			self.args.rej= {...}
			throwed= true
		end
		if self.state=="Rejected"  then
			params= self.args.rej
			params[#params + 1]= throw
			data= table.pack(onReject(table.unpack(params)))
			exec= true
		end
		if #data> 0 and not throwed then
			self:setState("Fulfilled")
			self.args.res= data
		end
		if exec and #data== 0 and not throwed then
			self:setState("Settled")
		end
		return self
	end
	function _promise:Finnaly(callback) --Every time it's runned doesn't matter what is the state of Promise
		local throwed= false
		function throw(...)
			self:setState("Rejected")
			self.args.rej= {...}
			throwed= true
		end
		callback(throw)
		if not throwed then
			self:setState("Settled")
		end
		return self
	end
end
---------------------------------------------------------------------------
do
	function Promise.new(callback) --Returns a new Promise instance
		return _promise:new(callback)
	end
	function Promise.resolve(...) --Returns a resolved Promise with ... values
		local args= {...}
		return Promise.new(function(resolve)
			resolve(table.unpack(args))
		end)
	end
	function Promise.reject(...) --Returns a rejected Promise with ... errors
		local args= {...}
		return Promise.new(function(_, reject)
			reject(table.unpack(args))
		end)
	end
	function Promise.all(list) --Run the list and returns: 1 - a resolved Promise (if all the Promises in list were resolved or if they're not promises, containing their values), 2 - a rejected Promise (if one of the Promises was rejected, containing its errors), 3 - a pending Promise (if the list is empty)
		local data= {}
		for pos in next, list do
			if type(list[pos])=="table" then
				if list[pos].state=="Fulfilled" then
					data[#data + 1]= list[pos].args.res
				elseif list[pos].state=="Rejected" then
					return Promise.new(function(_, reject)
						reject(table.unpack(list[pos].args.rej))
					end)
				end
			else
				data[#data + 1]= list[pos]
			end
		end
		if #list== 0 then
			return Promise.new(function()
				--Pending Promise
			end)
		else
			return Promise.new(function(resolve)
				resolve(data)
			end)
		end
	end
	function Promise.race(list) --Returns a resolved Promise if one of the Promises in list was resolved (contains its values) or a rejected Promise if one of the Promises in lost ws rejected (contains its errors)
		for pos in next, list do
			if list[pos].state=="Fulfilled" then
				return Promise.new(function(resolve)
					resolve(table.unpack(list[pos].args.res))
				end)
			elseif list[pos].state=="Rejected" then
				return Promise.new(function(_, reject)
					reject(table.unpack(list[pos].args.rej))
				end)
			end
		end
	end
end