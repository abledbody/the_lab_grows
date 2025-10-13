--[[pod_format="raw",created="2024-05-01 05:10:49",modified="2025-05-26 18:53:33",revision=185]]
local _modules = {}

function require(name)
  if _modules[name] == nil then
    _modules[name] = include(name:gsub ('%.', '/') ..'.lua')
  end
  return _modules[name]
end