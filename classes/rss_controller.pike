import Public.Parser.XML2;
import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
  string r;

  object obj = model()->get_fbobject(args, id);

  if(!obj) 
  {
    response->redirect("/exec/notfound/" + args*"/");
  }

  if(obj["datatype"]["mimetype"] != "text/wiki")
  {
    response->flash("msg", "page requested is not a weblog.\n");
    response->redirect("/exec/notfound/" + args*"/");
  }
 
  array o = model()->get_blog_entries(obj, 10);

  Node n = generate_rss(obj, o);

  response->set_type("text/xml");
  response->set_data(render_xml(n));
}

private Node generate_rss(object root, array entries)
{
  Node n = new_xml("1.0", "rss");
  n->set_attribute("version", "2.0");

  Node c;

  c = n->new_child("channel", "");
  c->new_child("title", root["title"]);
  c->new_child("link", app()->config->get_value("site", "url"));
  c->new_child("description", "");
  c->new_child("generator", version());
  c->new_child("docs", "http://blogs.law.harvard.edu/tech/rss");

    foreach(entries; int i; object row)
    {
      Node item = c->new_child("item", "");
      item->new_child("link",  sprintf(
        "%s/space/%s", app()->config->get_value("site", "url"), 
        row["path"]));
      item->new_child("guid",  sprintf(
        "%s/space/%s", app()->config->get_value("site", "url"),
        row["path"]))->set_attribute("isPermaLink", "1");
      item->new_child("title", row["title"]);
      item->new_child("pubDate", row["created"]->format_smtp());
      item->new_child("description", replace(row["current_version"]["contents"], ({"\n\n", "\n"}), ({"<p>\n", "<br/>"})));
    }
  return n;
}
