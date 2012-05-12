//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

import Tools.Logging;

Fins.FinsController plugin;
Fins.FinsController prefs;
Fins.FinsController themes;

void start()
{
  before_filter(app->admin_user_filter);
  plugin = load_controller("admin/plugin_controller");
  prefs = load_controller("admin/preference_controller");
  themes = load_controller("admin/theme_controller");
}

import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
   object t;

    if(id->variables->_ajax || id->variables->ajax) 
	  t = view->get_idview("admin/_adminindex");
	else
	  t = view->get_idview("admin/adminindex");

    app->set_default_data(id, t);

    t->add("in_admin", 1);

  response->set_view(t);
}

public void flush_templates(Request id, Response response, mixed ... args)
{
	view->flush_templates();
        response->flash("msg", LOCALE(305,"Templates flushed."));
        response->redirect(index, 0, ([time():""]));      
}
public void shutdown(Request id, Response response, mixed ... args)
{
	object t;
		
	if(!id->variables->really_shutdown)
	  t = view->get_idview("admin/confirmshutdown");
	else
	{	 
		t = view->get_idview("admin/shutdown");
			// this is bad, we should have a better way of doing this...
			call_out(exit, 5, 0);
		}
	        app->set_default_data(id, t);
    t->add("in_admin", 1);
	
		response->set_view(t);
	
}

public void getusers_json(Request id, Response response, mixed ... args)
{
  string json;
  array j = ({});
  array x;

  if(!sizeof(args))
   x = Fins.DataSource._default.find.users_all();
  else
  {
    object g = Fins.DataSource._default.find.groups_by_id((int)args[0]);
    
    x = g["users"];
  }

  foreach((array)x;;mixed g)
  {
    j += ({([ "name": g["name"] + " [" + g["username"] + "]", "value": g["id"] ])});
  } 

  json = Tools.JSON.serialize((["data": j]));
//werror("json: %O\n", json);
  response->set_data(json);
  response->set_type("text/json");
}

public void getrules_json(Request id, Response response, mixed ... args)
{
  string json;
  array j = ({});
  object a;

  if(!sizeof(args)) return;

  else
  {
    a = Fins.DataSource._default.find.acls_by_id((int)args[0]);
  }

  foreach(a["aclrules"];;mixed r)
  {
    j += ({([ "name": r->format_nice(), "value": r->format_data() ])});
  } 

werror("j: %O\n", j);
  json = Tools.JSON.serialize((["data": j]));

  response->set_data(json);
  response->set_type("text/json");
}

public void getgroups_json(Request id, Response response, mixed ... args)
{
  string json;
  array j = ({});
  array x = ({});

  if(!sizeof(args))
    x = Fins.DataSource._default.find.groups_all();
  else
  {
    object u = Fins.DataSource._default.find.users_by_id((int)args[0]);
    if(u)
       x = Fins.DataSource._default.find.groups((["users": u]));
  }

  foreach(x;;mixed g)
  {
    j += ({([ "name": g["name"], "value": g["id"] ])});
  } 

  json = Tools.JSON.serialize((["data": j]));

  response->set_data(json);
  response->set_type("text/json");
}

public void listacls(Request id, Response response, mixed ... args)
{
     object t = view->get_idview("admin/listacls");

     app->set_default_data(id, t);

	mixed ul;

	if(!id->variables->limit)
		ul = Fins.DataSource._default.find.acls_all();
	
	t->add("acls", ul);
    t->add("in_admin", 1);
	
	response->set_view(t);
}

public void listwip(Request id, Response response, mixed ... args)
{
    object t = view->get_idview("admin/listwip");

    app->set_default_data(id, t);

    mixed ul;

    ul = Fins.DataSource._default.find.objects((["is_attachment": 3]));
    t->add("wipblog", ul);

    ul = Fins.DataSource._default.find.objects((["is_attachment": 4]));
    t->add("wipobj", ul);

    t->add("in_admin", 1);
	
    response->set_view(t);
}

public void editacl(Request id, Response response, mixed ... args)
{
    object t = view->get_idview("admin/editacl");
	
    app->set_default_data(id, t);
    t->add("in_admin", 1);

    object g;

        if(id->variables->aclid)
        {
           g = Fins.DataSource._default.find.acls_by_id((int)id->variables->aclid);
	   t->add("acl", g);
        }
        else
        {
           t->add("newacl", 1);
        }

        if(id->variables->action)
        {
          if(id->variables->action == "Cancel")
          {
            response->redirect("listacls");
            return;
          }

          else if(id->variables->action == "Save")
          {
//werror("%O\n", id->variables);

            if(!id->variables->rules || !sizeof(id->variables->rules))
            {
              response->flash("msg", LOCALE(306,"ACL was not updated successfully. Rules were missing."));
              response->redirect("listacls");
              return;
            }

            if(id->variables->newacl)
            {
              g = Fins.DataSource._default.new("ACL");
              Log.info("creating a new acl.");
            }
            if((id->variables->name != g["name"]) || id->variables->newacl)
               g["name"] = id->variables->name;

            if(id->variables->newacl)
              g->save();

            mapping rules = Tools.JSON.deserialize(id->variables->rules);
            werror("Rules: %O\n", rules);

            foreach(rules->deleted;;mapping r)
            {
              object rule = Fins.DataSource._default.find.aclrules_by_id((int)(r->id));
              if(!rule)
                Log.error("Non existent ACL Rule %d.", (int)r->id);
              else
              {
                Log.info("Deleting ACL Rule %d", (int)rule["id"]);
                rule->delete();
              }
            }

            foreach(rules->rules;; mapping r)
            {
              if(r->isNew)
              {
                Log.debug("adding a rule");
                object newrule = Fins.DataSource._default.new("ACLRule");
                int cls = 0;
                if(r->class == "anonymous")
                  cls = 4;
                else if(r->class == "all_users")
                  cls = 2;
                else if(r->class == "owner")
                  cls = 1;

                newrule["class"] = cls;

                foreach(newrule->get_available_xmits();;string xm)
                {
                  if(r[xm]) newrule->add_xmit(xm);
                  else newrule->revoke_xmit(xm);
                }

                newrule->save();

                if(r->class == "user")
                {
                  object u = Fins.DataSource._default.find.users_by_id((int)r->user);
                  newrule["users"] += u;
                }
                else if(r->class == "group")
                {
                  object g = Fins.DataSource._default.find.groups_by_id((int)r->group);
                  newrule["groups"] += g;
                }

                // add the acl rule to the acl.
                g["aclrules"] += newrule;


              }
              else if(r->isChanged)
              {
                Log.debug("changing a rule");

                object oldrule = Fins.DataSource._default.find.aclrules_by_id((int)r->id);
                int cls = 0;
 
                if(r->class == "anonymous")
                  cls = 4;
                else if(r->class == "all_users")
                  cls = 2;
                else if(r->class == "owner")
                  cls = 1;

                oldrule["class"] = cls;

                foreach(oldrule->get_available_xmits();;string xm)
                {
                  if(r[xm]) oldrule->add_xmit(xm);
                  else oldrule->revoke_xmit(xm);
                }

                if(oldrule["users"])
                  foreach(oldrule["users"];; object u)
                    oldrule["users"] -= u;

                if(oldrule["groups"])
                  foreach(oldrule["groups"];; object g)
                    oldrule["groups"] -= g;

                if(r->class == "user")
                {
                  object u = Fins.DataSource._default.find.users_by_id((int)r->user);
                  oldrule["users"] += u;
                }
                else if(r->class == "group")
                {
                  object g = Fins.DataSource._default.find.groups_by_id((int)r->group);
                  oldrule["groups"] += g;
                }
              }
            }

            response->flash("msg", LOCALE(307,"ACL was updated successfully."));
            response->redirect("listacls");
            return;
          }
        }

  	response->set_view(t);
}

public void listusers(Request id, Response response, mixed ... args)
{
     object t = view->get_idview("admin/listusers");

     app->set_default_data(id, t);

	mixed ul;

	if(!id->variables->limit)
		ul = Fins.DataSource._default.find.users_all();
	
	t->add("users", ul);
    t->add("in_admin", 1);
	
	response->set_view(t);
}

public void listgroups(Request id, Response response, mixed ... args)
{
    object t = view->get_idview("admin/listgroups");

    app->set_default_data(id, t);

	mixed ul;

	if(!id->variables->limit)
		ul = Fins.DataSource._default.find.groups_all();
	
	t->add("groups", ul);
    t->add("in_admin", 1);
	
	response->set_view(t);
}

public void editgroup(Request id, Response response, mixed ... args)
{
    object t = view->get_idview("admin/editgroup");
	
    app->set_default_data(id, t);
    t->add("in_admin", 1);

    object g;

        if(id->variables->groupid)
        {
           g = Fins.DataSource._default.find.groups_by_id((int)id->variables->groupid);
	   t->add("group", g);
        }
        else
        {
           t->add("newgroup", 1);
        }

        if(id->variables->action)
        {
          if(id->variables->action == "Cancel")
          {
            response->redirect("listgroups");
            return;
          }

          else if(id->variables->action == "Save")
          {

            if(id->variables->newgroup)
              g = FinScribe.Objects.Group();

            if(id->variables->name != g["name"])
               g["name"] = id->variables->name;

            if(id->variables->newgroup)
              g->save();

            if(id->variables->added != "")
            {
              array a = id->variables->added / ",";
              foreach(a;;string toadd)
              {
                 object x = Fins.DataSource._default.find.users_by_id((int)toadd);
                 g["users"] += x;
              }
            }

            if(id->variables->removed != "")
            {
              array a = id->variables->removed / ",";
              foreach(a;;string toremove)
              {
                 object x = Fins.DataSource._default.find.users_by_id((int)toremove);
                 g["users"] -= x;
              }
            }

            response->flash("msg", LOCALE(308,"Group was updated successfully."));
            response->redirect("listgroups");
            return;
          }
        }

  	response->set_view(t);
}

public void newuser(Request id, Response response, mixed ... args)
{
    object t = view->get_idview("admin/newuser");
	
    app->set_default_data(id, t);
  	response->set_view(t);
    t->add("in_admin", 1);

   string Name, UserName, Email, Password, Password2;
   int is_active, is_admin;

        Name = "";
        UserName = "";
        Email = "";
        Password = "";

        if(id->variables->action)
        {
                Name = id->variables->name;
                UserName = id->variables->username;
                Email = id->variables->email;
                Password = id->variables->password;
                Password2 = id->variables->password2;
                is_active = (int)id->variables->is_active;
                is_admin = (int)id->variables->is_admin;


                if(id->variables->action == "Create")
                {
                        // check the username
                        if(sizeof(Name)< 2)
                        {
                                response->flash("msg", LOCALE(309,"You must provide a username with at least 2 characters."));
                                UserName = "";
                        }
                        else if(sizeof(Fins.DataSource._default.find.users((["username": UserName]))) != 0)
                        {
                                response->flash("msg", LOCALE(310,"The username you have chosen is already in use by another user."));
                                UserName = "";
                        }
                        else if(!sizeof(Name) || !sizeof(Email))
                        {
                                response->flash("msg", LOCALE(311,"You must provide a Real name and e-mail address."));

                                Name = "";
                                Email = "";
                       }
                        else if(sizeof(Password)<4 || (Password != Password2))
                        {
                                response->flash("msg", LOCALE(312,"Your password must be typed identically in both fields, and must be at least 4 characters long."));
                                Password = Password2 = "";
                        }
                        else
                        {
                                // if we got here, everything should be good to go.
                                object u = Fins.DataSource._default.new("User");
                                u["username"] = UserName;
                                u["name"] = Name;
                                u["email"] = Email;
                                u["password"] = Crypto.make_crypt_md5(Password);
                                u["is_active"] = is_active;
                                u["is_admin"] = is_admin;
                                u->save();

                               if(id->variables->added != "")
                               {
                                 array a = id->variables->added / ",";
                                 foreach(a;;string toadd)
                                 {
                                    object x = Fins.DataSource._default.find.groups_by_id((int)toadd);
                                    x["users"] += u;
                                  }
                                }

                                response->flash("msg", sprintf(LOCALE(313,"User %[0]s created successfully."), UserName));
                                response->redirect("listusers");

// now, let's set up a page for the new user.
                                object p = Fins.DataSource._default.find("object", (["path": "themes/default/newuser"]))[0];

                                object up = Fins.DataSource._default.new("Object");
                                up["path"] = u["username"];
                                up["author"] = u;
                                up["datatype"] = p["datatype"];
                                up["is_attachment"] = 0;

                                up->save();
                                up["md"]["locked"] = 1;

                                object uv = Fins.DataSource._default.new("Object_version");
                                uv["author"] = u;
                                uv["object"] = up;
                                uv["contents"] = p["current_version"]["contents"];
                                uv->save();
                        }
                }
                else if(id->variables->action == "Cancel")
                {
                    response->redirect("listusers");
                    return;
                }
                else
                {
                        response->flash("msg", sprintf(LOCALE(314,"Unknown action %[0]s"), id->variables->action));
                }

        }

          t->add("name", Name);
          t->add("username", UserName);
          t->add("email", Email);
          t->add("password", Password);
          t->add("password2", "");          

}

public void edituser(Request id, Response response, mixed ... args)
{
      object t = view->get_idview("admin/edituser");
	
    app->set_default_data(id, t);
  	response->set_view(t);
    t->add("in_admin", 1);

    object u = Fins.DataSource._default.find.users_by_id((int)id->variables->userid);
	t->add("user", u);

        if(id->variables->action)
        {
          if(id->variables->action == "Cancel")
          {
            response->redirect("listusers");
            return;
          }

          else if(id->variables->action == "Save")
          {
            if((int)id->variables->is_admin != u["is_admin"])
               u["is_admin"] = (int)id->variables->is_admin;

            if((int)id->variables->is_active != u["is_active"])
               u["is_active"] = (int)id->variables->is_active;

            if(id->variables->name != u["name"])
               u["name"] = id->variables->name;

            if(id->variables->email != u["email"])
               u["email"] = id->variables->email;


            if(id->variables->password && sizeof(id->variables->password))
            {
               if(id->variables->password != id->variables->confirmpassword)
               {
                 response->flash("msg", LOCALE(315,"You entered two differing passwords."));
                 return;
               }

               u["password"] = id->variables->password;
            }

            if(id->variables->added != "")
            {
              array a = id->variables->added / ",";
              foreach(a;;string toadd)
              {
                 object x = Fins.DataSource._default.find.groups_by_id((int)toadd);
                 x["users"] += u;
              }
            }

            if(id->variables->removed != "")
            {
              array a = id->variables->removed / ",";
              foreach(a;;string toremove)
              {
                 object x = Fins.DataSource._default.find.groups_by_id((int)toremove);
                 x["users"] -= u;
              }
            }



            response->flash("msg", LOCALE(316,"User was updated successfully."));
            response->redirect("listusers");
            return;
          }
        }

}

public void deleteuser(Request id, Response response, mixed ... args)
{
  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", LOCALE(317,"No user provided."));
  }
  if(!(u = Fins.DataSource._default.find.users_by_id((int)id->variables->userid)))
  {
    response->flash("msg", sprintf(LOCALE(318,"User id %[0]s does not exist."), id->variables->userid));
  }
  else if(id->variables->action == "Really Delete")
  {

    // first, we should reassign the documents.
    object nu = Fins.DataSource._default.find.users_by_id((int)id->variables->reassign_to);

    foreach(u["objects"];; object x)
      x["author"] = nu;
    foreach(u["versions"];; object x)
      x["author"] = nu;

    string n = u["name"];
    u->delete();
    response->flash("msg", sprintf(LOCALE(319,"User %[0]s deleted."),n));
    response->redirect("listusers");
  }
  else if(id->variables->action == "Cancel")
  {
    response->flash("msg", LOCALE(320,"User Delete Cancelled"));
    response->redirect("listusers");
  }
  else
  {
    object t = view->get_idview("admin/confirmdeleteuser");

    app->set_default_data(id, t);

    t->add("in_admin", 1);
    t->add("user", u);
    t->add("all_users", Fins.DataSource._default.find.users(([])));
    response->set_view(t);
  }
}

public void deleteacl(Request id, Response response, mixed ... args)
{
  object u;

  if(!id->variables->aclid)
  {
    response->flash("msg", "No ACL provided.");
  }
  if(!(u = Fins.DataSource._default.find.acls_by_id((int)id->variables->aclid)))
  {
    response->flash("msg", sprintf(LOCALE(321,"ACL id %[0]s does not exist."), id->variables->aclid));
  }
  else
  {
    string n = u["name"];
    u->delete();
    response->flash("msg", sprintf(LOCALE(322,"ACL %[0]s deleted."), n));
  }

  response->redirect("listacls");

}

public void deletegroup(Request id, Response response, mixed ... args)
{
  object u;

  if(!id->variables->groupid)
  {
    response->flash("msg", LOCALE(323,"No group provided."));
  }
  if(!(u = Fins.DataSource._default.find.groups_by_id((int)id->variables->groupid)))
  {
    response->flash("msg", sprintf(LOCALE(324,"Group id %[0]s does not exist."), id->variables->groupid));
  }
  else
  {
    string n = u["name"];
    u->delete();
    response->flash("msg", sprintf(LOCALE(325,"Group %[0]s deleted."), n));
  }
  response->redirect("listgroups");

}

public void toggle_useractive(Request id, Response response, mixed ... args)
{
  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", LOCALE(317,"No user provided."));
  }
  if(!(u = Fins.DataSource._default.find.users_by_id((int)id->variables->userid)))
  {
    response->flash("msg", sprintf(LOCALE(318,"User id %[0]s does not exist."), id->variables->userid));
  }
  else
  {
    u["is_active"] = !u["is_active"];
    
    string pre = "";
    if(!u["is_active"])
      response->flash("msg", sprintf(LOCALE(326,"User %[0]s deactivated."), u["name"]));
    else
      response->flash("msg", sprintf(LOCALE(327,"User %[0]s activated."), u["name"]));
  }
  response->redirect("listusers");
}


public void toggle_useradmin(Request id, Response response, mixed ... args)
{
  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", LOCALE(317,"No user provided."));
  }
  if(!(u = Fins.DataSource._default.find.users_by_id((int)id->variables->userid)))
  {
    response->flash("msg", sprintf(LOCALE(318,"User id %[0]s does not exist."), id->variables->userid));
  }
  else
  {
    u["is_admin"] = !u["is_admin"];
    
    if(!u["is_admin"])
      response->flash("msg", sprintf(LOCALE(328,"User administrative rights revoked for %[0]s."), u["name"]));
    else
      response->flash("msg", sprintf(LOCALE(329,"User administrative rights granted for %[0]s."), u["name"]));
  }
  response->redirect("listusers");
}

