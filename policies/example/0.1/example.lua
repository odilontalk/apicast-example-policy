local _M = require('apicast.policy').new('Example', '0.1')
local cjson = require('cjson')
local http_ng = require 'resty.http_ng'

local new = _M.new

function _M.new(config)
  local self = new(config)
  
  self.config = config or {}
  self.http_client = http_ng.new{
    backend = config.client
  }
  
  ngx.log(ngx.INFO, 'example policy new')

  return self
end

function _M:access(context)
  -- ability to deny the request before it is sent upstream
  local res, err = self.http_client.post{'https://sippe-acl.requestcatcher.com/test' , { data = 'sent from 3scale policy'}, headers = {['Authorization'] = 'admin:admin'}}
  
  if err then
    ngx.log(ngx.WARN, 'error post ACL')
  end

  ngx.log(ngx.INFO, 'example policy access')

  return true
end

return _M
