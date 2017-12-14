require 'xmlrpc/client'

Kernel::silence_warnings do
  XMLRPC::Config.const_set(:ENABLE_NIL_PARSER, true)
  XMLRPC::Config.const_set(:ENABLE_BIGINT, true)
end
