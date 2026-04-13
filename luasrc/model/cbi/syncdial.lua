require("luci.tools.webadmin")
local cmd = "for f in /var/run/mwan3track/vwan*/STATUS; do [ -f \"$f\" ] && [ \"$(cat $f)\" = \"online\" ] && echo ok; done 2>/dev/null | grep -c ok"
local f = io.popen(cmd, "r")
local t = f and f:read("*a") or "0"
if f then f:close() end
t = t:match("%d+") or "0"
m=Map("syncdial",translate("Multi-Syncdial"),
translate("Create multiple virtual WAN interfaces using macvlan driver for concurrent dialing")..
" <br />"..translate("Current online interface count: ")..t)
s=m:section(TypedSection,"syncdial",translate(" "))
s.anonymous=true
o=s:option(Flag,"enabled",translate("Enable"))
o.rmempty=false
o=s:option(Flag,"syncon",translate("Enable concurrent dialing"))
o.rmempty=false
o=s:option(ListValue,"dial_type",translate("Dial type"))
o:value("1",translate("Single-line multi-dial"))
o:value("2",translate("Dual-line multi-dial"))
o.rmempty=false
o=s:option(Value,"wanselect",translate("Select WAN interface"),translate("Specify the WAN interface for multi-dial, e.g. wan"))
luci.tools.webadmin.cbi_add_networks(o)
o.optional=false
o.rmempty=false
o=s:option(Flag,"ipv6",translate("Enable IPv6"))
o.rmempty=false
o=s:option(Value,"wannum",translate("Number of virtual WAN interfaces"))
o.datatype="range(0,249)"
o.optional=false
o.default=1
o=s:option(Flag,"bindwan",translate("Bind to physical interface"))
o.rmempty=false
o=s:option(Value,"wanselect2",translate("Select second WAN interface"),translate("<font color=\"red\">Specify the second WAN interface for multi-dial, e.g. wan2</font>"))
luci.tools.webadmin.cbi_add_networks(o)
o.optional=false
o:depends("dial_type","2")
o=s:option(Value,"wannum2",translate("Second line virtual WAN count"),translate("Number of virtual interfaces for the second line"))
o.datatype="range(0,249)"
o.optional=false
o.default=1
o:depends("dial_type","2")
o=s:option(Flag,"bindwan2",translate("Bind to physical interface"),translate("Bind second line virtual interfaces to physical interface"))
o.rmempty=false
o:depends("dial_type","2")
o=s:option(Flag,"dialchk",translate("Enable disconnect detection"))
o.rmempty=false
o=s:option(Value,"dialnum",translate("Minimum online interfaces"),translate("Redial if online interface count is below this value (each IPv6 also counts as one)"))
o.datatype="range(0,248)"
o.optional=false
o.default=2
o=s:option(Value,"dialnum2",translate("Second line minimum online interfaces"),translate("Redial if second line online interface count is below this value (each IPv6 also counts as one)"))
o.datatype="range(0,248)"
o.optional=false
o.default=2
o:depends("dial_type","2")
o=s:option(Value,"dialwait",translate("Redial wait time"),translate("Wait time after all interfaces go down before next dial attempt. Unit: seconds, minimum: 5"))
o.datatype="and(uinteger,min(5))"
o.optional=false
o=s:option(Flag,"old_frame",translate("Use legacy macvlan creation mode"))
o.rmempty=false
o=s:option(Flag,"nomwan",translate("Do not auto-configure MWAN3 load balancing"),translate("Select this if you need custom load balancing or policy routing"))
o.rmempty=false
o=s:option(DummyValue,"_redial",translate("Concurrent redial"))
o.template="syncdial/redial_button"
o.width="10%"
return m
