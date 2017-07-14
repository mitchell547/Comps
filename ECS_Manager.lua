require "ECS_Systems"
require "ECS_Components"

local t_insert = table.insert
local t_remove = table.remove

local function table_clear(t)
	for k, v in pairs(t) do t[k] = nil end
end

function ECSManager()
	local self = {}
	local systems = {}
	local entities = {}
	
	local entitiesToDelete = {}
	local componentsToDelete = {}
	local eventsToDelete = {}
	local systemsToDelete = {}
	
	local function doesEntitySatisfy(entity, requirements)
		for i, req in ipairs(requirements) do
			if entity[req] == nil then
				return false
			end
		end
		return true
	end
	
	-- Systems --
	
	function self.addSystem(system)
		--system.set_entities(entities)
		for i, entity in pairs(entities) do
			if doesEntitySatisfy(entity, system.requirements) then
				system.subscribers[i] = entity
			end
		end
		system.set_manager(self)
		t_insert(systems, system)
	end
	
	function self.removeSystem(system)
		t_insert(systemsToDelete, system)
	end
	
	function self.enableSystem(system_name)
		for index, sys in pairs(systems) do
			if sys.name == system_name then
				sys.enabled = true
			end
		end
	end
	
	function self.disableSystem(system_name)
		for index, sys in pairs(systems) do
			if sys.name == system_name then
				sys.enabled = false
			end
		end
	end
	
	-- Entities --
	
	function self.newEntity()
		t_insert(entities, {})
		return #entities
	end
	
	function self.deleteEntity(entity)
		t_insert(entitiesToDelete, entity)
	end
	
	-- Components --
	
	function self.addComponent(entity_id, component)
		local entity = entities[entity_id]
		entity[component.name] = component
		for i, system in pairs(systems) do
			if doesEntitySatisfy(entity, system.requirements) then
				system.subscribers[entity_id] = entity
			end
		end
	end
	
	function self.getComponent(entity, component)
		return entities[entity][component]
	end
	
	function self.getComponentField(entity, component, field)
		return entities[entity][component][field]
	end
	
	function self.setComponentField(entity, component, field, value)
		entities[entity][component][field] = value
	end
	
	function self.removeComponent(entity, component)
		t_insert(componentsToDelete, {entity=entity, component=component})
	end
	
	-- Events --
	
	function self.subscribeToEvent(event_entity_id, event_component, listener_id, callback_component)
		local event = entities[event_entity_id][event_component]
		t_insert(event.listeners, {entity = listener_id, component = callback_component})
	end
	
	function self.unsubscribeFromEvent(event_entity_id, event_component, listener_id)
		local event = entities[event_entity_id][event_component]
		for i, listener in pairs(event.listeners) do
			if listener.entity == listener_id then
				t_insert(event.listeners, i)
				return
			end
		end
	end
	
	-- Don't know if it is really necessary functionality
	-- Makes an array of components of one type (e.g. couple collisions happend with one entity)
	--[[function self.addListComponent(entity_id, component)
		local entity = entities[entity_id]
		if entity[component.name] == nil then
			entity[component.name] = {}
		end
		for i, system in pairs(systems) do
			if doesEntitySatisfy(entity, system.requirements) then
				--table.insert(system.subsribers, entity)
				system.subscribers[entity_id] = entity
			end
		end
		t_insert(entity[component.name], component)
	end
	
	function self.removeListComponent(entity, component, index)
		t_insert(eventsToDelete, {entity=entity, component=component, index=index})
	end
	]]--
	
	
	-- Auxiliary
	
	local function deleteMarkedObjects()
		for k, v in ipairs(entitiesToDelete) do
			t_remove(entities, v)
		end
		table_clear(entitiesToDelete)
		
		for k, v in ipairs(componentsToDelete) do
			local entity = entities[v.entity]
			if entity then 
				for i, system in pairs(systems) do
					for j, req in pairs(system.requirements) do
						if v.component == req then
							system.subscribers[v.entity] = nil
							break
						end
					end
				end
				entity[v.component] = nil 
			end
		end
		table_clear(componentsToDelete)
		
		for k, v in ipairs(eventsToDelete) do
			if entities[v.entity] then t_remove(entities[v.entity][v.component], v.index) end
		end
		table_clear(eventsToDelete)
		
		for k, system in ipairs(systemsToDelete) do
			for index, sys in pairs(systems) do
				if sys.name == system then
					systems[index] = nil
					break
				end
			end
		end
		table_clear(systemsToDelete)
	end
	
	--[[ Callbacks ]]--
	-- You can add other callbacks here ...
	
	function self.update(dt)
		for k, system in pairs(systems) do
			local upd = system.update
			if upd and system.enabled then	upd(dt)	end
		end
		deleteMarkedObjects()
	end
	
	function self.draw()
		for k, system in pairs(systems) do
			local drw = system.draw
			if drw and system.enabled then drw(dt) end
		end
	end
	
	function self.keypressed(key, unicode)
		for k, system in pairs(systems) do
			local kp = system.keypressed
			if kp and system.enabled then kp(key, unicode) end
		end
	end
	
	function self.keyreleased(key, scancode)
		for k, system in pairs(systems) do
			local kr = system.keyreleased
			if kr and system.enabled then kr(key, scancode) end
		end
	end
	
	function self.mousepressed(x, y, button, isTouch)
		for k, system in pairs(systems) do
			local mp = system.mousepressed
			if mp and system.enabled then mp(x, y, button, isTouch) end
		end
	end
	
	function self.mousereleased(x, y, button, isTouch)
		for k, system in pairs(systems) do
			local mr = system.mousereleased
			if mr and system.enabled then mr(x, y, button, isTouch) end
		end
	end
	
	return self
end
