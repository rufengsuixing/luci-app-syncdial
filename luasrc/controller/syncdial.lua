module("luci.controller.syncdial",package.seeall)
function index()
if not nixio.fs.access("/etc/config/syncdial")then
return
end
local e
e=entry({"admin","network","syncdial"},cbi("syncdial"),_("Multi-Syncdial"),103)
e.dependent=true
e=entry({"admin","network","macvlan_redial"},call("redial"),nil)
e.leaf=true
end
function redial()
os.execute("killall pppd")
end
