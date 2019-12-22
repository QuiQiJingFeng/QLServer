local skynet = require "skynet"
local cluster = require "skynet.cluster"
local snax = require "skynet.snax"

skynet.start(function()
	cluster.reload {
		db = "127.0.0.1:2528",
		db2 = "127.0.0.1:2529",
	}

	local sdb = skynet.newservice("simpledb")
	-- register name "sdb" for simpledb, you can use cluster.query() later.
	-- See cluster2.lua
	--将本地服务sdb暴露到公共接口中,这样其他结点能通过监听的端口来调用暴露出来的API
	cluster.register("sdb", sdb)

	print(skynet.call(sdb, "lua", "SET", "a", "foobar"))
	print(skynet.call(sdb, "lua", "SET", "b", "foobar2"))
	print(skynet.call(sdb, "lua", "GET", "a"))
	print(skynet.call(sdb, "lua", "GET", "b"))

	--FYD1 cluster1结点开启了两个监听端口,分别是db和db2,用来监听网络中的其他结点的调用
	cluster.open "db"
	cluster.open "db2"
	-- unique snax service
	snax.uniqueservice "pingserver"
end)
