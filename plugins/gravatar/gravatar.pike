import Tools.Logging;
import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name="Gravatar support";

int _enabled = 1;

mapping(string:Public.Web.Wiki.Macros.Macro) query_macro_callers()
{
  return (["gravatar": generate_gravatar_url()]);
}

void start()
{
  Log.info("Adding Simple Macro gravatar.");
  app->view->add_simple_macro("gravatar", simple_macro_gravatar);
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
    array a = (params->parameters/"|");
    string email = a[0];

    email = String.trim_whites(email);

    r += String.string2hex(Crypto.MD5.hash(email));

    if(sizeof(a) > 1)
    {
      mapping ar = ([]);

      foreach(a[1..];; string arg)
      {
        string argument, value;
        if(sscanf(arg, "%s=%s", argument, value) != 2) continue;

        ar[argument] = value;
        if(argument == "default") value = Protocols.HTTP.http_encode_string(value);
        r = r + "&" + argument + "=" + value;
      }
    }

    r+="\">";

    return ({r});
  }

}


  string simple_macro_gravatar(Fins.Template.TemplateData data, mapping|void arguments)
  {
    string r = "<img src=\"http://www.gravatar.com/avatar.php?gravatar_id=";

    if(!arguments) return "";

    string email = String.trim_whites(arguments->email || app->view->get_var_value(arguments->var, data->get_data()));

    r += String.string2hex(Crypto.MD5.hash(email));

    m_delete(arguments, "email");
    foreach(arguments; string argument; string value)
    {
      if(argument == "default") value = Protocols.HTTP.http_encode_string(value);
        r = r + "&" + argument + "=" + value;
    }

    r+="\">";

    return r;
  }

