import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name = "Gravatar support";
constant type = "gravatar";

int _enabled = 1;

mapping(string:Public.Web.Wiki.Macros.Macro) query_macro_callers()
{
  return (["gravatar": generate_gravatar_url()]);
}

void start()
{
  logger->info("Adding Simple Macro gravatar.");
  app->view->add_macro("gravatar", simple_macro_gravatar);
}

class generate_gravatar_url
{

  inherit Public.Web.Wiki.Macros.Macro;

  int is_cacheable()
  {
    return 1;
  }

  string describe()
  {
     return "Displays a GRAvatar image.";
  }

  array evaluate(Public.Web.Wiki.Macros.MacroParameters params)
  {
    string r = "<img src=\"http://www.gravatar.com/avatar.php?gravatar_id=";
    if(!params->args) params->make_args();
    
    string email;

    if(params->args->email) email = params->args->email;
    else email = indices(params->args)[-1];

    email = String.trim_whites(email);

    r += String.string2hex(Crypto.MD5.hash(email));

    m_delete(params->args, "email");

      foreach(params->args; string arg; string val)
      {

        if(arg == "default") val = Protocols.HTTP.uri_encode(val);
        r = (r + "&" + arg + "=" + val);
      }

    r+="\">";

    return ({r});
  }

}


  string simple_macro_gravatar(Fins.Template.TemplateData data, mapping|void arguments)
  {
    string r = "http://www.gravatar.com/avatar.php?gravatar_id=";

    if(!arguments->url) r = "<img src=\"" + r;

    string email = String.trim_whites(arguments->email || app->view->get_var_value(arguments->var, data->get_data()));

    r += String.string2hex(Crypto.MD5.hash(email));

    m_delete(arguments, "email");
    foreach(arguments; string argument; string value)
    {
      if(argument == "default") value = Protocols.HTTP.uri_encode(value);
        r = r + "&" + argument + "=" + value;
    }

    if(!arguments->url)
      r+="\">";

    return r;
  }

