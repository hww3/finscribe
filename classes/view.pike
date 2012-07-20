#charset utf8

import Fins;
import Tools.Logging;

inherit Fins.FinsView;
inherit Fins.Helpers.Macros.Pagination;

object logger = Tools.Logging.get_logger("fins.view");

program default_template = (program)"themed_template";
program default_data = (program)"themed_templatedata";

static void create(object app)
{
	::create(app);  
}

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

//! template: match all sub pages with this template name.
string simple_macro_list_subpages(Fins.Template.TemplateData data, mapping|void args)
{

  object request = data->get_request();
  mixed obj = request->misc->current_page_object;

  if(!obj) return "";
  if(!args->template) return "list_subpages: no template specified.";

  mapping criteria = (["template": args->template, "path": Fins.Model.LikeCriteria(obj["path"] + "/%") ]);
  array s = app->model->context->find->objects(criteria);

  string rv = "";

  if(request->misc->section)
    rv = request->misc->section + "»<br/>";

  foreach(s;;object sp)
  {
//werror("sp: %O, %O\n", sp["path"],  app->url_for_action(app->controller->space, ({sp["path"]})));
    rv += ("<a href=\"" + app->url_for_action(app->controller->space, ({sp["path"]})) + "\">" + sp["title"] + "</a><br/>");
  }
  return(rv);
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

//! args: var=preference name, val=default value for pref, store=variable to store the value in
string simple_macro_syspref(Fins.Template.TemplateData data, mapping|void arguments)
{
  if(arguments->var)
  {
    object p;
    if(arguments->type && arguments->type == "boolean")
      p = app->new_boolean_pref(arguments->var, arguments->val);
    else
      p = app->new_string_pref(arguments->var, arguments->val || 
                                         arguments->var);

    if(!p) return "";

    if(arguments->store)
    {
      mixed d = data->get_data();
      d[arguments->store] = p["typedvalue"];
      return "";
    }

    return p["typedvalue"];
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
             (args->name||app->get_theme(data->get_request())) + "/";

   return "";
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

//! split a string into an array
//!
//! args: var, on, val=variable to store the split into
string simple_macro_split_string(Fins.Template.TemplateData data, mapping|void args)
{

  if(args->var)  
  {
    mixed d = data->get_data();
    d[args->val] = (args->var)/(args->on);
//werror("split: %O\n", d[args->val]);
  }  


  return "";
} 


//! on a weblog page, display the source of the entries.
string simple_macro_blog_source(Fins.Template.TemplateData data, mapping|void args)
{
  mixed r;

  if((r = data->get_request()) && r->misc->object_is_weblog) 
    return r->misc->object_is_weblog["path"];
  else return "";
}


//! get a list of recent comments and store them in a variable.
string simple_macro_recent_comments(Fins.Template.TemplateData data, mapping|void args)
{
  mixed res;
  int max = 5;

  if(args->max) max = (int) args->max;  

  if(!args->store)
    return "recent_comments macro requires a variable to store in.";

  res = app->model->context->find->comments(([]), Fins.Model.CompoundCriteria(({Fins.Model.SortCriteria("created", "desc"), Fins.Model.LimitCriteria(max)}) ));

  mixed d = data->get_data();
  d[args->store] = res;
  return "";

  return "";
}


Tools.Mapping.MappingCache archive_data = Tools.Mapping.MappingCache(3600 * 3);

//! args: weblog, store, max
string simple_macro_archive_list(Fins.Template.TemplateData data, mapping|void args)
{
  mixed res;
  int max = 5;

  if(args->max)
    max = (int) args->max;

  if(max < 1 && max !=-1)
    return "archive_list macro: max, if provided, must be greater than zero.";

  if(!args->weblog)
    return "archive_list macro must be provided with path to desired weblog.";

  if(!args->store)
    return "archive_list macro requires a variable to store in.";

  if(!(res = archive_data[args->weblog])) 
  {
    logger->info("calculating archive buckets.");
    object root = app->model->context->find->objects_by_path(args->weblog);

    if(!root) return "archive_list macro could not retrieve weblog " + args->weblog + ".";

    mixed entries = root->get_blog_entries();

    mapping buckets = ([]);

    foreach(entries;;object entry)
    {
      buckets[entry["created"]->month()]++;
    }

    array x = ({});
    array y = ({});    

    foreach(buckets;object b;)
    {
      string cn = sprintf("%04d%02d", b->year_no(), b->month_no());
      x += ({ cn });
      y += ({(["month": b->format_nice(), "url": app->url_for_action(app->controller->exec->archive, ({args->weblog, b->year_no(), b->month_no()}), 0), "items": buckets[b] ]) });
    }

    sort(x, y);

    res = reverse(y);
    archive_data[args->weblog] = res;
  }

  if(max != -1 && sizeof(res) > max)
  res = res[0..max-1];

  mixed d = data->get_data();
  d[args->store] = res;
  return "";
}

Tools.Mapping.MappingCache feed_data = Tools.Mapping.MappingCache(600);

//! get an rss feed and store the items in a variable.
string simple_macro_rss_feed(Fins.Template.TemplateData data, mapping|void args)
{
  mixed res;
  int max = 5;

  if(args->max) max = (int) args->max;  

  if(!args->store)
    return "rss_feed macro requires a variable to store in.";
  if(!args->url)
    return "rss_feed macro requires a url to fetch.";

#if constant(Public.Parser.XML2) && constant(Public.Syndication)
  res = rss_fetch(args->url, max);
#else
  res = ({(["title": "RSS Feeds Unavailable - Install Public.Parser.XML2"])});
#endif
//werror("res: %O\n", res);
  mixed d = data->get_data();
  d[args->store] = res;
  return "";

  return "";
}


//! get an image rss feed (smugmug, flicker, etc)
string simple_macro_image_feed(Fins.Template.TemplateData data, mapping|void args)
{
  mixed res;
  int max = 5;

  if(args->max) max = (int) args->max;  

  if(!args->store)
    return "image_feed macro requires a variable to store in.";
  if(!args->url)
    return "image_feed macro requires a url to fetch.";

#if constant(Public.Parser.XML2) && constant(Public.Syndication)
  res = image_fetch(args->url, max);
#else
  res = ({(["title": "Image/RSS Feeds Unavailable - Install Public.Parser.XML2"])});
#endif
//werror("res: %O\n", res);
  mixed d = data->get_data();
  d[args->store] = res;
  return "";

  return "";
}

mixed image_fetch(string rssurl, int max, int|void timeout)
{
  object r = rss_fetch(rssurl, max, timeout);
  array x = ({});
  mapping res = ([]);

  if(r && r->items)
  { 

    foreach(r->items;; object item)
    {
      mapping image = ([]);
      mapping md = item->data["http://search.yahoo.com/mrss/"];
      if(md && md->thumbnail)
      {
        image = md["thumbnail"]->get_attributes();
        image->thumbnail = image->url;
        image->title = item->data->title;
        image->description = item->data->description;
        image->date = Calendar.dwim_time(item->data->pubDate);
        image->url = item->data->link;
        x+=({image});
        if(sizeof(x) >= max) break;
      }
      else continue;
    }

    res->photos=x;
    res->title = r->data->title;
    res->url = r->data->link;
  }


  return res;
}

#if constant(Public.Parser.XML2) && constant(Public.Syndication)

mixed rss_fetch(string rssurl, int max, int|void timeout)
{
  string rss;
  object r;

  if(!(rss = feed_data[rssurl]))
  {

    logger->info("rss-reader getting " + rssurl);

    if(has_prefix(rssurl, "file://"))
      rss = Stdio.read_file(rssurl[7..]);
    else rss = Protocols.HTTP.get_url_data(rssurl);

    if(rss) feed_data[rssurl] = rss;
  }

  mixed e = catch
  {
    if(rss)
      r = Public.Syndication.RSS.parse(rss);
  };

 if(e) logger->exception("Error parsing RSS Feed.", e);

  return r;
}

#else
mixed rss_fetch(string rssurl, int max, int|void timeout)
{
  return ([]);
}

#endif
