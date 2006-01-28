import Public.Parser.XML2;
import Fins;
inherit Fins.FinsController;

constant __uses_session = 0;

public void index(Request id, Response response, mixed ... args)
{
  string r;
  object obj;

  if(id->variables->type == "category")
  {
    array a = model->find("category", (["category": args*"/"]));
    if(!sizeof(a))
    {
      response->not_found("category " + args*"/");
      return;
    }

    obj = a[0];
    category_rss(id, response, obj, args);
    return;
  }


  obj = model->get_fbobject(args, id);

  if(!obj) 
  {
    response->redirect("/exec/notfound/" + args*"/");
  }

  if(id->variables->type == "history")
  {
    history_rss(id, response, obj, args);
  }

  else if(id->variables->type == "comments")
  {
    comments_rss(id, response, obj, args);
  }
  
  else // blog changes is the default mode
  {
    weblog_rss(id, response, obj, args);
  }

}

private void weblog_rss(Fins.Request id, Fins.Response response,
  object obj, mixed ... args)
{
  if(obj["datatype"]["mimetype"] != "text/wiki")
  {
    response->flash("msg", "page requested is not a weblog.\n");
    response->redirect("/exec/notfound/" + args*"/");
    return;
  }
 
  array o = obj->get_blog_entries(10);

  Node n = generate_weblog_rss(obj, o, id);

  response->set_type("text/xml");
  response->set_data(render_xml(n));
}

private void comments_rss(Fins.Request id, Fins.Response response,
  object obj, mixed ... args)
{
  if(obj["datatype"]["mimetype"] != "text/wiki")
  {
    response->flash("msg", "page requested is not a wiki page.\n");
    response->redirect("/exec/notfound/" + args*"/");
    return;
  }
 
  array o = obj["comments"];

  Node n = generate_comments_rss(obj, o, id);

  response->set_type("text/xml");
  response->set_data(render_xml(n));
}

private void category_rss(Fins.Request id, Fins.Response response,
  object obj, mixed ... args)
{
  array o = obj["objects"];

  Node n = generate_category_rss(obj, o, id);

  response->set_type("text/xml");
  response->set_data(render_xml(n));
}

private void history_rss(Fins.Request id, Fins.Response response,
  object obj, mixed ... args)
{
  if(obj["datatype"]["mimetype"] != "text/wiki")
  {
    response->flash("msg", "page requested is not a weblog.\n");
    response->redirect("/exec/notfound/" + args*"/");
    return;
  }
 
//  array o = obj->get_blog_entries(10);

  Node n = generate_history_rss(obj, model->find("object_version", (["object": obj])), id);

  response->set_type("text/xml");
  response->set_data(render_xml(n));
}

private Node generate_weblog_rss(object root, array entries, object id)
{
  Node n = new_xml("1.0", "rss");
  n->set_attribute("version", "2.0");

  Node c;

  c = n->new_child("channel", "");
  c->new_child("title", root["title"]);
  c->new_child("link", app->get_sys_pref("site.url"));
  c->new_child("description", "");
  c->new_child("generator", version());
  c->new_child("docs", "http://blogs.law.harvard.edu/tech/rss");

    foreach(entries; int i; object row)
    {
      Node item = c->new_child("item", "");
      item->new_child("link",  sprintf(
        "%s/space/%s", app->get_sys_pref("site.url"), 
        row["path"]));
      item->new_child("guid",  sprintf(
        "%s/space/%s", app->get_sys_pref("site.url"),
        row["path"]))->set_attribute("isPermaLink", "1");
      item->new_child("title", row["title"]);
      item->new_child("pubDate", row["created"]->format_smtp());
      item->new_child("description", app->render(row["current_version"]["contents"], row, id));
    }
  return n;
}

private Node generate_category_rss(object root, array|object entries, object id)
{
  Node n = new_xml("1.0", "rss");
  n->set_attribute("version", "2.0");

  Node c;

  c = n->new_child("channel", "");
  c->new_child("title", root["category"]);
  c->new_child("link", app->get_sys_pref("site.url"));
  c->new_child("description", "");
  c->new_child("generator", version());
  c->new_child("docs", "http://blogs.law.harvard.edu/tech/rss");

  foreach(FinScribe.Blog.limit(reverse((array)entries), 10);;object row)
  {
      Node item = c->new_child("item", "");
      item->new_child("link",  sprintf(
        "%s/space/%s", app->get_sys_pref("site.url"), 
        row["path"]));
      item->new_child("guid",  sprintf(
        "%s/space/%s", app->get_sys_pref("site.url"),
        row["path"]))->set_attribute("isPermaLink", "1");
      item->new_child("title", row["title"]);
      item->new_child("pubDate", row["created"]->format_smtp());
      item->new_child("description", app->render(row["current_version"]["contents"], row, id));
    }
  return n;
}

private Node generate_comments_rss(object root, array entries, object id)
{
  Node n = new_xml("1.0", "rss");
  n->set_attribute("version", "2.0");

  Node c;

  c = n->new_child("channel", "");
  c->new_child("title", root["title"]);
  c->new_child("link", ({ app->get_sys_pref("site.url"), "space",  root["path"] }) * "/" );
  c->new_child("description", app->render(root["current_version"]["contents"], root, id));
  c->new_child("generator", version());
  c->new_child("docs", "http://blogs.law.harvard.edu/tech/rss");

  // we should put the entries in newest first order.
    foreach(FinScribe.Blog.limit(reverse((array)entries), 10); int i; object row)
//    foreach(entries; int i; object row)
    {
      Node item = c->new_child("item", "");
      item->new_child("link",  sprintf(
        "%s/comments/%s#%s", app->get_sys_pref("site.url"), 
        root["path"], (string)row["id"]));

      item->new_child("guid",  sprintf(
        "%s/comments/%s#%s", app->get_sys_pref("site.url"), 
        root["path"], (string)row["id"]))->set_attribute("isPermalink", "1");

      item->new_child("title", row["author"]["UserName"] + ": " + row["object"]["title"]);
      item->new_child("pubDate", row["created"]->format_smtp());
      item->new_child("description", app->render(row["contents"], row, id));
    }
  return n;
}


private Node generate_history_rss(object root, array entries, object id)
{
  Node n = new_xml("1.0", "rss");
  n->set_attribute("version", "2.0");

  Node c;

  c = n->new_child("channel", "");
  c->new_child("title", root["title"]);
  c->new_child("link", ({ app->get_sys_pref("site.url"), "space",  root["path"] }) * "/" );
  c->new_child("description", "");
// app()->engine->render(root["current_version"]["contents"], (["request": id, "obj": root])));
  c->new_child("generator", version());
  c->new_child("docs", "http://blogs.law.harvard.edu/tech/rss");

  // we should put the entries in newest first order.
    foreach(FinScribe.Blog.limit(reverse((array)entries), 10); int i; object row)
//    foreach(entries; int i; object row)
    {
      Node item = c->new_child("item", "");
      item->new_child("link",  sprintf(
        "%s/space/%s?show_version=%s", app->get_sys_pref("site.url"), 
        root["path"], (string)row["version"]));

      item->new_child("guid",  sprintf(
        "%s/comments/%s#%s", app->get_sys_pref("site.url"), 
        root["path"], (string)row["id"]))->set_attribute("isPermalink", "1");

      item->new_child("title", "Version " + row["version"] + ": " + row["object"]["title"]);
      item->new_child("pubDate", row["created"]->format_smtp());
      item->new_child("description", FinScribe.Blog.make_excerpt(app->render(row["contents"], row, id)));
    }
  return n;
}


