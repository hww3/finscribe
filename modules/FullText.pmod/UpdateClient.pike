inherit .BaseClient;

string type="update";

//!
static void create(string|void index_url, string|void index_name, string auth, int|void create_if_new)
{
  ::create(index_url, index_name, auth);
  int e = exists(name);
  if(!e && create_if_new)
    new(name);
  else if(!e)
    throw(Error.Generic("UpdateClient(): index " + name + " does not exist.\n"));
}

//!
int new(string name)
{
  return auth_call("new", name);
}

//!
int exists(string name)
{
  return call("exists", name);
}

//!
int delete_by_handle(string handle)
{
  return index_call("delete_by_handle", handle);

}

//!
int delete_by_uuid(string uuid)
{
  return index_call("delete_by_uuid", uuid);
}

//!
string add(string title, Calendar.Second date, string contents, string handle, string|void excerpt, string mimetype)
{
  return index_call("add", title, date->unix_time(), MIME.encode_base64(contents), handle, excerpt, mimetype);
}

//!
string add_from_map(mapping doc)
{  
  return index_call("add_from_map", doc);
}
