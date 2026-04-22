require 'xmlrpc/client'

verbose = $VERBOSE
$VERBOSE = nil
XMLRPC::Config.const_set(:ENABLE_NIL_PARSER, true)
XMLRPC::Config.const_set(:ENABLE_BIGINT, true)
$VERBOSE = verbose
