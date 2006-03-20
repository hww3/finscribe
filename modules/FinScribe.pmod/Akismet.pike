//! An interface to the Akismet SPAM Filtering service.

string apiKey;
string blogName;
string verified;

//!
static void create(string key, string blog)
{
  apiKey = key;
  blogName = blog;
}

//!
int verify()
{
  string url = "http://rest.akismet.com/1.1/verify-key";
  mapping vars = (["blog": blogName, "key": apiKey]);

  string res = Protocols.HTTP.post_url_data(url, vars);
  
  verified = (res == "valid");

  return verified;
}

static int callAkismet(string func, mapping dta)
{
  string url = "http://" + apiKey + ".rest.akismet.com/1.1/" + func;
  return (Protocols.HTTP.post_url_data(url, dta) != "false");
}

static mapping check_args(mapping dta)
{
  string fn = "";

  if(!dta->blog || !strlen(dta->blog))
    (fn="blog") && goto err;

  if(!dta->user_ip || !strlen(dta->user_ip))
    (fn="user_ip") && goto err;

  if(!dta->user_agent || !strlen(dta->user_agent))
    (fn="user_agent") && goto err;

  err:
    throw(Error.Generic("invalid args: " + fn + " is required.\n"));
}

//!
//! @mapping dta
//!   blog
//!   user_ip
//!   user_agent
//!   referrer
//!   permalink
//!   comment_type
//!   comment_author
//!   comment_author_email
//!   comment_author_url
//!   comment_content
//! @endmapping
public int check_comment(mapping dta)
{
  return callAkismet("comment-check", check_args(dta));
}

//!
public int submit_spam(mapping dta)
{
  return callAkismet("submit-spam", check_args(dta));
}

//!
public int submit_ham(mapping dta)
{
  return callAkismet("submit-ham", check_args(dta));
}
