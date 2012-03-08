string url = "http://localhost:8124";
string type;
string name = "default";
protected string auth;

protected object c; // the client

protected void create(string|void index_url, string|void index_name, string _auth)
{
  if(index_url) 
    url = index_url;
  if(index_name)
    name = index_name;
  auth = _auth;

  if(!type) throw(Error.Generic("Cannot instantiate BaseClient directly!\n"));
}

protected Protocols.XMLRPC.Client get_client()
{
  if(c) return c;

  object u = Standards.URI("/" + type + "/", Standards.URI(url));
  u->add_query_variable("PSESSIONID", "123");
  return c = Protocols.XMLRPC.Client(u);
}

protected mixed call(string func_name, mixed ... args)
{
  mixed r;

  get_client();

  r = c[func_name](@args);

  if(objectp(r))
    throw(.RemoteError(r));
  else return r[0];
}

protected mixed index_call(string func_name, mixed ... args)
{
  return auth_call(func_name, name, @args);
}

protected mixed auth_call(string func, mixed ... args)
{
  return call(func, auth, @args);
}


