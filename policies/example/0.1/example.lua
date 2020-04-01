local setmetatable = setmetatable

local _M = require('apicast.policy').new('Example', '0.1')
local mt = { __index = _M }

local cjson = require('cjson.safe')
local http_ng = require 'resty.http_ng'

function _M.new()
  self.config = config or {}
  self.http_client = http_ng.new{
    backend = config.client
  }
  
  ngx.log(ngx.INFO, 'example policy new')

  return setmetatable({}, mt)
end

function _M:init()
  -- do work when nginx master process starts
end

function _M:init_worker()
  -- do work when nginx worker process is forked from master
end

function _M:rewrite()
  -- change the request before it reaches upstream
end

function _M:access()
  -- ability to deny the request before it is sent upstream
  local res, err = self.http_client.post{'https://sippe-acl.requestcatcher.com/test' , { data = 'sent from 3scale policy'}, headers = {['Authorization'] = 'admin:admin'}}
  
  if err then
    ngx.log(ngx.WARN, 'error post ACL')
  end

  ngx.log(ngx.INFO, 'example policy access')

  return true
end

function _M:content()
  -- can create content instead of connecting to upstream
end

function _M:post_action()
  -- do something after the response was sent to the client
end

function _M:header_filter()
  -- can change response headers
end

function _M:body_filter()
  -- can read and change response body
  -- https://github.com/openresty/lua-nginx-module/blob/master/README.markdown#body_filter_by_lua
end

function _M:log()
  -- can do extra logging
end

function _M:balancer()
  -- use for example require('resty.balancer.round_robin').call to do load balancing
end

return _M
