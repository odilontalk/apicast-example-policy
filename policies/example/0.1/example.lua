local _M = require('apicast.policy').new('Example', '0.1')
local cjson = require('cjson')
local http_ng = require 'resty.http_ng'
local re = require('ngx.re')

local new = _M.new

function _M.new(config)
  local self = new(config)
  
  self.config = config or {}
  self.http_client = http_ng.new{
    backend = config.client
  }
  
  ngx.log(ngx.INFO, '>>> example policy new')

  return self
end

function _M:access(context)
  -- ability to deny the request before it is sent upstream
  local res, err = self.http_client.json.post{'https://auth-cb405.uat.sippe.com.br/v1/acl/auth/token/validate-resource-access-status', 
    { 
      url = ngx.var.uri, 
      token = re.split(ngx.req.get_headers()['Authorization'], " ")[2], 
      method = ngx.req.get_method() 
    }
  }

  if err then
    ngx.log(ngx.WARN, '>>> error with ACL: ', err)
  end

  ngx.log(ngx.INFO, '>>> acl response status: ', res.status)
  ngx.log(ngx.INFO, '>>> last request headers: ', self.http_client.last_request.headers)
  ngx.log(ngx.INFO, '>>> last request body: ', self.http_client.last_request.body)
  
  local ok = (res.status == 200) 
  
  if not ok then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end

  return ok
end

return _M
