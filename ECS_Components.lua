
-- Just a template for component
function Component_Empty() 
	local self = {
		name = "put_unique_name"
		-- properties ...
	}
	return self
end

function Component_Position(_x, _y)
	local self = {	
		name = "position",
		x = _x or 0, 
		y = _y or 0 }
	return self
end

function Component_Velocity(_vx, _vy)
	local self = {
		name = "velocity",
		vx = _vx or 0,
		vy = _vy or 0 }
	return self
end

function Component_Keyboard_Controls(_up, _right, _down, _left) 
	local self = {
		name 	= "keyboard_controls",
		
		up = _up or "up",
		right = _right or "right",
		down = _down or "left",
		left = _left or "left",
	}
	return self
end

function Component_Timer_Event(_interval)
	local self = {
		name = "timer_event",
		listeners = {},
		interval = _interval or 10.0, -- in seconds
		remaining_time = _interval
	}
	return self
end

function Component_New_Direction_Callback()
	local self = {
		name = "new_direction"
	}
	return self
end


