local Promise= {}
do
	local promise= {}
	do
		promise.__index= promise
		function promise:new(callback)
			local p= {
				state="Pending",
				args= {res= {}, rej= {}}
			}
			local did= false
			function p.setState(state)
				p.state= state
			end
			function p.resolve(...)
				if not did then
					p.setState("Fullfilled")
					p.args.res= {...}
					did= true
				end
			end
			function p.reject(...)
				if not did then
					p.setState("Rejected")
					p.args.rej= {...}
					did= true
				end
			end
			callback(p.resolve, p.reject)
			return setmetatable(p, self)
		end
		function promise:Then(resolved, rejected)
			local res, throwed, did
			function Throw(...)
				self.setState("Rejected")
				self.args.rej= {...}
				throwed= true
			end
			if self.state=="Fullfilled" then
				res= resolved(table.unpack(self.args.res), Throw)
				did= true
			elseif self.state=="Rejected" and rejected then
				res= rejected(table.unpack(self.args.rej), Throw)
				did= true
			end
			if res and not throwed then
				self.setState("Fullfilled")
				self.args.res= {res}
			end
			if not res and not throwed and did then
				self.setState("Settled")
			end
			return self
		end
		function promise:Catch(callback)
			local res, throwed, did
			function Throw(...)
				self.setState("Rejected")
				self.args.rej= {...}
				throwed= true
			end
			if self.state=="Rejected" then
				res= callback(table.unpack(self.args.rej), Throw)
				did= true
			end
			if res and not throwed then
				self.setState("Fullfilled")
				self.args.res= {res}
			end
			if not res and not throwed and did then
				self.setState("Settled")
			end
			return self
		end
		function promise:Finnaly(callback)
			local throwed= false
			function Throw(...)
				self.setState("Rejected")
				self.args.rej= {...}
				throwed= true
			end
			callback(Throw)
			if not throwed then
				self.setState("Settled")
			end
			return self
		end
	end
	Promise.promise= promise
	function Promise.new(callback)
		return Promise.promise:new(callback)
	end
	function Promise.all(ps)
		local data= {}
		for pos in next, ps do
			if ps[pos].state=="Fullfilled" then
				data[#data + 1]= ps[pos].args.res
			elseif ps[pos].state=="Rejected" then
				return Promise.new(function(_, reject)
					reject(table.unpack(ps[pos].args.rej))
				end)
			end
		end
		return Promise.new(function(resolve)
			resolve(table.unpack(data))
		end)
	end
	function Promise.race(ps)
		for pos in next, ps do
			if ps[pos].state=="Fullfilled" then
				return Promise.new(function(resolve)
					resolve(table.unpack(ps[pos].args.res))
				end)
			elseif ps[pos].state=="Rejected" then
				return Promise.new(function(_, reject)
					reject(table.unpack(ps[pos].args.rej))
				end)
			end
		end
	end	
end