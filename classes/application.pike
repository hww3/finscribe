import Fins;
inherit Fins.Application;
import Fins.Model;

object model;

Public.Web.Wiki.RenderEngine engine;

static void create(Fins.Configuration config)
{
  add_constant("application", this);
  add_constant("get_object_name", get_object_name);
  add_constant("get_object", get_object);
  add_constant("get_blog_entries", get_blog_entries);
  add_constant("get_object_title", get_object_title);
  add_constant("get_object_contents", get_object_contents);
  add_constant("get_when", get_when);  

  load_wiki();
  load_model();

  Template.add_simple_macro("breadcrumbs", macro_breadcrumbs);
  Template.add_simple_macro("snip", macro_snip);
  
  ::create(config);
}

void load_wiki()
{
   engine = ((program)"wikiengine")(this);
}

void load_model()
{

   model = ((program)"model")();

}

string macro_breadcrumbs(Template.TemplateData data, string|void args)
{
  return get_page_breadcrumbs(data->get_data()[args]||"");
}

string macro_snip(Template.TemplateData data, string|void args)
{
   object obj = get_object(args/"/");

   if(!obj) return "";

   string contents = get_object_contents(obj);

   return engine->render(contents);
}


string get_page_breadcrumbs(string page)
{
  array s = ({});
  string newcomponent;
  array p = page/"/";

  // in this application, if we're at the root, 
  // we don't have any place left to go.
  if(sizeof(p) == 1 && p[0]=="start") return "";

  if(p[0] != "start")
    p = ({"start"}) + p;

  foreach(p; int i; string component)
  {
    if(newcomponent)
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

private string get_when(object c)
{
   string howlongago;

   c = c->distance(Calendar.now());
      
   if(c->number_of_minutes() < 3)
   {
      howlongago = "Just a moment ago";
   }
   else if(c->number_of_minutes() < 60)
   {
      howlongago = c->number_of_minutes() + " minutes ago";
   }
   else if(c->number_of_hours() < 24)
   {
      howlongago = c->number_of_hours() + " hours ago";
   }
   else
   {
      howlongago = c->number_of_days() + " days ago";
   }

   return howlongago;
}

array get_blog_entries(string obj)
{
  array o = Model.find("object", ([ "is_attachment": 2,
                          "path": Model.LikeCriteria(obj + "/%"),
                          "_page": Model.Criteria("LOCATE('/', path, " + (strlen(obj)+2) + ")") ]),
                        Model.Criteria("ORDER BY path DESC"));

  // ok, that gives us a good guess; let's narrow it down a bit.

  o = Array.filter(o, lambda(mixed e){ if(sscanf(e["path"], obj + "/%*4d-%*2d-%*2d/%*d/%*1s") ==4) return 1; });
  
  return o;

}

string get_object_name(string obj)
{
   return (obj/"/")[-1];
}

private object get_object(array args, Request|void id)
{
   array r = Model.find("object", (["path": args*"/"]));

   if(sizeof(r))
     return r[0];
   else return 0;
}

private string get_object_title(object obj, Request|void id)
{
   string t = obj["current_version"]["subject"];
   return (t && sizeof(t))?t:get_object_name(obj["path"]);
}

private string get_object_contents(object obj, Request|void id)
{

   return obj["current_version"]["contents"];
}
