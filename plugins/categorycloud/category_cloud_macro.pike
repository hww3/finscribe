import Tools.Logging;
import Fins;

inherit FinScribe.Plugin;

constant name="Category Display";

int _enabled = 1;

mapping(string:object) query_macro_callers()
{
  return ([ "category-cloud": categories_display_macro() ]);
}

class categories_display_macro
{

inherit Public.Web.Wiki.Macros.Macro;

string describe()
{
   return "Displays a Flickr like category block";
}

array evaluate(Public.Web.Wiki.Macros.MacroParameters params)
{
  string doc;
  int limit;
  int hidetitle;

  string query = "select categories.category, count(*) as cnt, objects_categories.object_id from  "
                 "objects_categories, categories where objects_categories.category_id = categories.id "
                 "group by categories.category order by cnt desc";

  string query2 = "select count(*) as cnt FROM objects_categories";

  // we should get a limit for the number of entries to display.

  array res = ({});
  array srt = ({});
  array c = params->engine->wiki->model->context->sql->query(query);

  if(!c || !sizeof(c))
    return ({""});

  int total = (int)(c[0]->cnt);

  foreach(c;;mapping row)
  {
    int count = (int)(row->cnt);
    
    float f = ((float)count/(float)total);
    count = (int)(f*5);
    srt+=({row->category});
    res+=({"<font size=\"" + count + "\">" + row->category + "</font> (" + row->cnt + ") &nbsp; "});
    
  }

  sort(srt, res);

  return ({"<div class=\"category-display\">"}) + res + ({"</div>"});

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
