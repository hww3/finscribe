inherit Public.Web.Wiki.RenderEngine;
import Fins;
import Fins.Model;

object wiki;

int exists_queries;
multiset existing_objects = (<>);

void create(object _wiki)
{
  // wiki is the application object.
  wiki = _wiki;
  string s = Stdio.read_file(combine_path(wiki->config->app_dir, "config/wiki_rules.txt"));
  ::create(s);
}

int exists(string _file)
{
  array res;

  exists_queries ++;
  if(exists_queries==100)
  {
    existing_objects=(<>);
    exists_queries=0;
  }
  if(existing_objects[_file]) return 1;

  res = wiki->model->find("object", (["path": _file]));

  if(!sizeof(res)) return 0;
  else 
  {
    existing_objects[_file] = 1;
    return 1;
  }
}

int showCreate()
{
  return 1;
}

void appendLink(String.Buffer buf, string name, string view, string|void anchor)
{
  //werror("appendLink: %O %O %O\n", name, view, anchor);
  buf->add("<a href=\"/space/");
  buf->add(name + (anchor?("#" + anchor):""));
  buf->add("\">");
  buf->add(wiki->get_object_name(view));
  buf->add("</a>");
}

void appendCreateLink(String.Buffer buf, string name, string view)
{
  //werror("appendCreateLink: %O %O\n", name, view);
  buf->add("&#");
  buf->add((string)'[');
  buf->add("; create <a href=\"/exec/edit/");
  buf->add(name);
  buf->add("\">");
  buf->add(view);
  buf->add("</a>]");
}

string macro_recent_changes()
{
  mixed res;
  string ret = "";
//  res = sql->query("SELECT page from GotPikeWiki group by page order by created desc limit 5");

  res = wiki->model->find("object", (["is_attachment": 
Model.Criteria("is_attachment!=1")]), 
Model.Criteria("GROUP BY id ORDER by created DESC LIMIT 10"));

  foreach(res, mixed row)
  {
    string type="Permalink";

    if(row["is_attachment"] == 1) continue;
    else if(row["is_attachment"] == 2) type = "Blogentry";

    string icon = "<img src=\"/static/images/Icon-" + type+ ".png\" alt=\"*\"/> ";
    ret = ret +  icon + "<a href=\"/space/" + row["path"] + "\">" + get_object_title(row) + "</a><br/>";
  }

  return ret;
}

