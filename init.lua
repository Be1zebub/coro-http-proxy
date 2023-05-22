local http = require("coro-http")

local function chain(connection, url)
	local uri = http.parseUrl(url)

	connection.host = uri.host
	connection.port = uri.port
	connection.tls = uri.tls
	connection.reset()

	http.saveConnection(connection)
end

local function connect(proxy, url)
	local uri = http.parseUrl(url)
	local from = uri.host ..":".. uri.port
	local connection = http.getConnection(proxy.host, proxy.port, proxy.tls)

	local data = {
	    method = "CONNECT",
	    path = from,
	    {"Host", from},
		{"proxy-connection", proxy.keepalive ~= false and "keep-alive" or "close"}
	}

	if proxy.authorization then
		data[#data + 1] = {"proxy-authorization", proxy.authorization}
	end

	connection.write(data)

	local response = connection.read()
	if response and response.code == 200 then
		chain(connection, url)
		return connection
	else
		connection.socket:close()
		return false, response.code
	end
end

local function request(proxy, method, url, headers, body, customOptions)
	local connection, reason = connect(proxy, url)
	if connection == false then p("coro-http-proxy connect error ".. reason) return end

	local response, body = http.request(method, url, headers, body, customOptions)
	connection.socket:close()

	return response, body
end

return {
	connect = connect,
	chain 	= chain,
	request = request
}