inherit .BaseClient;

string type="admin";

//!
static void create(string|void index_url, string authcode)
{
  ::create(index_url, 0, authcode); // we store auth in name field for now.
}


//!
int shutdown(int delay)
{
  return auth_call("shutdown", delay);
}

//!
string grant_access(string index)
{
  return auth_call("grant_access", index);
}

//!
string exists(string index)
{
  return auth_call("exists", index);
}

//!
int revoke_access(string index, string authcode)
{
  return auth_call("revoke_access", index, authcode);
}

