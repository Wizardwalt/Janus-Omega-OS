-- src/lua/sensor_interface.lua
-- Hardware sensor interface and data collection

local sensor_interface = {}
sensor_interface.sensors = {}
sensor_interface.readings = {}

-- Supported sensors
local SENSOR_TYPES = {
    BME680 = "environmental",
    FLIR = "thermal",
    GEIGER = "radiation",
    HEART_RATE = "biometric",
    EKG = "biometric",
}

-- Initialize sensor
function sensor_interface.init_sensor(sensor_type)
    if not SENSOR_TYPES[sensor_type] then
        return false, "Unknown sensor type"
    end
    
    local sensor = {
        type = sensor_type,
        category = SENSOR_TYPES[sensor_type],
        active = true,
        last_reading = nil,
    }
    
    table.insert(sensor_interface.sensors, sensor)
    print("Sensor initialized: " .. sensor_type)
    return true
end

-- Read sensor data
function sensor_interface.read_sensor(sensor_index)
    local sensor = sensor_interface.sensors[sensor_index]
    if not sensor then
        return nil, "Sensor not found"
    end
    
    if not sensor.active then
        return nil, "Sensor inactive"
    end
    
    -- Simulated sensor reading
    local reading = {
        type = sensor.type,
        value = math.random(20, 30),
        unit = sensor.category == "environmental" and "°C" or sensor.category == "radiation" and "µSv" or "%",
        timestamp = os.time(),
    }
    
    sensor.last_reading = reading
    table.insert(sensor_interface.readings, reading)
    return reading
end

-- Get sensor readings history
function sensor_interface.get_readings_history(limit)
    limit = limit or 100
    local history = {}
    for i = math.max(1, #sensor_interface.readings - limit + 1), #sensor_interface.readings do
        table.insert(history, sensor_interface.readings[i])
    end
    return history
end

-- Disable sensor
function sensor_interface.disable_sensor(sensor_index)
    local sensor = sensor_interface.sensors[sensor_index]
    if sensor then
        sensor.active = false
        print("Sensor disabled: " .. sensor.type)
        return true
    end
    return false
end

-- List active sensors
function sensor_interface.list_active_sensors()
    local active = {}
    for _, sensor in ipairs(sensor_interface.sensors) do
        if sensor.active then
            table.insert(active, sensor)
        end
    end
    return active
end

return sensor_interface
