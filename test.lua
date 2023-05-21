local proxy = require("coro-http-proxy")

p(
	proxy.request({
		host = "5.161.219.69",
		port = "8080",
		keepalive = false
	}, "GET", "http://incredible-gmod.ru/ping.php")
)