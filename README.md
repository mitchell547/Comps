# Comps
Entity-Component-System framework on Lua aimed to use with Love2D.

# Basic use

To use framework you only need to load ECS_Manager.lua in your code:
```lua
require "ECS_Manager"
```

Creating new entity in our ECS instance:
```lua
player = ECS.newEntity() -- returns index of entity
ECS.addComponent(player, Component_Position(200, 100))
ECS.addComponent(player, Component_Velocity(0, 0))
ECS.addComponent(player, Component_Keyboard_Controls(("w", "d", "s", "a")))
```

If you want to remove a component "position" from entity with index 'player':
```lua
ECS.removeComponent(player, "position")
```

Adding Systems that will process Components:
```lua
ECS.addSystem(System_Handling())
ECS.addSystem(System_Moving())
ECS.addSystem(System_Drawing())
```
Note, that order of adding is also the order of Systems calling.

Creating an instance of ECS Manager:
```lua
function love.load()
    ECS = ECSManager()
end
```

Using ECS in gameloop:
```lua
function love.update(dt)
    ECS.update(dt)
end

function love.draw()
    ECS.draw()
end
```

# Writing new Components and Systems

Components are actually tables with some fields. Field 'name' is necessary for every Component.
It is convenient to wrap up table creating into function:
```lua
function Component_Position(_x, _y)	-- your function, that takes initial parameters
    local self = {			-- table, that represents Component
        name = "position",		-- name of your Component (necessary field)
        x = _x or 0, 			-- fields of this Component
        y = _y or 0 }
    return self				-- return created table (Component)
end
```

Systems are also Lua-tables, that store some functions. This is actually one of the variants to implement a class in Lua.
```lua
function System_Moving()		
	local self = System_Base()	-- inherit functional of Systems of framework
	self.name = "moving"		-- call it with unique name
	
	self.requirements = {		-- write required Components to process in this System
		"position",
		"velocity"
	}
	
	function self.update(dt)	-- callback function, that ECS Manager will call
		for i, e in pairs(self.subscribers) do	-- iterate over subscribers of this System (subscriber list is generated automatically)
			local p = e.position		
			local v = e.velocity
			p.x = p.x + v.vx * dt		-- do some processing
			p.y = p.y + v.vy * dt
		end
	end
	
	return self			-- don't forget to return table (class)
end
```
