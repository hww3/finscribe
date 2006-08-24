//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

import Fins;
import Tools;
import Tools.Logging;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
  response->redirect("list");
}

public void tree(Request id, Response response, mixed ... args)
{
  if(id->variables->action && id->variables->action == "getChildren")
  {
    mapping d = Tools.JSON.deserialize(id->variables->data);
    Log.debug("data: %O\n", d);
    array prefixes = ({});
    array nodes = ({});
    if(d->node && d->node->widgetId)
    {
      array x =  model->find("preference", (["name": Fins.Model.LikeCriteria(d->node->widgetId[5..] + "%")]));
      int q = sizeof(d->node->widgetId[5..] / ".");
      foreach(x;;object p)
      {
        array x1 = p["Name"]/".";
        if(sizeof(x1)>(q +1))
          prefixes += ({ ({x1[q], (x1[..q] * ".")})});
        else
          nodes += ({p});
      }
      prefixes = Array.uniq(prefixes);

      array data = ({});

      foreach(prefixes;; array p)
        data += ({ (["title":  p[0], "widgetId": "tree_" + p[1], "isFolder": 1 ]) });
      foreach(nodes;; object pref)
        data += ({ (["title":  pref["ShortName"], "widgetId": "treepref_" + pref["Name"], "isFolder": 0 ]) });
// "<div dojoType=\"TreeNode\" widgetId=\"treepref_" + pref["Name"] + "\" title=\"" + pref["ShortName"] + "\" isFolder=\"false\"></div>"});

      response->set_data(Tools.JSON.serialize(data));
      response->set_type("text/json");

      werror("JSON: %O\n", Tools.JSON.serialize( data ));      
    }
  }
}

public void list(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

     object t = view->get_view("admin/prefs/list");

     app->set_default_data(id, t);

     mixed ul = ({});
    mapping c = ([]);

    array prefixes=({});

    {
      array x =  model->find("preference", ([]));
      foreach(x;;object p)
        prefixes += ({ (p["Name"]/".")[0]});
      prefixes = Array.uniq(prefixes);
    }     

    if(id->variables->startswith) c->Name = Fins.Model.LikeCriteria(id->variables->startswith + "%");
    ul = model->find("preference", c,  Fins.Model.Criteria("ORDER BY Name DESC"));

     t->add("prefprefixes", prefixes);
     t->add("preferences", ul);
	
     response->set_view(t);
}

public void set(Request id, Response response, mixed ... args)
{
  if(!app->is_admin_user(id, response)) {
    response->flash("msg", "Only admin user can change preferences!");
    response->redirect("list");
  }

  if (id->variables->key && id->variables->value) {
    object pref = app->get_sys_pref(id->variables->key);
    if (pref) {
      if(pref["Type"] == FinScribe.BOOLEAN)
      {
        if(lower_case(id->variables->value) == "false" || !(int)id->variables->value)
          pref["Value"] = 0;
        else
          pref["Value"] = 1;

      }
      pref["Value"] = id->variables->value;
      response->set_data(JSON.serialize(([ set : 1 ])));
      response->set_type("text/javascript");
    }
  }
  else {
    response->set_data(JSON.serialize(([ set : 0 ])));
    response->set_type("text/javascript");
  }
}
