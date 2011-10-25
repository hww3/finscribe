import Fins;
inherit Fins.FinsView;
import Tools.Logging;

program default_template = (program)"themed_template";
program default_data = (program)"themed_templatedata";

mapping included_snips = ([]);

void start()
{
  app->add_event_handler("postSave", snip_updated);
}

int snip_updated(string event, object id, object obj)
{
  if(included_snips[obj["path"]])
  {
    flush_templates();
  }
  return 0;
}

public Template.View get_idview(string tn, object id)
{
  object t;

  t = get_view(tn);
  t->data->request = id;

  // NOTE
  // we use a shared copy of the data mapping
  // so we must be careful to not use += on it!
  if(id && id->misc)
    id->misc->template_data = t->get_data();
  t->get_data()->id = id;

  return t;  
}

//! args: content, object, force (optional)
string simple_macro_render(Fins.Template.TemplateData data, mapping|void args)
{
  if(!args->content || !args->object) return "render macro missing content or object arguments";

  string contents = args->content;
  mixed obj = args->entry;

  object request = data->get_request();
//  if(!request->misc->template_data)
//    request->misc->template_data = data;

  return app->render(contents, obj, request, (int)args->force);
}

// args: name, val
string simple_macro_list_store(Fins.Template.TemplateData data, mapping|void args)
{
//werror("*\n*\n*\n list_store: %O\n", args->name);
  if(args->name)
  {
    mixed d = data->get_data();
    list_store(d, args->name, args->val); 
  }  

//werror("d: %O\n");

  return "";
}

void list_store(mapping data, string name, mixed value)
{
  if(!data[name]) data[name] = ({});
    data[name] += ({ value });
}

//! args: var, separator (optional)
string simple_macro_list_retrieve(Fins.Template.TemplateData data, mapping|void args)
{
  mixed contents;
  if(args->var)
    contents = args->var;

  if(contents && arrayp(contents) && sizeof(contents))
  {
    return contents * (args->separator||"\n");
  }
  else return "";
}


string simple_macro_fontlock(Fins.Template.TemplateData data, mapping|void args)
{
  string contents = "";

  if(args->var)
    contents = args->var;

  function hilite = FontLock.Pike.highlight;

  if(args->type)
  {
    if(FontLock[String.capitalize(args->type)])
      hilite = FontLock[String.capitalize(args->type)]["hilite"];
  }

  if(hilite)
    return hilite(contents);
 
  else return contents;
}

string simple_macro_syspref(Fins.Template.TemplateData data, mapping|void arguments)
{
  if(arguments->var)
  {
    object p = app->new_string_pref(arguments->var, arguments->val || 
                                         arguments->var);

    if(!p) return "";

    if(!arguments->val)
      return p["value"];
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
  return get_page_breadcrumbs(args->var||args->val||"");
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
   mixed rv;

   if(!mappingp(args)) return "";
   if(!args->snip) return "";
   object obj = model->get_fbobject((args->snip)/"/");
   object id = data->get_request();   

   if(!obj) return "";

   included_snips[obj["path"]] = 1;
   string contents = obj->get_object_contents();

   rv = app->render(contents, obj, id);

   return rv;
}

string simple_macro_theme(Template.TemplateData data, mapping|void args)
{
   if(!mappingp(args) || !args->show) return "";
   if(args->show == "path") return "/theme/" + 
             app->get_theme(data->get_request()) + "/";

   return "";
}

string simple_macro_friendly_size(Template.TemplateData data, mapping|void args)
{
  if(args->size)
  {
    int size = (int)args->size;
    if(size < 1024) return size + " bytes";
    if(size < 1024*1024) return sprintf("%.1f KB", size/1024.0);
    if(size < 1024*1024*1024) return sprintf("%.2f MB", size/(1024.0*1024.0));
    if(size < 1024*1024*1024*1024) return sprintf("%.12f GB", size/(1024.0*1024.0*1024.0));
  }
  else return "--";
}
 
  


//! display a calendar object as a date and time in a friendly manner
//!
//! args: var
string simple_macro_describe_news_date(Fins.Template.TemplateData data, mapping|void args)
{
  if(args->var && args->var->format_ymd)  
    return args->var->format_ymd();
  else return "N/A";
} 
