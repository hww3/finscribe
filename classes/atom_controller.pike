inherit Fins.FinsController;
import Fins;

#if constant(Public.Syndication.ATOM)

// atom implies xml2.
import Public.Parser.XML2;

import Fins.Model;
import Public.Syndication;
import Standards;

constant __uses_session = 0;

public void index(Request id, Response response, mixed ... args) {
  mixed err = catch(__index(id, response, @args));
  if (err) {
    response->set_type("text/html");
    if (arrayp(err)) {
      object e = Error.Generic(err[0]);
      e->error_backtrace = err[1];
      throw(e);
    }
    else if (objectp(err))
      throw(err);
    else
      throw(Error.Generic(err));
  }
}

public void __index(Request id, Response response, mixed ... args)
{
  object obj;

  if(id->variables->type == "category")
  {
    array a = find.categories((["category": args*"/"]));
    if(!sizeof(a))
    {
      response->not_found("category " + args*"/");
      return;
    }

    obj = a[0];
    category_atom(id, response, obj, args);
    return;
  }
  if ((sizeof(args) > 1) && (args[0] == "category")) {
    array a = find.categories(([ "category" : args[1..]*"/"]));
    if(!sizeof(a))
    {
      response->not_found("category " + args*"/");
      return;
    }

    obj = a[0];
    category_atom(id, response, obj, args);
    return;
  }

  obj = model->get_fbobject(args, id);

  if(!obj) 
  {
    response->redirect("/exec/notfound/" + args*"/");
  }

  if(id->variables->type == "history")
  {
    history_atom(id, response, obj, args);
  }

  else if(id->variables->type == "comments")
  {
    comments_atom(id, response, obj, args);
  }
  
  else // blog changes is the default mode
  {
    weblog_atom(id, response, obj, args);
  }

}

private void weblog_atom(Fins.Request id, Fins.Response response,
  object obj, mixed ... args)
{
  // attachments and blog entries cannot be blogs.
  if(obj["is_attachment"]!=0)
  {
    response->flash("msg", "page requested is not a weblog.\n");
    response->redirect("/exec/notfound/" + args*"/");
    return;
  }
 
  array o = obj->get_blog_entries(10);

  ATOM.Feed feed = generate_weblog_atom(obj, o, id);

  //FIXME should be atom+xml but nothing supports it yet!
  //response->set_type("application/atom+xml");
  response->set_type("application/xml");
  response->set_data(ATOM.render_atom_string(feed));
}

private void comments_atom(Fins.Request id, Fins.Response response,
  object obj, array args)
{
  if(obj["is_attachment"] == 1)
  {
    response->flash("msg", "document requested cannot contain comments.\n");
    response->redirect("/exec/notfound/" +  args*"/");
    return 0;
  }
 
  array o = obj["comments"];

  ATOM.Feed feed = generate_comments_atom(obj, o, id);

  //FIXME should be atom+xml but nothing supports it yet!
  //response->set_type("application/atom+xml");
  response->set_type("application/xml");
  response->set_data(ATOM.render_atom_string(feed));
}

private void category_atom(Fins.Request id, Fins.Response response,
  object obj, mixed ... args)
{
  array o = obj["objects"];

  ATOM.Feed feed = generate_category_atom(obj, o, id);

  //FIXME should be atom+xml but nothing supports it yet!
  //response->set_type("application/atom+xml");
  response->set_type("application/xml");
  response->set_data(ATOM.render_atom_string(feed));
}

private void history_atom(Fins.Request id, Fins.Response response,
  object obj, mixed ... args)
{
  if(obj["datatype"]["mimetype"] != "text/wiki")
  {
    response->flash("msg", "page requested is not a weblog.\n");
    response->redirect("/exec/notfound/" + args*"/");
    return 0;
  }
 
  ATOM.Feed feed = generate_history_atom(obj, find.object_versions((["object": obj])), id);

  //FIXME should be atom+xml but nothing supports it yet!
  //response->set_type("application/atom+xml");
  response->set_type("application/xml");
  response->set_data(ATOM.render_atom_string(feed));
}

private ATOM.Feed generate_weblog_atom(object root, array entries, object id)
{
  ATOM.Feed feed = generate_empty_atom(root, id);
  feed->title()->contents(sprintf("%s :: %s", app->get_sys_pref("site.name")["value"], root["title"]));
  // Assume the entries are sorted in reverse chronological order.
  if (sizeof(entries)) {
    feed->updated(ATOM.RFC3339(entries[0]["created"]));

    foreach((array)entries, object e) {
      feed->add_entry(make_entry(id, e));
    }
  }
  else
    feed->updated(ATOM.RFC3339(Calendar.now()));

  return feed;
}

private ATOM.Feed generate_category_atom(object root, array|object entries, object id)
{
  ATOM.Feed feed = generate_empty_atom(root, id);
  feed->title()->contents(sprintf("%s :: %s", app->get_sys_pref("site.name")["value"], root["category"]));

  if (sizeof(entries)) {
    feed->updated(ATOM.RFC3339(reverse(sort((array)entries["created"]))[0]));

    foreach((array)entries, object e) {
      feed->add_entry(make_entry(id, e));
    }
  }
  else
    feed->updated(ATOM.RFC3339(Calendar.now()));
  return feed;
}

private ATOM.Feed generate_comments_atom(object root, array entries, object id)
{
  ATOM.Feed feed = generate_empty_atom(root, id);
  feed->title()->contents(sprintf("%s :: %s", app->get_sys_pref("site.name")["value"], root["title"]));

  string contents = app->render(root["current_version"]["contents"], root, id);
  mixed c = make_contents(contents);
  if (objectp(c)) {
    feed->subtitle()->type(ATOM.HRText.TEXT_XHTML);
    feed->subtitle()->contents(c);
  }
  else if (stringp(c)) {
    feed->subtitle()->type(ATOM.HRText.TEXT_HTML);
    feed->subtitle()->contents(c);
  }

  if (sizeof(entries)) {
    feed->updated(ATOM.RFC3339(reverse(sort((array)entries["created"]))[0]));

    foreach((array)entries, object e) {
      feed->add_entry(make_entry(id, e));
    }
  }
  else
    feed->updated(ATOM.RFC3339(Calendar.now()));
  return feed;
}


private ATOM.Feed generate_history_atom(object root, array entries, object id)
{
  ATOM.Feed feed = generate_empty_atom(root, id);
  feed->title()->contents(sprintf("%s :: %s", app->get_sys_pref("site.name")["value"], root["title"]));

  if (sizeof(entries)) {
    feed->updated(ATOM.RFC3339(reverse(sort((array)entries["created"]))[0]));

    foreach((array)entries, object e) {
      feed->add_entry(make_entry(id, e));
    }
  }
  else
    feed->updated(ATOM.RFC3339(Calendar.now()));
  return feed;
}

ATOM.Feed generate_empty_atom(object root, object id) {
  ATOM.Feed feed = ATOM.Feed();
  feed->id(URI(id->not_query, app->get_sys_pref("site.url")["value"]));
  ATOM.HRText title = ATOM.HRText();
  title->tag_name("title");
  title->type(ATOM.HRText.TEXT_PLAIN);
  multiset idxs = (multiset)indices(root);
  if (idxs["title"])
  title->contents(root["title"]);
  else if (idxs["subject"])
    title->contents(root["subject"]);
  else if (idxs["category"])
    title->contents(root["category"]);
  else
    title->contents(app->get_sys_pref("site.name")["value"]);
  feed->title(title);
  ATOM.Link self = ATOM.Link();
  self->rel("self");
  self->href(URI(id->not_query, app->get_sys_pref("site.url")["value"]));
  self->type("application/atom+xml");
  feed->add_link(self);
  ATOM.Link html = ATOM.Link();
  html->rel("alternate");
  // FIXME - Bill, is this the right thing to do (the replace())?
  html->href(URI(replace(id->not_query, "atom", "space"), app->get_sys_pref("site.url")["value"]));
  html->type("text/html");
  feed->add_link(html);
  ATOM.Link rss = ATOM.Link();
  rss->href(URI(replace(id->not_query, "atom", "rss"), app->get_sys_pref("site.url")["value"]));
  rss->type("application/rss+xml");
  feed->add_link(rss);
  feed->generator(ATOM.Generator());
  feed->generator()->contents(sprintf("%s (%s)", version(), feed->generator()->contents()));
  feed->generator()->uri(URI("http://hww3.riverweb.com/space/pike/FinScribe"));
  // FIXME - potential bug if the logo isn't on the same host as
  // the site.url.
  feed->logo(URI(app->get_sys_pref("site.logo")["value"], app->get_sys_pref("site.url")["value"]));
  feed->icon(URI("/favicon.ico", app->get_sys_pref("site.url")["value"]));
  feed->subtitle(ATOM.HRText());
  feed->subtitle()->tag_name("subtitle");
  feed->subtitle()->type(ATOM.HRText.TEXT_PLAIN);
  feed->subtitle()->contents(app->get_sys_pref("site.tagline")["value"]);
  return feed;
}

static Node make_xhtml(Node node, void|int first) {
  if (first)
    catch(node->add_ns(XHTML.XMLNS, "html"));
  catch(node->set_ns(XHTML.XMLNS));
  if (node->children())
    foreach(node->children(), object child)
      if (child->get_node_type() == Constants.ELEMENT_NODE)
	make_xhtml(child);
      else if (child->get_node_type() == Constants.TEXT_NODE)
	// This is a hack because we parsed a potential xhtml fragment as html
	child->set_content(replace(child->get_text(), "/>", ""));
}

static string|Node make_contents(string contents) {
  Node node;
  Node div;
  if (!catch(node = parse_html(contents))) {
    array nodes = node->children()[0]->children();
    foreach(nodes, object n)
      n->unlink();
    if (sizeof(nodes) == 1) {
      node = nodes[0];
      if (node->get_node_name() == "div")
	div = node;
      else {
	div = new_node("div");
	div->add_child(node);
      }
    }
    else if (sizeof(nodes) > 1) {
      div = new_node("div");
      foreach(nodes, object n)
	div->add_child(n);
    }
    make_xhtml(div, 1);
    return div;
  }
  else
    return contents;
}

static ATOM.Entry make_entry(Request id, object e) {
  ATOM.Entry entry = ATOM.Entry();
  URI perma = URI(sprintf("/space/%s", e["path"]), app->get_sys_pref("site.url")["value"]);
  entry->id(perma);
  entry->title(ATOM.HRText());
  entry->title()->tag_name("title");
  entry->title()->type(ATOM.HRText.TEXT_PLAIN);
  entry->title()->contents(e["title"]);
  entry->updated(ATOM.RFC3339(e["created"]));
  entry->published(ATOM.RFC3339(e["created"]));
  string author_name = e["author"]["name"];
  ATOM.Author author = ATOM.Author();
  author->name(author_name);
  entry->add_author(author);
  // FIXME - add XESN stuff here.
  foreach((array)e["versions"], object ee) {
    if (ee["author"]["name"] != author_name) {
      ATOM.Contributor cont = ATOM.Contributor();
      cont->name(ee["author"]["name"]);
      // FIXME - also here
      entry->add_contributor(cont);
    }
  }
  foreach((array)e["categories"], object c) {
    object cc = ATOM.Category();
    string term = lower_case(replace(c["category"], " ", ""));
    cc->term(term);
    cc->label(c["category"]);
    entry->add_category(cc);
  }
  if (e["is_attachment"] == 2) {
    // Not an attachment.
    ATOM.Link alt = ATOM.Link();
    alt->rel("alternate");
    alt->href(perma);
    alt->type("text/html");
    alt->title(e["title"]);
    entry->add_link(alt);
    if (sizeof((array)e["comments"])) {
      ATOM.Link atom_comments = ATOM.Link();
      atom_comments->rel(URI("http://purl.org/syndication/thread/1.0/comments"));
      atom_comments->href(URI(sprintf("/atom/%s?type=comments", e["path"]), app->get_sys_pref("site.url")["value"]));
      atom_comments->type("application/atom+xml");
      atom_comments->title("Comment feed.");
      entry->add_link(atom_comments);
      ATOM.Link rss_comments = ATOM.Link();
      rss_comments->rel(URI("http://purl.org/syndication/thread/1.0/comments"));
      rss_comments->href(URI(sprintf("/rss/%s?type=comments", e["path"]), app->get_sys_pref("site.url")["value"]));
      rss_comments->type("application/rss+xml");
      rss_comments->title("Comments feed.");
      entry->add_link(rss_comments);
    }
    array attachments = (array)e["attachments"];
    if (attachments)
      foreach(attachments, object a) {
	ATOM.Link at = ATOM.Link();
	at->rel("enclosure");
	at->href(URI(sprintf("/space/%s", a["path"]), app->get_sys_pref("site.url")["value"]));
	at->type(a["datatype"]["mimetype"]=="text/wiki"?"text/html":a["datatype"]["mimetype"]);
	at->title(a["title"]);
	at->length((int)a["current_version"]["content_length"]);
	entry->add_link(at);
      }
    string contents = app->render(e["current_version"]["contents"], e, id);
    entry->content(ATOM.Content());
    mixed c = make_contents(contents);
    if (stringp(c))
      entry->content()->set("html", c);
    else
      entry->content()->set("xhtml", c);

    if (sizeof(contents / "<!--break-->") > 1) {
      // teaser.
      string teaser = (contents / "<!--break-->")[0];
      entry->summary(ATOM.HRText());
      entry->summary()->tag_name("summary");
      mixed t = make_contents(teaser);
      if (stringp(t)) {
	entry->summary()->type(ATOM.HRText.TEXT_HTML);
	entry->summary()->contents(t);
      }
      else {
	entry->summary()->type(ATOM.HRText.TEXT_XHTML);
	entry->summary()->contents(t);
      }
    }
  }
  else {
    entry->content(ATOM.Content());
    entry->content()->set(e["datatype"]["mimetype"]=="text/wiki"?"text/html":e["datatype"]["mimetype"], URI(sprintf("/space/%s", e["path"]), app->get_sys_pref("site.url")["value"]));
  }
  return entry;
}

#else
public void index(Request id, Response response, mixed ... args)
{
  response->set_data("Public.Syndication.ATOM is not installed. ATOM feeds are unavailable.");
}
#endif /* Public.Syndication.ATOM */
