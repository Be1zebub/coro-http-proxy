local proxy = require("coro-http-proxy")

local response, body = proxy.request({
	host = "138.68.60.8",
	port = "3128",
	keepalive = false
}, "GET", "http://incredible-gmod.ru/ping.php")

p(response and response.code, body)