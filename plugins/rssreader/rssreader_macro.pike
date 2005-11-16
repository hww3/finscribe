import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

string describe()
{
   return "Consumes an RSS Feed";
}

void evaluate(String.Buffer buf, Macros.MacroParameters params)
{
  string doc;
  int limit;

  // we should get a limit for the number of entries to display.


  array a = params->parameters / "|";

  if(!sizeof(a) || !strlen(a[0]))
  {
    buf->add("No RSS URL provided!\n");
    return;
  }

  else doc = a[0];

  if(sizeof(a)>1 && a[1] && strlen(a[1]))
    limit = (int)a[1];
  else limit = 10;

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
    buf->add("RSS: invalid RSS document\n");
    return;
  }

  buf->add("<div class=\"rss-feed\">");
  buf->add(r->data->title);
  buf->add("<hr/>\n");
 
  foreach(r->items, item)
  {
    buf->add("<li/>\n");
    buf->add("<a href=\"");
    buf->add(item->data->link);
    buf->add("\">");
    buf->add(item->data->title);
    buf->add("</a>");
    buf->add("\n");
  }

  buf->add("</div>");

  return;
}


mixed rss_fetch(string rssurl, int timeout)
{
  string rss;
  object r;

  werror("rss-reader: getting " + rssurl + "\n");

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

