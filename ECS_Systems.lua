require "ECS_Components"

function System_Base()
	-- Your systems must be *inherited* from this class 
	-- Don't forget about returning self table at the end
	local self = {}
	self.name = "base"
	self.subscribers = {}
	self.enabled = true
	local manager = {}
	
	function self.addComponent(entity, component)
		manager.addComponent(entity, component)
	end
	
	function self.removeComponent(entity, component)
		manager.removeComponent(entity, component)
	end
	
	function self.addEventComponent(entity, component)
		manager.addEventComponent(entity, component)
	end
	
	function self.removeEventComponent(entity, component, index)
		manager.removeEventComponent(entity, component, index)
	end
	
	function self.addComponentsToListeners(event_component)
		for i, listener in pairs(event_component.listeners) do
			self.addComponent(listener.entity, listener.component(--[[arguments]]))
		end
	end
	
	--[[function self.addListComponent(entity, component)
		manager.addListComponent(entity, component)
	end
	
	function self.removeListComponent(entity, component, index)
		manager.removeListComponent(entity, component, index)
	end
	]]--
	
	function self.set_manager(_manager)
		manager = _manager
	end
	
	function self.get_manager()
		return manager
	end
	
	return self
end

function System_Moving()
	local self = System_Base()
	self.name = "moving"
	
	self.requirements = {
		"position",
		"velocity"
	}
	
	function self.update(dt)
		for i, e in pairs(self.subscribers) do
			local p = e.position
			local v = e.velocity
			p.x = p.x + v.vx * dt
			p.y = p.y + v.vy * dt
		end
	end
	
	return self
end

function System_Handling()
	local self = System_Base()
	self.name = "handling"
	
	self.requirements = {
		"velocity",
		"keyboard_controls"
	}
	
	function self.update(dt)
		for i, e in pairs(self.subscribers) do
			local v = e.velocity
			local b = e.keyboard_controls
			v.vx, v.vy = 0, 0
			if 		love.keyboard.isDown(b.up) 		then v.vy = -100
			elseif 	love.keyboard.isDown(b.down) 	then v.vy = 100
			end
			if 		love.keyboard.isDown(b.right) 	then v.vx = 100
			elseif 	love.keyboard.isDown(b.left) 	then v.vx = -100
			end
		end
	end
	
	return self
end

function System_EventTimerHandling()
	local self = System_Base()
	self.name = "event_timer_handling"
	
	self.requirements = {
		"timer_event"
	}
	
	function self.update(dt)
		for i, e in pairs(self.subscribers) do
			local event = e.timer_event
			event.remaining_time = event.remaining_time - dt
			if event.remaining_time <= 0 then
				-- fire event
				self.addComponentsToListeners(event)
				-- restart timer
				event.remaining_time = event.interval
			end
		
		end
	end
	
	return self
end

function System_ChangeDirection()
	local self = System_Base()
	self.name = "change_direction"
	
	self.requirements = {
		"new_direction",
		"velocity"
	}
	
	function self.update(dt)
		for i, e in pairs(self.subscribers) do
			local v = e.velocity
			local nd = e.new_direction
			-- processing ...
			v.vx, v.vy = love.math.random(-1, 1)*30, love.math.random(-1, 1)*30
			-- event is processed, remove the component
			self.removeComponent(i, nd.name)
		end
	end
	
	return self
end

function System_Drawing()
	local self = System_Base()
	self.name = "drawing"
	
	self.requirements = {
		"position"
	}
	
	function self.draw()
		for i, e in pairs(self.subscribers) do
			local p = e.position
			love.graphics.circle("fill", p.x, p.y, 10)
		end
	end
	
	return self
end


return Systems