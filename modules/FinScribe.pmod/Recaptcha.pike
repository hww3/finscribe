
string verify_url = "http://api-verify.recaptcha.net/verify";
private string pkey;
private string response_error;

//!
void create(string private_key)
{
  pkey = private_key;
}


//!
string get_error()
{
  return response_error;
}

//! @returns
//!   1 on success, 0 on failure. use @get_error to get the error string.
int validate(string challenge, string response, string remoteip)
{
  mapping v = ([]);

  v->privatekey = pkey;
  v->remoteip = remoteip;
  v->challenge = challenge;
  v->response = response;

  //werror("v: %O\n", v);
  
  object q = Protocols.HTTP.post_url(verify_url, v);

  if(!q) return 0;
  
  string resp = q->data();

  array x = resp/"\n";

  if(!x || !x[0] || (x[0] != "true"))
  {
    response_error=x[1..]* "\n";    
    return 0;
  }

  //werror("q: %O\n", q);
  //werror("response: %O\n", q->data());

  return 1;
}
