require "ECS_Manager"

--- New entity creating
function create_player(x, y, vx, vy)
	local entity = ecs.newEntity()
	ecs.addComponent(entity, Component_Position(x, y))
	ecs.addComponent(entity, Component_Velocity(vx, vy))
	ecs.addComponent(entity, Component_Keyboard_Controls("w", "d", "s", "a"))
	return entity
end

function create_moving_dot(x, y, vx, vy)
	local entity = ecs.newEntity()
	ecs.addComponent(entity, Component_Position(x, y))
	ecs.addComponent(entity, Component_Velocity(vx, vy))
	return entity
end

function create_static_dot(x, y)
	local entity = ecs.newEntity()
	ecs.addComponent(entity, Component_Position(x, y))
	return entity
end

function add_systems_prior(ECS)
	ECS.addSystem(System_Handling())
	ECS.addSystem(System_Moving())
	ECS.addSystem(System_EventTimerHandling())
	ECS.addSystem(System_ChangeDirection())
	ECS.addSystem(System_Drawing())
end

-- Main --

-- Example of use of ECS framework

function love.load()
	-- Create new instance of ECS Manager
	ecs = ECSManager()
	
	-- Add processing Systems to it
	add_systems_prior(ecs)
	
	-- Make some entities
	e1 = create_player(400, 300)
	create_static_dot(500, 400)
	e2 = create_moving_dot(300, 300, 50, 0)
	
	-- Example of using events with ECS
	ecs.addComponent(e2, Component_Timer_Event(1.0))
	ecs.subscribeToEvent(e2, "timer_event", e2, Component_New_Direction_Callback)
end

function love.update(dt)
	ecs.update(dt)
end

function love.draw()
	ecs.draw()
	local x, y = ecs.getComponentField(e1, "position", "x"), ecs.getComponentField(e1, "position", "y")
	love.graphics.print("player", x - 20, y - 25)
	love.graphics.print("W A S D", 10, 10)
end
