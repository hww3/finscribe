import Tools.Logging;
import Public.Web.Wiki;
import Fins;

inherit FinScribe.Plugin;

constant name="RSS Reader Macro";

mapping query_macro_callers()
{
  return ([ "rss-reader": rssreader_macro() ]);
}

class rssreader_macro
{

inherit Macros.Macro;

string describe()
{
   return "Consumes an RSS Feed";
}

array evaluate(Macros.MacroParameters params)
{
  string doc;
  int limit;
  int hidetitle;

  // we should get a limit for the number of entries to display.

array res = ({});
  array a = params->parameters / "|";

  if(!sizeof(a) || !strlen(a[0]))
  {
    return ({"No RSS URL provided!\n"});
  }

  else doc = a[0];

  if(sizeof(a)>1 && a[1] && strlen(a[1]))
    limit = (int)a[1];
  else limit = 10;

  if(sizeof(a)>2 && a[2] && strlen(a[2]))
	{
		if(a[2]=="hidetitle")
		  hidetitle = 1;
	}
  object r = params->engine->wiki->cache->get("__RSSdata-" + doc);

  if(!r)
  {
    r = rss_fetch(doc, 10);
    if(r)
      params->engine->wiki->cache->set("__RSSdata-" + doc, r, 1800);
  }

  Public.Web.RSS.Item item;

  if(!r) 
  {
    return ({"RSS: invalid RSS document\n"});
  }

  res+=({"<div class=\"rss-feed\">"});

  if(!hidetitle)
  {
    res+=({r->data->title});
    res+=({"<hr/>\n"});
  }

  foreach(r->items, item)
  {
    res+=({"<li class=\"rssreader\"/>\n"});
    res+=({"<a href=\""});
    res+=({item->data->link});
    res+=({"\">"});
    res+=({item->data->title});
    res+=({"</a>"});
    res+=({"\n"});
  }

  res+=({"</div>"});

  return res;
}


mixed rss_fetch(string rssurl, int timeout)
{
  string rss;
  object r;

  Log.debug("rss-reader getting " + rssurl + "\n");

  if(has_prefix(rssurl, "file://"))
    rss = Stdio.read_file(rssurl[7..]);

  else rss = Protocols.HTTP.get_url_data(rssurl);

  catch
  {

  if(rss)
    r = Public.Web.RSS.parse(rss);
  };

  return r;
}

}
