import Fins;
inherit Fins.XMLRPCController;

constant __uses_session = 0;

#define CHECKUSER(X,Y) do{ if(!check_user(X,Y)) throw(Error.Generic("Invalid login.")); }while(0);

mapping(string:function|string|object) __actions = 
  ([
    "metaWeblog.newPost": new_post,
    "metaWeblog.getPost": get_post,
    "metaWeblog.getRecentPosts": get_posts,
    "metaWeblog.getCategories": get_categories,
    "blogger.getUsersBlogs": get_users_blogs,
    "blogger.deletePost": delete_post    
  ]); 

array get_categories(object id, string blogId, string username, string password)
{
  CHECKUSER(username, password)

  mixed x = Fins.Model.find.categories_all();

  array y = allocate(sizeof(x));

  foreach(x; int i; object cat)
  {
     mapping c = ([]);
     c["description"] = cat["category"];
     c["categoryid"] = cat["id"];
     c["title"] = cat["category"];
     c["htmlURL"] = action_url(app->controller->exec->categories, ({cat["category"]}));
     c["rssURL"] = action_url(app->controller->rss, ({cat["category"]}));
     y[i] = c;
  }

  return y;

}

int delete_post(object id, string appKey, string postId, string username, string password, int publish)
{
  CHECKUSER(username, password)

  object user = model->context->find->users_by_alt(username);
  object obj = model->get_fbobject(postId, id);

  if(!obj) throw(Error.Generic(sprintf("No post with id %O found.\n", postId)));

  return model->delete_post(id, obj, user, publish);
}

array get_users_blogs(object id, string appkey, string username, string password)
{
  CHECKUSER(username, password)

  object obj = model->get_fbobject(appkey, id);
  return ({ object_to_bloginfo(obj) });
}

public string new_post(object id, string blogId, string username, string password, mapping content, int publish)
{
  CHECKUSER(username, password)
  object new_post;
  object user = model->context->find->users_by_alt(username);
  object obj = model->get_fbobject(blogId, id);

  if(!obj) throw(Error.Generic(sprintf("No blog with id %O found.\n", blogId)));

  new_post = model->do_post(id, obj, user, content->title, content->description, content->pubDate, content->categories, publish);

  return new_post["path"];
}

public mapping get_post(object id, string postId, string username, string password)
{
  CHECKUSER(username, password)

  object obj = model->get_fbobject(postId, id);

  if(!obj) throw(Error.Generic(sprintf("No post with id %O found.\n", postId)));
  return object_to_struct(obj); 
}

public array get_posts(object id, string blogId, string username, string password, int count)
{
  CHECKUSER(username, password)

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
      item["postid"] = doc["path"];
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

protected int check_user(string user, string password)
{
         
      array r = Fins.DataSource._default.find.users((["username": user,
                                        "password": password,
                                        "is_active": 1]));
      if(r && sizeof(r)) return 1;
      else return 0;
}
