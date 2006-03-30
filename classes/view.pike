import Fins;
inherit Fins.FinsView;

string simple_macro_syspref(Fins.Template.TemplateData data, mapping|void arguments)
{
  if(arguments->var)
  {
    object p = app->get_sys_pref(arguments->var);

    if(!p) return "";

    if(!arguments->val)
      return p["Value"];
  }
}

string simple_macro_folding_div(Fins.Template.TemplateData data, mapping|void arguments)
{
  String.Buffer b = String.Buffer();

  b+="<a id='";
  b+=arguments["name"];
  b+=" onclick=\"toggleVisibility('";
  b+=arguments["name"];
  b+="')\"><img id=\"icon-";
  b+=arguments["name"];
  b+="\" src=\"/static/images/Icon-Unfold.png\" border=\"0\">";

  b+=arguments["title"];
  b+="<br/><div id=\"";
  b+=arguments["name"];
  b+="\" style=\"display:none;margin-left:20px\">";

  return b->get();
}

string simple_macro_breadcrumbs(Template.TemplateData data, mapping|void args)
{
  if(!mappingp(args)) return "";
  return get_page_breadcrumbs(get_var_value(args->var, data->get_data())||args->val||"");
}

string get_page_breadcrumbs(string page)
{
  array s = ({});
  string newcomponent;
  array p = page/"/";

  // in this application, if we're at the root, 
  // we don't have any place left to go.
  if(sizeof(p) == 1 && (p[0]=="start" || p[0] == "admin")) return "";

  if(p[0] != "start" && p[0] != "admin")
    p = ({"start"}) + p;

  foreach(p; int i; string component)
  {
    if(newcomponent && !(i==1))
      newcomponent=newcomponent+"/" + component;
    else
      newcomponent = component;

    if(i == (sizeof(p)-1))
      s += ({ component });
    else
      s += ({ "<a href=\"/space/" + newcomponent + "\">" + component + "</a>" });
  }

  return (s * " &gt; ");
}

string simple_macro_snip(Template.TemplateData data, mapping|void args)
{
   if(!mappingp(args)) return "";
   if(!args->snip) return "";
   object obj = model->get_fbobject((args->snip)/"/");
   object id = data->get_request();

   if(!obj) return "";

   string contents = obj->get_object_contents();

   return app->render(contents, obj, id);
}

