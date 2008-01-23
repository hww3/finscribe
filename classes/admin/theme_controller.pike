//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)


import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
  response->redirect("list");
}

public void list(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

     object t = view->get_view("admin/themes/list");
     string current_theme = app->new_string_pref("site.theme", "default")->get_value();

     app->set_default_data(id, t);

     mixed ul = ({});

     foreach(get_dir(combine_path(app->config->app_dir, "themes"));; mixed p)
     {
       object s;
//werror("adding " + p + "\n");
       if(p == "CVS") continue;
       if(!(s = file_stat(combine_path(app->config->app_dir, "themes", p)))) continue;
       if(!s->isdir) continue;
       ul += ({ (["name": p, "is_active": (p==current_theme?1:0) ])});
     }

     t->add("themes", ul);
	
     response->set_view(t);
}

public void upload(Request id, Response response, mixed ... args)
{
  int viaframe = 0;

  if(!app->is_admin_user(id, response))
    return;

  object t = view->get_idview("admin/themes/_upload");

  werror("vars: %O\n", indices(id->variables));
  if(id->variables->Filename && id->variables->Filedata)
  {
    if(has_suffix(lower_case(id->variables->Filename), ".zip"))
    {
       object z;
werror("sizeof data: %d\n", sizeof(id->variables->Filedata));
       if(catch(z = Tools.Zip(Stdio.FakeFile(id->variables->Filedata))))
         response->flash("Invalid Zip file " + id->variables->Filename + ".");      
werror("z: %O\n", z);
mixed e = catch(
       z->unzip(combine_path(app->config->app_dir, "themes")));
       
if(e) werror("%O\n", e);
    }
    else
    {
      response->flash("Invalid file extension for document " + id->variables->Filename  + ".");
    }
  }

  if(viaframe)
   {
     string s = "<html><head></head><body><div id=\"return\">" + t->render() + "</div></body></html>";
     response->set_data(s);
     response->set_type("text/html");
   }
   else
   {
     response->set_view(t);

   }
}

public void activate(Request id, Response response, mixed ... args)
{
  if(!app->is_admin_user(id, response))
    return;

  if(!args || !sizeof(args) || args[0] == "")
    return;

  string theme = args[0];
  string theme_dir = combine_path(app->config->app_dir, "themes", theme);

  object s = file_stat(theme_dir);

  if(!s || !s->isdir)
    return 0;

  object current_theme = app->new_string_pref("site.theme", "default");
  current_theme["Value"] = theme;

  response->flash("Activated theme " + theme + ".");
  response->redirect(list);
}

public void get(Request id, Response response, mixed ... args)
{
  if(!app->is_admin_user(id, response))
    return;

  if(!args || !sizeof(args) || args[0] == "")
    return;

  string theme = args[0];
  string theme_dir = combine_path(app->config->app_dir, "themes", theme);
  
  object s = file_stat(theme_dir);

  if(!s || !s->isdir)
    return 0;

  Tools.Zip z = Tools.Zip();

  z->add_dir(theme_dir, 1, theme);

  response->set_data(z->generate()); 
  response->set_type("application/zip");
  response->set_header("Content-Disposition", sprintf("attachment; filename=\"%s\"", theme + ".zip"));
}

public void toggle_enabled(Request id, Response response, mixed ... args)
{
  if(!app->is_admin_user(id, response))
     return;
  object u;

  if(!id->variables->plugin)
  {
    response->flash("msg", "No plugin.");
  }

  else if(!app->plugins[id->variables->plugin])
  {
	response->flash("msg", "Plugin enumeration failure.");
  }

  else
  {
	object p = app->get_sys_pref("plugin." + app->plugins[id->variables->plugin]->name + ".enabled");
    p["Value"] = !p->get_value();
    response->flash("msg", "Plugin " + id->variables->plugin + " " + (p->get_value()?"en":"dis") + "abled.");
  }

  response->redirect("list");
}
