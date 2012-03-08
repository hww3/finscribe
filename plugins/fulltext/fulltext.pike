import FullText;
import Tools.Logging;
import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name="Full Text indexing";

int _enabled = 0;

int checked_exists = 0;

mapping query_event_callers()
{
  return (["postSaveAttachment": updateIndex,
           "postDeleteAttachment": updateIndexDelete,
           "postMoveAttachement": updateIndexMove,
           "postSave": updateIndex,
           "postMove": updateIndexMove,
           "postDelete": updateIndexDelete ]);
}

mapping query_ipath_callers()
{
  return (["ftsearch": ftSearch ]);
}

mapping query_macro_callers()
{
  return ([ "search-dialog": searchdialog_macro(),
            "search-results": searchresults_macro() ]);
}

mapping query_preferences()
{
  return ([ 
    "indexserver" : (["type": FinScribe.STRING, "value": "http://localhost:8124"]), 
    "indexname" : (["type": FinScribe.STRING, "value": "http://bill.welliver.org"]), 
    "authcode" : (["type": FinScribe.STRING, "value": "NANA"]) 

  ]);
}

void ftSearch(object id, object response, mixed ... args)
{
  if(!id->variables->q)
  {
    response->set_data("ftsearch: no query specified.");
    return;
  }

  else
  {
    object c = SearchClient(get_preference("indexserver")->get_value(), 
				get_preference("indexname")->get_value(),
				get_preference("authcode")->get_value());

    array r = c->search(id->variables->q);

    if(r && sizeof(r))
    {
      response->set_data(sprintf("<pre>%O</pre>\n", r));
    }
    else 
    {
      response->set_data("no results for your query.");
    }
  }
}

int updateIndex(string event, object id, object obj)
{
  call_out(Thread.Thread, 0, doUpdateIndex, event, id, obj);

  return 0;
}

int updateIndexDelete(string event, object id, string obj)
{
  call_out(Thread.Thread, 0, doUpdateIndexDelete, event, id, obj);
    
  return 0;
}          
    
int updateIndexMove(string event, object id, string oldpath, object obj)
{
  call_out(Thread.Thread, 0, doUpdateIndexMove, event, id, oldpath, obj);
        
  return 0;
}

void doUpdateIndexDelete(string event, object id, string obj)
{

  mapping p = app->config["fulltext"];
  if(!p || !p["indexserver"]) return 0;

    object c = UpdateClient(get_preference("indexserver")->get_value(), 
				get_preference("indexname")->get_value(),
				get_preference("authcode")->get_value());

  if(strlen(obj))
    c->delete_by_handle(obj);
}

void doUpdateIndexMove(string event, object id, string oldpath, object obj)
{
  doUpdateIndexDelete(event, id, oldpath);
  doUpdateIndex(event, id, obj);
}

    
void doUpdateIndex(string event, object id, object obj)
{
  if(obj["is_attachment"] == 3)
  {
    Log.info("Skipping " + obj["path"]);
     return;
  }
//  Log.info("saved " + obj["path"]);  

    object c = UpdateClient(get_preference("indexserver")->get_value(), 
				get_preference("indexname")->get_value(),
				get_preference("authcode")->get_value());

  string t = app->render(obj["current_version"]["contents"], obj, id);

  if(obj["path"] && strlen(obj["path"]))
  c->delete_by_handle(obj["path"]);  
  c->add(obj["title"], 
      obj["current_version"]["created"], 
      t, obj["path"], 0,
      obj["datatype"]["mimetype"]);
}

class searchdialog_macro
{

inherit Macros.Macro;

string describe()
{
   return "Displays a search dialog";
}

array evaluate(Macros.MacroParameters params)
{
  array res = ({});
  string target_url;

  array a = params->parameters / "|";

  if(!sizeof(a) || !strlen(a[0]))
  {
    return ({"No Search Result page specified!\n"});
  }

  foreach(a;;string val)
  {
    if(has_prefix(val, "target_url="))
    {
      target_url = val[11..];
    }
  }

  res+=({"<div class=\"search-dialog\">\n"});
  res+=({"<form action=\"" + target_url + "\">\n" });

  res+=({"<input type=\"text\" name=\"q\"> <input type=\"submit\" value=\"Search\">"});

  res+=({"</form>\n"});
  res+=({"</div>\n"});

  return res;
}

}

class searchresults_macro
{

inherit Macros.Macro;

string describe()
{
   return "Displays a set of search results";
}

array doSearchMacro(Macros.MacroParameters params)
{
  array res = ({});

  if(!params || !params->extras->request || !params->extras->request->variables->q)
    return ({"No query specified."});

  object c = SearchClient(get_preference("indexserver")->get_value(), 
				get_preference("indexname")->get_value(),
				get_preference("authcode")->get_value());

  mixed r;
  mixed e = catch(r = c->search(params->extras->request->variables->q));
  res+=({"<div class=\"search-results\">\n"});

  if(e)
  {
    res+=({"<div class=\"search-results\">\n"});
    res += ({ "<b>Searching failed, with the following response from the index server:</b><p>"  });  
    res += ({ e->message() });  
    res+=({"</div>\n"});
  
    return res;  
  }

  res+=({"<div class=\"search-results\">\n"});
  
  if(!r || !sizeof(r)) 
  {
    res += ({ "Your search for <b>" + params->extras->request->variables->q + "</b> returned no results.</b><p>\n" });
  }  
  else
  {
    object user = params->engine->wiki->get_current_user(params->extras->request);
    res += ({ "Results for your query: <b>" + params->extras->request->variables->q + "</b>:<p>" });
    foreach(r;int i; mapping entry)
    {
      array o = params->engine->wiki->model->context->find->objects((["path": entry->handle]));
      if(!sizeof(o)) continue;
      object e = o[0];
      if(e->is_readable(user))
        res += ({ "<img src=\"/static/images/attachment/" + e["icon"] + "\"> <a href=\"/space/" 
              + entry->handle + "\">" + entry->title + 
              "</a> (" + entry->date + ")  [" + (int)(entry->score * 100.0)+ "%]<dd>\n" + entry->excerpt + "</dd><p>\n"});
    }
  }

  res+=({"</div>\n"});

  return res;
}

int is_cacheable()
{
  return 0;
}

array evaluate(Macros.MacroParameters params)
{
  array res = doSearchMacro(params);
  return res;
}


}

