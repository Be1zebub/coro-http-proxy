local proxy = require("coro-http-proxy")
local base64 = require("base64")

local response, body = proxy.request({
	host = "1.1.1.1",
	port = "1234",
	authorization = "Basic ".. base64.encode("user:password"),
	keepalive = false
}, "GET", "http://incredible-gmod.ru/ping.php")

p(response and response.code, body)
p(response)