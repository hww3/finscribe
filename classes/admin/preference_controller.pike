//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

import Fins;
import Tools;
import Tools.Logging;
import Fins.Model;
inherit Fins.FinsController;

protected string vtype = "admin";

protected string get_root(object id)
{
  return "";
}

static void start()
{
  before_filter(app->admin_user_filter);
} 

public void index(Request id, Response response, mixed ... args)
{
  response->redirect("list");
}

public void tree(Request id, Response response, mixed ... args)
{
  string pr = get_root(id);
  if(id->variables->action && id->variables->action == "getChildren")
  {
      array data = ({});
    mapping d = Tools.JSON.deserialize(id->variables->data);
    Log.debug("data: %O\n", d);
    array prefixes = ({});
    array nodes = ({});

    if(d->node && d->node->widgetId && d->node->widgetId == "prefroot")
    {

      mapping prc = ([]);
      if(pr && sizeof(pr)) prc->name = Fins.Model.LikeCriteria(pr + "%");
      array x =  find.preferences(prc);
      foreach(x;;object p)
      {
	array x = (p["name"][sizeof(pr)..]/".");
        prefixes += ({x[0]});
      }
      prefixes = Array.uniq(prefixes);
      prefixes -= ({"", 0});
	foreach(prefixes;;string p)
       data += ({ (["title":  p, "data": p, "widgetId": "tree_" + p, "isFolder": 1 ]) });

    }
    else if(d->node && d->node->widgetId)
    {
      array x;
      if(!has_prefix(d->node->widgetId[5..], pr?(pr):"")) x = ({});
      else x = find.preferences((["name": Fins.Model.LikeCriteria(d->node->widgetId[5..] + "%")]));
      int q = sizeof(d->node->widgetId[5..] / ".");
      multiset nodesadded = (<>);
      foreach(x;;object p)
      {
        array x1 = p["name"]/".";
        if(sizeof(x1)>(q))
        {
          if(nodesadded[x1[q]]) continue;
          prefixes += ({ ({x1[q], (x1[..q] * ".")})});
          nodesadded[x1[q]] = 1;
        }
        else
          nodes += ({p});
      }
  
//      prefixes = Array.uniq(prefixes);
    

      if(sizeof(prefixes))
        foreach(prefixes;; array p)
          data += ({ (["title":  p[0], "data": p[1], "widgetId": "tree_" + p[1], "isFolder": 1 ]) });
      if(sizeof(nodes))foreach(nodes;; object pref)
          data += ({ (["title":  pref["shortname"], "data": pref["name"], "widgetId": "treepref_" + pref["name"], "isFolder": 0 ]) });
      
}
      response->set_data(Tools.JSON.serialize(data));
      response->set_type("text/json");

      werror("JSON: %O\n", Tools.JSON.serialize( data ));      
  }
}

public void list(Request id, Response response, mixed ... args)
{
    object t;
  string pr = get_root(id);
werror("list()\n");
    if(id->variables->ajax)
      t = view->get_view(vtype + "/prefs/_list");
    else
      t = view->get_view(vtype + "/prefs/list");
werror("template: %O\n", t);
    app->set_default_data(id, t);

    mixed ul = ({});
    mapping c = ([]);

    array prefixes=({});

    {
      mapping prc = ([]);
      if(pr && sizeof(pr)) prc->name = Fins.Model.LikeCriteria(pr + "%");
      array x =  find.preferences(prc);
      foreach(x;;object p)
        prefixes += ({ (p["name"][sizeof(pr)..]/".")[0]});
      prefixes -= ({"", 0});
      prefixes = Array.uniq(prefixes);
    }     

    string startswith = id->variables->startswith;
    if(startswith && !has_prefix(startswith, pr))
    {
      ul = ({});
    }
    else
    {
    if(startswith) c->name = Fins.Model.LikeCriteria(startswith + "%");
    else if(pr) c->name = Fins.Model.LikeCriteria(pr + "%");
    ul = find.preferences(c,  Fins.Model.Criteria("ORDER BY Name DESC"));
    }
werror("prefixes: %O\n", prefixes);
werror("prefs:    %O\n", ul);

    if(startswith)
      t->add("startswith", (startswith||"")/".");
    t->add("prefprefixes", prefixes);
    t->add("preferences", ul);

    response->set_view(t);
}

public void set(Request id, Response response, mixed ... args)
{
  mixed e;
  if (id->variables->key && id->variables->value && has_prefix(id->variables->key, (string)get_root(id))) {
    object pref = app->get_sys_pref(id->variables->key);
    if (pref) {
      if(pref["type"] == FinScribe.BOOLEAN)
      {
        if(lower_case(id->variables->value) == "false" || id->variables->value == "0" || lower_case(id->variables->value) == "no")
          pref["value"] = 0;
        else
        {
          pref["value"] = 1;
        }

      }
	  else
      	pref["value"] = id->variables->value;
      response->set_data(JSON.serialize(([ "set" : 1 ])));
      response->set_type("text/javascript");
    }
  }
  else {
    response->set_data(JSON.serialize(([ "set" : 0 ])));
    response->set_type("text/javascript");
  }

  if(e) Log.exception("an error occurred while setting a variable.", e);
}
