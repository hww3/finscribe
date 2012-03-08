inherit Error.Generic;

constant __is_xmlrpc_remote_error = 1;

Protocols.XMLRPC.Fault fault;

static void create(Protocols.XMLRPC.Fault e)
{
  fault = e;
  ::create("Remote Error: " + e->fault_string);
  error_backtrace = error_backtrace[..<1];
  // we really don't need to show the call to create().
}
