local http = require("coro-http")

local function connect(proxy)
	local connection = http.getConnection(proxy.host, proxy.port, proxy.tls)
	local data = {
	    method = "CONNECT",
	    path = proxy.path or "/",
	    {"Host", proxy.host},
		{"proxy-connection", proxy.keepalive ~= false and "keep-alive" or "close"}
	}

	if proxy.authorization then
		data[#data + 1] = {"proxy-authorization", proxy.authorization}
	end

	connection.write(data)

	local response = connection.read()
	if response and response.code == 200 then
		return connection
	else
		connection.socket:close()
	end
end

local function chain(connection, url)
	local requestURI = http.parseUrl(url)

	connection.host = requestURI.host
	connection.port = requestURI.port
	connection.tls = requestURI.tls
	connection.reset()

	http.saveConnection(connection)
end

local function request(proxy, method, url, headers, body, customOptions)
	local connection = connect(proxy)
	if connection == nil then return end

	chain(connection, url)

	local response, body = http.request(method, url, headers, body, customOptions)
	connection.socket:close()

	return response, body
end

return {
	connect = connect,
	chain 	= chain,
	request = request
}