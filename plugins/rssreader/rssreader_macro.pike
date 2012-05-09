import Fins;

inherit FinScribe.Plugin;

constant name="RSS Reader Macro";

#if constant(Public.Parser.XML2) && constant(Public.Syndication.RSS)
int _enabled = 1;

Tools.Mapping.MappingCache feed_data = Tools.Mapping.MappingCache(600);

mapping(string:object) query_macro_callers()
{
  return ([ "rss-reader": rss_macro(), "rss-output": rss_output() ]);
}

class rss_output
{

inherit Public.Web.Wiki.Macros.Macro;

string describe()
{
   return "Consumes an RSS Feed";
}

array evaluate(Public.Web.Wiki.Macros.MacroParameters params)
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

  Public.Syndication.RSS.Item item;

  if(!r) 
  {
    return ({"RSS: invalid RSS document\n"});
  }

  if(!hidetitle)
  {
    res+=({"<h3>" + r->data->title + "</h3>"});
  }

  foreach(r->items; int cnt; item)
  {

     if(cnt >= limit) break;
  
      res+=({ replace(params->contents, ({"%L", "%T"}),
              ({item->data->link, item->data->title }) )
           });
  }
  return res;
}


mixed rss_fetch(string rssurl, int timeout)
{
  string rss;
  object r;

  if(!(rss = feed_data[rssurl]))
  {

    logger->debug("rss-reader getting " + rssurl);

    if(has_prefix(rssurl, "file://"))
      rss = Stdio.read_file(rssurl[7..]);
    else rss = Protocols.HTTP.get_url_data(rssurl);

    if(rss) feed_data[rssurl] = rss;
  }

  catch
  {
    if(rss)
      r = Public.Syndication.RSS.parse(rss);
  };

  return r;
}


}

class rss_macro
{

inherit Public.Web.Wiki.Macros.Macro;

string describe()
{
   return "Consumes an RSS Feed";
}

array evaluate(Public.Web.Wiki.Macros.MacroParameters params)
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

  Public.Syndication.RSS.Item item;

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

  foreach(r->items; int cnt; item)
  {
     if(cnt >= limit) break;

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


  if(!(rss = feed_data[rssurl]))
  {
    logger->debug("rss-reader getting " + rssurl);

    if(has_prefix(rssurl, "file://"))
      rss = Stdio.read_file(rssurl[7..]);
    else rss = Protocols.HTTP.get_url_data(rssurl);

    if(rss) feed_data[rssurl] = rss;
  }

  catch
  {
    if(rss)
      r = Public.Syndication.RSS.parse(rss);
  };

  return r;
}

}
#endif /* Public.Parser.XML2 && Public.Syndication.RSS */
