---@meta

---@alias JavaLaunchOptions string|string[]
---@alias JavaLaunchEnvFile string|string[]
---@alias JavaLaunchEnv table<string, string|number|boolean>

---@class JavaLaunchMainConfig
---@field vmOptions? JavaLaunchOptions JVM options appended for this Main class
---@field envFile? JavaLaunchEnvFile Environment files loaded before launch
---@field env? JavaLaunchEnv Environment variables overriding values from envFile

---@class JavaLaunchConfig
---@field vmOptions? JavaLaunchOptions JVM options shared by all Main classes
---@field envFile? JavaLaunchEnvFile Environment files loaded before launch
---@field env? JavaLaunchEnv Environment variables overriding values from envFile
---@field mainClass? table<string, JavaLaunchMainConfig|JavaLaunchOptions> Settings keyed by the fully qualified Main class name
