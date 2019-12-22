local skynet = require "skynet"
local cluster = require "skynet.cluster"

skynet.start(function()
	--创建远程结点服务的代理
	local proxy = cluster.proxy "db@sdb"	-- cluster.proxy("db", "@sdb")
	local largekey = string.rep("X", 128*1024)
	local largevalue = string.rep("R", 100 * 1024)
	--调用远程结点暴露的API
	skynet.call(proxy, "lua", "SET", largekey, largevalue)
	local v = skynet.call(proxy, "lua", "GET", largekey)
	assert(largevalue == v)
	skynet.send(proxy, "lua", "PING", "proxy")

	skynet.fork(function()
		skynet.trace("cluster")
		print(cluster.call("db", "@sdb", "GET", "a"))
		print(cluster.call("db2", "@sdb", "GET", "b"))
		cluster.send("db2", "@sdb", "PING", "db2:longstring" .. largevalue)
	end)

	-- test snax service
	skynet.timeout(300,function()
		--实时更新网络中的结点
		cluster.reload {
			db = false,	-- db is down
			db3 = "127.0.0.1:2529"
		}
		--当远程结点挂掉的时候调用会报错,并且打印调用堆栈 
		--cluster node [db] is down
		print(pcall(cluster.call, "db", "@sdb", "GET", "a"))	-- db is down
	end)
	cluster.reload { __nowaiting = false }
	local pingserver = cluster.snax("db3", "pingserver")
	print(pingserver.req.ping "hello")
end)
