# Lurker

A small module which automatically hotswaps changed Lua files in a running
[LÖVE](http://love2d.org) project.


## Installation
```
git clone --recursive https://github.com/JustMog/lurker
```
into an existing project (or drop the [lurker.lua](lurker.lua?raw=1) and
[lume.lua](https://raw.github.com/rxi/lume/master/lume.lua) files) and add the following line inside the `love.update()`
function:
```lua
require("lurker").update()
```
Lurker will automatically detect changed files and hotswap them into the
running project.


## Additional Functionality

To more easily make use of additional functionality, the lurker module can be
set to a variable when it is required into the project:
```lua
lurker = require "lurker"
```

### lurker.scan()
As opposed to using the `lurker.update()` function -- such to avoid the
overhead of repeatedly polling for file changes -- you can instead opt to
trigger a scan of the directory by calling `lurker.scan()` manually. If the
scan detects any changes a hotswap is performed.

### lurker.preswap
`lurker.preswap` can be set to a function. This function is called before a
hotswap occurs and is passed the name of the file which will be swapped. If the
function returns `true` then the hotswap is canceled.
```lua
lurker.preswap = function(f) print("File " .. f .. " swapping...") end
```

### lurker.postswap
`lurker.postswap` can be set to a function. This function is called after a
hotswap occurs and is passed the name of the file which was swapped.
```lua
lurker.postswap = function(f) print("File " .. f .. " was swapped") end
```

### lurker.useShaderReload(enable)
Pass true to enable hot reloading shaders from .glsl files.
Once enabled, use require to load shaders in the form of a thin wrapper hotswappable by lurker.
These also provide a couple of new functions.
```lua
lurker.useShaderReload(true)
-- must use slashes as separators (same as love.graphics.newShader)
local shader = require "shaders/someShader.glsl"

function love.draw()
    love.graphics.setShader(shader) -- works
    shader:set() -- alternatively

    shader:send("someUniform", 42)  -- works
    -- alternatively, does nothing if no such uniform
    shader:trySend("someUniform", 42)

    --draw stuff

    love.graphics.setShader()
end
```

### lurker.protected
Dictates whether lurker should run in protected mode; this is `true` by
default. If protected mode is disabled then LÖVE's usual error screen is used
when an error occurs in a LÖVE callback function; if it is enabled then
lurker's error state (which continues watching for file changes and can resume
execution) is used. Changes to this variable should be made before any calls to
lurker.update() are made.

### lurker.quiet
Dictates what should happen if lurker tries to load a file which contains a
syntax error. If it is `false` then lurker's error screen is shown until the
syntax error is fixed; if it is `true` the error message is printed to the
console and the program continues. lurker.quiet is `false` by default.

### lurker.interval
The interval in seconds for how often the scan of the directory is performed.
This is `.5` by default.

### lurker.path
The directory which is scanned for changes. This is `.` (The project's root) by
default.
