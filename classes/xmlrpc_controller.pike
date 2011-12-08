import Fins;
inherit Fins.XMLRPCController;

constant __uses_session = 0;

mapping(string:function|string|object) __actions = 
  ([
    "metaWeblog.getPost": get_post,
    "metaWeblog.getRecentPosts": get_posts,
    "metaWeblog.getCategories": get_categories,
    "blogger.getUsersBlogs": get_users_blogs
    
  ]); 

array get_categories(object id, string blogId, string username, string password)
{
  mixed x = Fins.Model.find.categories_all();

  array y = allocate(sizeof(x));

  foreach(x; int i; object cat)
  {
     mapping c = ([]);
     c["description"] = cat["category"];
     c["categoryid"] = cat["id"];
     c["title"] = cat["category"];
     y[i] = c;
  }
}

array get_users_blogs(object id, string appkey, string username, string password)
{
  object obj = model->get_fbobject(appkey, id);
  return ({ object_to_bloginfo(obj) });
}

public mapping get_post(object id, string postId, string username, string password)
{
  object obj = model->get_fbobject(postId, id);

  if(!obj) throw(Error.Generic(sprintf("No post with id %O found.\n", postId)));
  return object_to_struct(obj); 
}

public array get_posts(object id, string blogId, string username, string password, int count)
{
  object obj = model->get_fbobject(blogId, id);

  if(!obj) throw(Error.Generic(sprintf("No post with id %O found.\n", blogId)));

  array o = obj->get_blog_entries(count||10);    

  array res = allocate(sizeof(o));

  foreach(o; int i; object ent)
    res[i] = object_to_struct(ent);

  return res;
}

protected mapping object_to_struct(object doc)
{
  mapping item = ([]);

//      item["link"] = sprintf("%s/space/%s", app->get_sys_pref("site.url")["value"], doc["path"]);
      item["permaLink"] = sprintf( "%s/space/%s", app->get_sys_pref("site.url")["value"], doc["path"]);
      item["title"] = doc["title"];
      item["dateCreated"] = doc["created"];
      item["postid"] = doc["id"];
      item["userid"] = doc["author"]["id"];
      item["categories"] = ({});
	
      foreach(doc["categories"];; object cat)
        item["categories"] += ({cat["category"]});

      item["description"] = doc["current_version"]["contents"];

  return item;
}

protected mapping object_to_bloginfo(object doc)
{
  mapping item = ([]);

      item["isAdmin"] = 1;
      item["url"] = sprintf("%s/space/%s", app->get_sys_pref("site.url")["value"], doc["path"]);
      item["blogid"] =  doc["path"];
      item["blogName"] = doc["title"];
      item["xmlrpc"] = action_url(app->controller->xmlrpc);

  return item;
}
