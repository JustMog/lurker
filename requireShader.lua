local Wrapper = {}
Wrapper.__index = Wrapper

---@diagnostic disable-next-line: deprecated
local loaders = package.loaders or package.searchers

local loveShader = love.graphics.newShader([[
    vec4 effect( vec4 _color, Image _tex, vec2 _texPos, vec2 _scrPos ) {
        return vec4(0.0);
    }
]])
local loveShaderFns = {"release","type","typeOf","getWarnings","hasUniform","send","sendColor"}

for _, k in ipairs(loveShaderFns) do
    Wrapper[k] = function(self,...)
        local ok, res = pcall(loveShader[k], self.shader, ...)
        if not ok then
            error(res:gsub("?", k), 2)
        end
    end
end

local origSet = love.graphics.setShader

---@diagnostic disable-next-line: duplicate-set-field
function love.graphics.setShader(shader)
    if getmetatable(shader) == Wrapper then
        shader = shader.shader
    end
    return origSet(shader)
end

function Wrapper:set()
    origSet(self.shader)
end

function Wrapper:trySend(uniformName, ...)
    if self.shader:hasUniform(uniformName) then
        self.shader:send(uniformName, ...)
    end
end

function Wrapper:trySendColor(uniformName, ...)
    if self.shader:hasUniform(uniformName) then
        self.shader:sendColor(uniformName, ...)
    end
end

function Wrapper:release()
    package.loaded[self.path] = nil
    self.shader:release()
end

local function newWrapped(path)
    local ok, res = pcall(love.graphics.newShader, path)
    if not ok then error(("Error loading shader %s:\n %s"):format(path,res),2) end
    return setmetatable({ shader = res, path = path }, Wrapper)
end


table.insert(loaders, function(modName)
    if modName:match(".glsl$") then
        return newWrapped
    end
end)
