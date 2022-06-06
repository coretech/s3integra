local cjson = require "cjson"
-- check request content
if  ngx.req.get_headers()["Content-Type"] ~= 'application/json' then 
	ngx.say(cjson.encode({"error","bad content type"})); 
	return 
end
-- get request body
ngx.req.read_body();
local message = ngx.req.get_body_data();
-- json decode exeption
-- local jreq = cjson.decode(message)
local success, res = pcall(cjson.decode, message);
if success then
-- res contains a valid json object
    jreq = res
else
-- res contains the error message
    ngx.say(res)
    return
end
-- wrong data in json
if jreq['data'] == nil or jreq['action'] == nil or jreq['action_id'] == nil or jreq['data']['filename'] == nil  then 
    ngx.say(cjson.encode({'error','wrong data in json'}))
    return
end
-- json parce
local filename = jreq['data']['filename']
local action = jreq['action']
local action_id = jreq['action_id']
-- variables
local basedir = "/usr/local/freeswitch"
local localfile = basedir .. filename
local resp_json = {}
-- prepare responce json
resp_json['action'] = action
resp_json['action_id'] = action_id
--resp_json['last_error'] = ''
resp_json['last_data'] = ''
resp_json['timestamp'] = os.time(os.date("!*t"))
-- try to open file
local f = io.open(localfile,"r")
-- check record file
if f == nil  then
    resp_json['last_data'] = 'file_not_found'
    ngx.say(cjson.encode(resp_json))
    return
end
-- check exist proceses uplod recordfile
ps_string = string.format("ps -axu | grep \'%s\' | grep -v grep | grep -v curl | wc -l", filename)
local handle = io.popen(ps_string)
local exist_ps = handle:read("*a")
handle:close()
--ngx.say(exist_ps)
if tonumber(exist_ps) > 0 then 
    resp_json['last_data'] = 'file_already_uploading'
    ngx.say(cjson.encode(resp_json))
    return
end
-- for s3 file store
if  action == 'pbx.s3.store' then
    local popenline = string.format("/root/s3_python/bin/python /root/s3_python/ptests3.py \'%s\' &" ,  message )
    os.execute(popenline)
--    local handle = io.popen(popenline)
--    local result = handle:read("*a")
--    handle:close()
--    io.close(f)
    resp_json['last_data'] = 'upload_started'
    ngx.say(cjson.encode(resp_json))
    return
end
-- delete local file
if action == 'pbx.local.delete' then
    io.close(f)
    os.remove(localfile)
--    local handle = io.popen(popenline)
--    local result = handle:read("*a")
--    handle:close()
    resp_json['last_data'] = 'file_deleted'
    ngx.say(cjson.encode(resp_json))
    return
end 

resp_json['last_error'] = 'unknown_error'
ngx.say(cjson.encode(resp_json))
return

