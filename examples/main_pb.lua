local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cjson = require "cjson"
local max_client = 64

skynet.start(function()
	skynet.error("Server start111")
	local pb = require "pb"
	assert(pb.loadfile "proto/protocol.pb") -- 载入刚才编译的pb文件
	local content = {
		sessionId = 1024,
		Handshake = {
			v1 = "FYD1",
			v2 = "FYD2"
		}
	}
	local buffer = pb.encode("C2S", content)
	local msessage = pb.decode("C2S",buffer)
	print(cjson.encode(msessage))
	skynet.exit()
end)
