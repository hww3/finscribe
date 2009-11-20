//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Tools.Logging;
import Fins;
import Fins.Model;   
inherit Fins.FinsController;

int i=0;

public void up(Request id, Response response, mixed ... args)
{
  werror("UPLOAD: %O\n", id->variables);
}

public void index(Request id, Response response, mixed ... args)
{
  response->set_data(LOCALE(334, "hello from exec, perhaps you'd like to choose a function?"));
}

public void x(Request id, Response response, mixed ... args)
{
  if(!sizeof(args))
  {
    response->redirect(action_url(app->controller));
  }
  else
  {
    object o = Fins.DataSource._default.find.objects_by_id((int)MIME.decode_base64(args[0]));
    if(!o)
      response->redirect(action_url(app->controller));
    else
      response->redirect(action_url(app->controller->space), o["path"]);
  }
}

public void notfound(Request id, Response response, mixed ... args)
{
     object t = view->get_idview("exec/objectnotfound", id);

     app->set_default_data(id, t);

     t->add("obj", args*"/");
     response->set_view(t);
}


public void notreadable(Request id, Response response, mixed ... args)
{
     object t = view->get_idview("exec/objectnotreadable", id);

     app->set_default_data(id, t);

     t->add("obj", args*"/");
     response->set_view(t);
}


public void actions(Request id, Response response, mixed ... args)
{
  object obj = model->get_fbobject(args, id);
  object t = view->get_idview("exec/actions", id);

  app->set_default_data(id, t);

  t->add("object", obj);
  t->add("islocked", obj["md"]["locked"]);
  t->add("iseditable", obj->is_editable(t->get_data()["user_object"]));
  t->add("isdeleteable", obj->is_deleteable(t->get_data()["user_object"]));
  t->add("islockable", obj->is_lockable(t->get_data()["user_object"]));
  t->add("comments_closed", obj["md"]["comments_closed"]);

  response->set_view(t);
}

public void object_properties_menu(Request id, Response response, mixed ... args)
{
  object obj = model->get_fbobject(args, id);

  object cuser = app->get_current_user(id);

  array items = ({});

  items += ({ (["title": LOCALE(335,"Edit..."), "href": combine_path(action_url(edit), args * "/"), "enabled": obj->is_writeable(cuser)]) }) ;
  items += ({ (["title": LOCALE(336,"New Child..."), "href": combine_path(action_url(new), args * "/"), "enabled": obj->is_writeable(cuser) ]) }) ;
  items += ({ (["title": LOCALE(337,"Delete..."), "href": combine_path(action_url(delete), args * "/"), "enabled": obj->is_deleteable(cuser) ]) }) ;

  if(obj["md"]["locked"])
  {
    items += ({ (["title": LOCALE(338,"Unlock"), "href": "", "enabled": obj->is_lockable(cuser)]) }) ;
  }
  else
  {
    items += ({ (["title": LOCALE(339,"Lock"), "href": "", "enabled": obj->is_lockable(cuser)]) }) ;
  }

  int readable =  obj->is_readable(cuser);

  items += ({ (["title": LOCALE(340,"Versions..."), "href": combine_path(action_url(versions), args * "/"), "enabled": readable ]) }) ;
  items += ({ (["title": LOCALE(341,"Properties..."), "href": combine_path(action_url(info), args * "/"), "enabled": readable ]) }) ;

  string json = Tools.JSON.serialize((["data": items]));
   
  response->set_data(json);
}

public void info(Request id, Response response, mixed ... args)
{
  object obj = model->get_fbobject(args, id);
  object t = view->get_idview("exec/info", id);

  app->set_default_data(id, t);

  t->add("object", obj);

  response->set_view(t);
}

public void changeacl(Request id, Response response, mixed ... args)
{
  object obj = model->get_fbobject(args, id);

   object t = view->get_idview("exec/changeacl", id);

   if(!id->variables->return_to)
   {
     t->add("return_to", id->referrer || "/space/start");
   }
   else
     t->add("return_to", id->variables->return_to);

   app->set_default_data(id, t);

   if(!obj) 
   {
     response->flash("msg", sprintf(LOCALE(342,"Unable to find the requested object, %[0]s."), args*"/"));
     response->redirect(id->referrer);
     return;
   }

   t->add("obj", obj["path"]);
   t->add("acls", Fins.Model.find.acls_all());
   t->add("currentacl", obj["acl"]);

   if(id->variables->newacl)
   {
     object a = find.acls_by_id((int)id->variables->newacl);

     obj["acl"] = a;

     response->flash("msg", LOCALE(343,"ACL changed successfully."));
     response->redirect(id->variables->return_to);
   }

   response->set_view(t);
}

public void getcomments(Request id, Response response, mixed ... args)
{
  object obj = model->get_fbobject(args, id);

  object data = view->default_data();

  data->add("obj", obj["path"]);

  app->set_default_data(id, data);

  string r = view->render_partial("exec/_comments", data->get_data(), "comment", obj["comments"]);
     
  response->set_data(r);
}

public void editcategory(Request id, Response response, mixed ... args)
{
   if(!args || !sizeof(args))
   {
     response->set_data(LOCALE(344,"You must provide an object to modify categories for."));
     return;
   }
   if(!id->misc->session_variables->userid)
   {
     response->set_data(LOCALE(345,"You must login to edit a category."));
     return;
   }

  string path = args*"/";
  array o = find.objects((["path": path]));
  object dta = view->default_data();
  dta->add("flash", "");

  if(!((!id->variables["existing-category"] || 
     !sizeof(id->variables["existing-category"])) && 
     (!id->variables["new-category"] ||
     !sizeof(id->variables["new-category"]))))
  {
    string category = id->variables["existing-category"];
    array c;

    if(!category || !sizeof(category))
    { 
      category = id->variables["new-category"];
      object nc = Fins.DataSource._default.new("category");
      nc["category"] = category;
      nc->save();
      c=({nc});
    }
    else
    {
       c = find.categories((["category": category]));
    }

  array x;
  if(sizeof(c))
    x = find.objects((["path": path, "categories": c[0]]));

  if(!sizeof(o))
  {
    dta->add("flash", sprintf(LOCALE(346, "Unknown object %[0]s."), path));
  }
  else if(!sizeof(c))
  {
    dta->add("flash", sprintf(LOCALE(347, "Unknown category %[0]s."), category));
  }
  else if(sizeof(x) && id->variables->action == "Include")
  {
    dta->add("flash", sprintf(LOCALE(348, "Category %[0]s is already assigned to this item."), category));
  }
  else if(id->variables->action == "Include")
  {
    o[0]["categories"]+=c[0];
    model->clear_categories();
    dta->add("flash", sprintf(LOCALE(349, "Added to %[0]s ."), category));
  }

  else if(id->variables->action == "Remove")
  {
    o[0]["categories"]-=c[0];
    model->clear_categories();
    dta->add("flash", sprintf(LOCALE(350, "Removed from %[0]s."), category));
  }

  }

  app->set_default_data(id, dta);
  dta->add("obj", o[0]["path"]);
  dta->add("object", o[0]);
  dta->add("existing-categories",  model->get_categories());

  response->set_data(view->render_partial("space/_categoryform", dta->get_data()));
}

public void category(Request id, Response response, mixed ... args)
{
   if(!args || !sizeof(args))
   {
     response->set_data(LOCALE(351, "You must provide a category to view."));
   }

    object t = view->get_idview("exec/category", id);

   app->set_default_data(id, t);

   array c = find.categories((["category": args[0]]));
  
   if(!c || !sizeof(c))
   {
     response->set_data(sprintf(LOCALE(352, "Category %[0]s does not exist."), args[0]));
     return;
   }

   t->add("category", c[0]);
   t->add("objects", c[0]["objects"]);

   response->set_view(t);
}

public void backlinks(Request id, Response response, mixed ... args)
{
   if(!args || !sizeof(args))
   {
     response->set_data(LOCALE(353, "You must provide an object to view the backlinks for."));
   }

   object obj_o;

   object t;
   if(id->variables->ajax)
     t = view->get_idview("exec/_backlinks", id);
   else
     t = view->get_idview("exec/backlinks", id);

   app->set_default_data(id, t);

   obj_o = model->get_fbobject(args, id);

   if(!obj_o)
   {
     response->set_data(sprintf(LOCALE(354,"Object %[0]s does not exist."), args*"/"));
     return;
   }

   t->add("object", obj_o);

   mixed bl = obj_o["md"]["backlinks"];
 
   if(!bl) bl = ({});
   array bal;
   bal = find.objects((["path": Fins.Model.InCriteria(bl)]));
   t->add("objects", bal);
   response->set_view(t);
}

public void deletecomment(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(355, "You must login to delete comments."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
  
   if(!id->variables->id)
   {
      response->flash("msg", LOCALE(356,"You provide a comment id to delete."));
      response->redirect(id->referrer || "/space/");
      return;
   }

   object c = find.comments_by_id((int)id->variables->id);

   if(!c)
   {
      response->flash("msg", sprintf(LOCALE(357,"Comment #%[0]s does not exist."), id->variables->id));
      response->redirect(id->referrer || "/space/");
      return;
   }

   // we need to add a check for admin privs here.
   // user["is_admin"]
   object us = find.users_by_id((int)id->misc->session_variables->userid);
   if(us["is_admin"] || (us["id"] == c["object"]["author"]["id"]))
   {
     // we can delete!
      c->delete();
      response->flash("msg", LOCALE(358,"Comment deleted successfully."));
      response->redirect(id->referrer || "/space/");
      return;

   }
   else
   {
      response->flash("msg", "Only administrators and page owners can delete comments.");
      response->redirect(id->referrer || "/space/");
      return;
   }

     response->flash("msg", LOCALE(359,"How'd we get here?"));
}

public void createaccount(Request id, Response response, mixed ... args)
{
   object t = view->get_idview("exec/createaccount", id);

   app->set_default_data(id, t);

   string Name, UserName, Email, Password, Password2, return_to;

	Name = "";
	UserName = "";
	Email = "";
	Password = "";
   return_to = "/space/start";
	
	if(id->variables->action)
	{
		Name = id->variables->name;
		UserName = id->variables->username;
		Email = id->variables->email;
		Password = id->variables->password;
		Password2 = id->variables->password2;
		return_to = id->variables->return_to;

		if(id->variables->action == "Create")
		{

         mixed e,a;
         e = catch(a=app->trigger_event("preCreateAccount", id));

         if(e || a == FinScribe.abort)
          {
            if(!e) e = ({"An unknown error occurred."});
            if(id->variables->ajax)
            {
              response->set_data(LOCALE(0,"Error: " + e[0]));
              return;
            }
            response->flash("msg", LOCALE(0,"Error: " + e[0]));
            response->redirect(Tools.Function.this_function());
            return;
          }


			// check the username
			if(sizeof(Name)< 2)
			{
				response->flash("msg", LOCALE(309,"You must provide a username with at least 2 characters."));
			}
			else if(sizeof(find.users((["username": UserName]))) != 0)
			{
				response->flash("msg", LOCALE(310,"The username you have chosen is already in use by another user."));
			}
			else if(!sizeof(Name) || !sizeof(Email))
			{
				response->flash("msg", LOCALE(311,"You must provide a Real name and e-mail address."));
			}
			else if(sizeof(Password)<4 || (Password != Password2))
			{
				response->flash("msg", LOCALE(312,"Your password must be typed identically in both fields, and must be at least 4 characters long."));
			}
			else
			{
				// if we got here, everything should be good to go.
				object u = Fins.DataSource._default.new("user");
				u["username"] = UserName;
				u["name"] = Name;
				u["email"] = Email;
				u["password"] = Password;
                u["is_active"] = 1;
				u->save();

				response->flash("msg", LOCALE(360,"User created successfully."));
				response->redirect("/space/start");
				
				object p = find.objects((["path": "themes/default/newuser"]))[0];
				
				object up = Fins.DataSource._default.new("object");
				up["path"] = u["username"];
				up["author"] = u;
				up["datatype"] = p["datatype"];
				up["is_attachment"] = 0;
				
				up->save();
				up["md"]["locked"] = 1;
				
				object uv = Fins.DataSource._default.new("object_version");
				uv["author"] = u;
				uv["object"] = up;
				uv["contents"] = p["current_version"]["contents"];
				uv->save();
			}
		}
                else if(id->variables->action == "Cancel")
                {
                    response->redirect("/space/");
                    return;
                }
		else
		{
			response->flash("msg", sprintf(LOCALE(361,"Unknown action %[0]s."), id->variables->action));
		}
	}

   t->add("name", Name);
   t->add("username", UserName);
   t->add("email", Email); 
   t->add("password", Password);

   response->set_view(t);
}

public void forgotpassword(Request id, Response response, mixed ... args)
{
    object t = view->get_idview("exec/forgotpassword", id);

     app->set_default_data(id, t);

	 t->add("username", "");

		if(id->variables->username)
		{
			t->add("username", id->variables->username);
			array a = find.users((["username": id->variables->username]));

			if(!sizeof(a))
			{
				response->flash("msg", LOCALE(362,"Unable to find a user account with that username. Please try again."));
			}
			
			else
			{

                object tp = view->get_idview("exec/sendpassword", id);

				
				tp->add("password", a[0]["password"]);
				
				string mailmsg = tp->render();
				
				Protocols.SMTP.Client(app->get_sys_pref("mail.host")->get_value())->simple_mail(a[0]["email"], 
																											"Your FinScribe password", 
										app->get_sys_pref("mail.return_address")->get_value(), 
																											mailmsg);
				
				response->flash("msg", LOCALE(363,"Your password has been located and will be sent to the email address on record for your account."));
				response->redirect("/exec/login");
			}
			
		}
     response->set_view(t);
}

public void logout(Request id, Response response, mixed ... args)
{
  if(id->misc->session_variables->userid)
  {
     id->misc->session_variables->logout = time();
     m_delete(id->misc->session_variables, "userid");
  }

  response->redirect(id->referrer||"/space/");
}

public void upload(Request id, Response response, mixed ... args)
{
  if(!id->variables->root || !strlen(id->variables->root)) 
  {
    response->set_data(LOCALE(364,"No attachment location specified."));
    return;
  }
  
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(365,"You must login to upload."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   } 

  string path = Stdio.append_path(id->variables->root, id->variables["save-as-filename"]);
  string obj=id->variables->root;
  array a = find.objects((["path": obj ]));
  object obj_o;
  object p;
  if(sizeof(a)) p = a[0];
  else 
  {
    throw(Error.Generic("Unable to find root object to attach this document to.\n"));
  }
  
               array dtos = find.datatypes((["mimetype": Protocols.HTTP.Server.filename_to_type(id->variables["save-as-filename"])]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", sprintf(LOCALE(366,"Mime type %[0]s for file %[1]s is not valid."), 
                     Protocols.HTTP.Server.filename_to_type(id->variables["save-as-filename"]),
                     id->variables["save-as-filename"]));
               }
               else{              
               object dto = dtos[0];
               obj_o = Fins.DataSource._default.new("object");
               obj_o["datatype"] = dto;
               obj_o["is_attachment"] = 1;
               obj_o["parent"] = p;
               obj_o["author"] = find.users_by_id(id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o->save();

            object obj_n = Fins.DataSource._default.new("object_version");
            obj_n["contents"] = id->variables["upload-file"];

            int v;
            object cv;

            obj_o->refresh();

            if(cv = obj_o["current_version"])
            { 
              v = cv["version"];
            }
            obj_n["version"] = (v+1);
            obj_n["object"] = obj_o;
            obj_n["author"] = find.users_by_id(id->misc->session_variables->userid);
            obj_n->save();
            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));
            response->flash("msg", LOCALE(367,"Succesfully Saved."));

            }

            response->redirect("/space/" + obj);
}

public void editattachments(Request id, Response response, mixed ... args)
{
  int viaframe = 0;

//werror("editattachments: %O\n", id->variables);

  if(!args || !sizeof(args)) 
  {
    response->set_data(LOCALE(364,"No attachment location specified."));
    return;
  }
  
   if(!id->misc->session_variables->userid)
   {
      response->set_data(LOCALE(365,"You must login to upload."));
      return;
   } 


  object t = view->get_idview("exec/_editattachments", id);
  t->add("flash", "");

    string obj=args*"/";
    array a = find.objects((["path": obj ]));
    object p;
    if(sizeof(a)) p = a[0];
    else 
    {
      response->set_data(LOCALE(368,"Unable to find root object to attach this document to."));
      return;
    }

  if(id->variables->action == "Delete") 
  {
    viaframe = 1;
    if(!id->variables["save-as-filename"])
    {
      t->add("flash", LOCALE(369,"No filename specified to delete."));
    }
    else
    {
      array o = find.objects((["path": id->variables["save-as-filename"], "is_attachment": 1]));
      if(!sizeof(o))
      {
        t->add("flash", sprintf(LOCALE(370,"Cannot find file %[0]s"), id->variables["save-as-filename"]));
      }
      else
      {
        o[0]->delete(1);
        t->add("flash", sprintf(LOCALE(371,"Sucessfully deleted %[0]s"), id->variables["save-as-filename"]));
      }
    }
  }

  array o = find.objects(([ "is_attachment": 1, "parent": p ]));
  array datatypes = model->get_datatypes();  
  t->add("object", p);
  t->add("numattachments", sizeof(o));
  t->add("attachments", o);
  t->add("datatypes", datatypes);

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

public void addattachments(Request id, Response response, mixed ... args)
{
  //werror("addattachments!: %O\n", args);
  
  // workaround for flash player not passing cookies properly
  if(id->variables->PSESSIONID)
  {
    id->misc->session_variables = id->get_session_by_id(id->variables->PSESSIONID);
    if(id->misc->session_variables) id->misc->session_variables = id->misc->session_variables->data;
  }

   if(!id->misc->session_variables->userid)
   {
    Log.debug("You must login to upload.");
      response->set_data(LOCALE(365,"You must login to upload."));
    response->set_error(500);
      return;
   } 

    string obj=args*"/";
    array a = find.objects((["path": obj ]));
    object p;
    if(sizeof(a)) p = a[0];
    else 
    {
    Log.debug("unable to find root object for attachment.");
      response->set_data(LOCALE(368,"Unable to find root object to attach this document to."));
    response->set_error(500);
      return;
    }

    string path = Stdio.append_path(obj, id->variables["userfile.filename"]);
    object obj_o;
  
    array dtos = find.datatypes((["mimetype": Protocols.HTTP.Server.filename_to_type(id->variables["userfile.filename"])]));
    if(!sizeof(dtos))
    {

       Log.debug("Mime type " + Protocols.HTTP.Server.filename_to_type(id->variables["userfile.filename"]) + " for file " + id->variables["userfile.filename"] + " is not valid.");
       response->set_data(sprintf(LOCALE(366,"Mime type %[0]s for file %[1]s is not valid."), 
             Protocols.HTTP.Server.filename_to_type(id->variables["userfile.filename"]), id->variables["userfile.filename"]));
       response->set_error(500);
       return;
    }

    array x = Fins.Model.find("object", (["path": path]));
    if(sizeof(x))
    {
      obj_o = x[0];
    }
    else
    {       
      mixed e = catch {
        object dto = dtos[0];
        obj_o = Fins.DataSource._default.new("object");
        obj_o["datatype"] = dto;
        obj_o["is_attachment"] = 1;
        obj_o["parent"] = p;
        obj_o["author"] = find.users_by_id(id->misc->session_variables->userid);
        obj_o["datatype"] = dto;
        obj_o["path"] = path;
        obj_o->save();
      };
    }

      object obj_n = Fins.DataSource._default.new("object_version");
      obj_n["contents"] = id->variables["userfile"];

      int v;
      object cv;
      obj_o->refresh();

      if(cv = obj_o["current_version"])
      { 
        v = cv["version"];
      }
      else
      {
        werror("no existing version.\n");         
      }
      obj_n["version"] = (v+1);
      obj_n["object"] = obj_o;
      obj_n["author"] = find.users_by_id(id->misc->session_variables->userid);
      obj_n->save();
      cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));


  response->set_data("ok");
}

public void login(Request id, Response response, mixed ... args)
{
     object t;

   if(id->variables->ajax)
   {
     t = view->get_idview("exec/_login", id);
     t->add("ajax", 1);
   }
   else t = view->get_idview("exec/login", id);

   app->set_default_data(id, t);

   if(!id->variables->return_to)
   {
      id->variables->return_to = ((id->misc->flash && id->misc->flash->from) || 
                               id->variables->referrer || id->referrer || 
	                               "/space/");
   }

   if(!id->variables->username)
      t->add("username", "");


   if(app->get_sys_pref("administration.autocreate") && 
         app->get_sys_pref("administration.autocreate")->get_value())
	{
		t->add("autocreate", 1);
	}
	else
	{
		t->add("autocreate", 0);
	}
	
   if(id->variables->action)
   {
      if(id->variables->action == "Cancel")
      {
         response->redirect(id->variables->return_to);
         return;
      }
      
      array r = find.users((["username": id->variables->username, 
                                        "password": id->variables->password, 
                                        "is_active": 1]));
      if(r && sizeof(r))
      {
         // success!
         id->misc->session_variables->logout = 0;
         id->misc->session_variables["userid"] = r[0]["id"];
         if(search(id->variables->return_to, "?") < -1)
           id->variables->return_to = id->variables->return_to + "&" + time();
         else
           id->variables->return_to = id->variables->return_to + "?" + time();
         response->redirect(id->variables->return_to);
         return;
      }
      else
      {
         response->flash("msg", LOCALE(372,"Login Incorrect."));
         t->add("username", id->variables->username);
         
      }
   }
   
         t->add("return_to", id->variables->return_to);
   response->set_view(t);
}

public void get_content(Request id, Response response, mixed ... args)
{
  object obj_o = model->get_fbobject(args, id);
  if(!obj_o->is_readable(app->get_current_user(id) ))
    response->set_data(LOCALE(373,"You do not have read permission"));
  else
    response->set_data(app->render(obj_o->get_object_contents(), obj_o, id));
}

public void comments(Request id, Response response, mixed ... args)
{
   string contents, title, obj;
   object obj_o;

werror("POST: %O\n", id->variables);

   int anonymous = app->get_sys_pref("comments.anonymous")->get_value();
 
   if(!id->misc->session_variables->userid && 
             !anonymous)
   {
     if(id->variables->ajax)
     {
       response->set_data(LOCALE(374,"You must login to comment."));
       return;
     }
      response->flash("msg", LOCALE(374,"You must login to comment."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
   else if(!id->misc->session_variables->userid && anonymous)
   {
     anonymous = 1;
   }
   else anonymous = 0;

   id->misc->anonymous = anonymous;

   obj_o = model->get_fbobject(args, id);

   if(obj_o["md"]["comments_closed"] == 1)
   {
     if(id->variables->ajax)
     {
       response->set_data(LOCALE(375,"Comments for this article have been closed."));
       return;
     }
     response->flash("msg", LOCALE(375,"Comments for this article have been closed."));
     response->redirect("/comments/" + obj_o["path"]);
     return;
   }
 
  title = obj_o["title"];
   obj = args*"/";
  
  object t;

   if(id->variables->ajax)
   {
     t = view->get_idview("exec/_comment", id);
     t->add("ajax", 1);
   }
   else t = view->get_idview("exec/comment", id);

   app->set_default_data(id, t);

   t->add("object", app->render(obj_o["current_version"]["contents"], 
                                                        obj_o, id));
   response->set_view(t);

   if(id->variables->action)
   {
      contents = id->variables->contents;
      switch(id->variables->action)
      {
         case "Preview":
            t->add("preview", app->render(contents, obj_o, id));
            break;
         case "Save":

         mixed e,a;
         e = catch(a=app->trigger_event("prePostComment", id, obj_o));

         if(e || a == FinScribe.abort)
          {
            if(!e) e = ({"An unknown error occurred."});
            if(id->variables->ajax)
            {
              response->set_data(LOCALE(0,"Error: " + e[0]));
              return;
            }
            response->flash("msg", LOCALE(0,"Error: " + e[0]));
            response->redirect("/comments/" + obj_o["path"]);
            return;
          }

          if(anonymous && ! (id->variables->email && id->variables->name))
          {
             response->flash("msg", LOCALE(377,"Name and Email are required for posting without logging in."));
             break;
          }

          if(anonymous && (!sizeof(id->variables->email) || !sizeof(id->variables->name)))
          {
             response->flash("msg", LOCALE(377,"Name and Email are required for posting without logging in."));
             break;
          }
          object obj_n = Fins.DataSource._default.new("comment");
            obj_n["contents"] = contents;
            obj_n["object"] = obj_o;
            if(anonymous)
            {
              obj_n["author"] = find.users((["username": "anonymous"]))[0];
            }
            else
              obj_n["author"] = find.users_by_id(id->misc->session_variables->userid);

            obj_n->save();
            if(anonymous)
            {
              obj_n["md"]["name"] = id->variables->name;
             
              if(id->variables->website)
                obj_n["md"]["website"] = id->variables->website;
  
              obj_n["md"]["email"] = id->variables->email;
            }
            if(!id->variables->ajax)
			{
	      	  response->flash("msg", LOCALE(367,"Succesfully Saved."));
              response->redirect("/space/" + obj);
			}
			else
			{
				response->set_data("OK");
				return;
			}
          break;
       default:
          response->set_data(sprintf(LOCALE(378,"Unknown comment action %[0]s"), id->variables->action));
          return; 
          break;
      }
   }
   else
   {
     contents = "";
   }

   if(anonymous)
   {
     t->add("website", id->variables->website || "");
     t->add("email", id->variables->email || "");
     t->add("name", id->variables->name || "");
     if(!id->variables->check)
     {
       id->variables->check = get_checkid();
       id->misc->session_variables[id->variables->check] = make_checkval();
     }
     t->add("check", id->variables->check);
   }

   string check_value = id->variables->check_value || "";

   t->add("check_value", check_value);
   t->add("anonymous", anonymous);
   t->add("contents", contents);
   t->add("title", title);
   t->add("obj", obj);   
}

public void check_image(object id, object response, mixed ... args)
{
  string v;

  if(!args[0])
    v = "INVALID REQUEST";

  if(!id->misc->session_variables[args *"/"])
    v = "INVALID REQUEST";
  else 
    v = id->misc->session_variables[args *"/"];

Log.debug("in check image.");
  object img;
  mixed e;
  if(e =catch(img = Image.Fonts.open_font("goo", 48,0, 1)
                    ->write(v)))
    Log.exception("error!", e);

Log.debug("wrote image, encoding.");

  string i = Image.GIF.encode(img->phaseh());
Log.debug("encoded.");

  response->set_data(i);
  response->set_type("image/gif");
}

private string get_checkid()
{
  return lower_case(MIME.encode_base64(Crypto.Random.random_string(8))[0..5]);
}

private string make_checkval()
{
   return lower_case(MIME.encode_base64(Crypto.Random.random_string(8))[0..5]);
}

public void toggle_lock(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(379,"You must login to lock objects."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

  object obj_o = model->get_fbobject(args, id);

	if(!obj_o)
	{
		response->flash("msg", sprintf(LOCALE(354,"Object %[0]s does not exist."), args*"/"));
      response->redirect(id->referrer);		
 		return;
	}

   if((obj_o["author"]["id"] != id->misc->session_variables->userid) && !find.users_by_id(id->misc->session_variables->userid)["is_admin"])
	{
		response->flash("msg", LOCALE(380,"A locked object can only be toggled by its owner or an administrator."));
      response->redirect(id->referrer);		
		return;
	}
	
	obj_o["md"]["locked"] = !obj_o["md"]["locked"];

   if(obj_o["md"]["locked"])
     response->flash("msg", LOCALE(381,"Object successfully locked."));
   else
     response->flash("msg", LOCALE(382,"Object successfully ulocked."));
   response->redirect(id->referrer);
}

public void toggle_comments(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(383,"You must login to toggle comments."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

  object obj_o = model->get_fbobject(args, id);

	if(!obj_o)
	{
		response->flash("msg", sprintf(LOCALE(354,"Object %[0]s does not exist."), args*"/"));
      response->redirect(id->referrer);		
		return;
	}

   if((obj_o["author"]["id"] != id->misc->session_variables->userid) && !find.users_by_id(id->misc->session_variables->userid)["is_admin"])
	{
		response->flash("msg", LOCALE(384,"Comments on an object can only be toggled by its owner or an administrator."));
      response->redirect(id->referrer);		
		return;
	}
	
	obj_o["md"]["comments_closed"] = !obj_o["md"]["comments_closed"];

   if(obj_o["md"]["comments_closed"])
     response->flash(LOCALE(385,"Comments successfully disabled.")); 
   else
     response->flash(LOCALE(386,"Comments successfully enabled."));

   response->redirect(id->referrer);
}

public void new(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(387,"You must login to edit content."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   if(id->variables->title)
   {
     if(id->variables->currentpage && id->variables->pageloc)
     {
       switch(id->variables->pageloc)
       {
         case "subpage":
           if(arrayp(id->variables->currentpage)) id->variables->currentpage = id->variables->currentpage[0];

           id->variables->title = combine_path(id->variables->currentpage, id->variables->title);

           break;
         case "parentpage":
           if(arrayp(id->variables->currentpage))
             id->variables->currentpage = id->variables->currentpage[0];
           id->variables->title = combine_path(id->variables->currentpage, "..", id->variables->title);
           break;
         case "manual":
         default:
           break;
       }
     }


     response->redirect("/exec/edit/" + id->variables->title + "?datatype=" + id->variables->datatype);
     return;
   }   

     object t = view->get_idview("exec/new", id);

     app->set_default_data(id, t);

     mixed p = app->new_string_pref(t->get_data()["user_object"]["username"] + ".new.default_mimetype", "text/wiki");

     array mimetypes = ({});

     foreach(app->engines; string ty; mixed e)
     { 
       mapping t = ([]);
       t->mimetype = ty;
       if(e->typename) t->name = e->typename;

       mimetypes+= ({t});
     }

    if(id->variables->currentpage)
    {
      object obj_o;

      obj_o = model->get_fbobject(id->variables->currentpage/"/", id);
      t->add("object", obj_o);

      obj_o =  model->get_fbobject(combine_path(id->variables->currentpage, "..") /"/", id);
      t->add("parentobject", obj_o);
    }

     t->add("currentpage", id->variables->currentpage);
     t->add("datatypes", mimetypes);
     t->add("datatype", p->get_value());
     response->set_view(t);
}

public void move(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(388,"You must login to move content."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   object obj_o; 
   object t;
   string newpath;
   string movesub;

   t = view->get_idview("exec/move", id);
   obj_o = model->get_fbobject(args, id);

   app->set_default_data(id, t);

   if(!obj_o)
   {
      response->flash("msg", sprintf(LOCALE(389,"This is a non-existent object: %[0]s"), args*"/"));
      response->redirect(id->referrer);		
      return;
   }

   if(obj_o && !obj_o->is_deleteable(t->get_data()["user_object"]))
   {
      response->flash("msg", LOCALE(390,"You do not have permission to move this object"));
      response->redirect(id->referrer);		
      return;
   }

   if(id->variables->newpath)
   {
     newpath = id->variables->newpath;
   }   
   else
   {
     newpath = obj_o["path"];
   }

   array a = ({});

   if(id->variables->action == "Cancel")
   {
     response->flash("msg", LOCALE(391,"Move operation cancelled."));
     response->redirect("/space/" + (args*"/"));
     return;
   }

   if(id->variables->action == "Move")
   {
     if(newpath == obj_o["path"])
     {
       response->flash("msg", LOCALE(392,"You must specify a location to move to."));
     }
     else
     {
       string oldpath = obj_o["path"];

       if(id->variables->movesub)
         a = Fins.Model.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += Fins.Model.find("object", ([ "path": oldpath, 
                 "type": Fins.Model.Criteria("is_attachment = 2") ]));

       a += Fins.Model.find("object", ([ "path": oldpath ]));

       array overlaps = ({});

       foreach(a;;mixed p)
       {
         // is it really as simple as just renaming the path?
         string pth = p["path"];
         pth = newpath + ((sizeof(pth) > sizeof(newpath))?(pth[sizeof(newpath)-1..]):"");
Log.debug("Checking to see if %s has an overlap at %s...", p["path"], pth);
         if(!p->is_deleteable(t->get_data()["user_object"]) || 
                   sizeof(Fins.Model.find("object", ([ "path": pth]))))
         {
           overlaps += ({pth});
         }
       }

       if(sizeof(overlaps))
       {
         response->flash("msg", LOCALE(393,"One or more objects already exist in the location you're moving to or cannot be moved because of permissions") + ":<p/>" + (overlaps*"<br>") );
       }
       else 
       {       
         if(a && sizeof(a))
           t->add("affected", a);
         t->add("getconfirm", 1);
         if(id->variables->movesub)
           t->add("movesub", id->variables->movesub);
       }
     }
   }

   if(id->variables->action == "Really Move")
   {
     // ok, first, let's get a list of objects to move.
     string oldpath = obj_o["path"];
 
       if(id->variables->movesub)
         a = Fins.Model.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += Fins.Model.find("object", ([ "path": oldpath, 
                 "type": Fins.Model.Criteria("is_attachment = 2") ]));

     a += Fins.Model.find("object", ([ "path": oldpath ]));

     int n;
     foreach(a;; object p)
     {
       // is it really as simple as just renaming the path?
       string pth = p["path"];
       pth = newpath + ((sizeof(pth) > sizeof(newpath))?(pth[sizeof(newpath)-1..]):"");

Log.debug("moving %s to %s.", p["path"], pth);
 
       p["path"] = pth;
       cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", p->get_id()));
       n++;
     }

     t->add("msg", sprintf(LOCALE(394,"%[0]s objects moved."), (string)n));
     response->redirect("/space/" + newpath);
     return;
   }

   

   t->add("object", obj_o);
   t->add("newpath", newpath);
 
   response->set_view(t);
}

public void delete(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(395,"You must login to delete content."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   object obj_o; 
   object t;
   string newpath;
   string movesub;

   t = view->get_idview("exec/delete", id);
   obj_o = model->get_fbobject(args, id);

   app->set_default_data(id, t);

   if(!obj_o)
   {
      response->flash("msg", sprintf(LOCALE(389,"This is a non-existent object: %[0]s"), args*"/"));
      response->redirect(id->referrer);	
      return;
   }

   if(obj_o && !obj_o->is_deleteable(t->get_data()["user_object"]))
   {
      response->flash("msg", LOCALE(396,"You do not have permission to delete this object"));
      response->redirect(id->referrer);		
      return;
   }

   array a = ({});

   newpath = "/space/" + combine_path(args*"/", "..");
   

   if(id->variables->action == "Delete")
   {
       string oldpath = obj_o["path"];

     if(id->variables->movesub)
         a = Fins.Model.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += Fins.Model.find("object", ([ "path": oldpath + "/%", 
                 "type": Fins.Model.Criteria("is_attachment = 2") ])) || ({});

       a += Fins.Model.find("object", ([ "path": oldpath ])) || ({});

       array overlaps = ({});

       foreach(a;;mixed p)
       {
Log.debug("Checking to see if %s is deleteable...", p["path"]);
         if(!p->is_deleteable(t->get_data()["user_object"]))
         {
           overlaps += ({p["path"]});
         }
       }

       if(sizeof(overlaps))
       {
         response->flash("msg", LOCALE(397,"You do not have permission to delete one or more objects") + ":<p/>" + (overlaps*"<br>") );
       }
       else 
       {       
         t->add("getconfirm", 1);
         if(a)
           t->add("affected", a);
         if(id->variables->movesub)
           t->add("movesub", id->variables->movesub);
       }
   }

   if(id->variables->action == "Really Delete")
   {
     // ok, first, let's get a list of objects to move.
     array a;
     string oldpath = obj_o["path"];
 
     if(id->variables->movesub)
         a = Fins.Model.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += Fins.Model.find("object", ([ "path": oldpath + "/%", 
                 "type": Fins.Model.Criteria("is_attachment = 2") ])) || ({});

     a += Fins.Model.find("object", ([ "path": oldpath ])) || ({});

     int n;
     foreach(a;; object p)
     {
       string pth = p["path"];

       Log.debug("deleting %s.", p["path"]);
       int pid = p->get_id();
       foreach(p["comments"];; object c)
          c->delete(1);
       p->delete(1);
 
       cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", pid));
       n++;
     }

     t->add("msg", sprintf(LOCALE(398,"%[0]d objects deleted."), n));
     response->redirect(app->controller->space);
     return;
   }

   

   t->add("object", obj_o);
   t->add("newpath", newpath);
 
   response->set_view(t);
}

public void edit(Request id, Response response, mixed ... args)
{
   string contents, title, obj, subject, datatype;
   object obj_o;
   
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(387,"You must login to edit content."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
   
   obj_o = model->get_fbobject(args, id);
   title = args[-1];
   obj = args*"/";

   object t;
   if(id->variables->ajax)
     t = view->get_idview("exec/_edit", id);
   else
     t = view->get_idview("exec/edit", id);
   object np;

   app->set_default_data(id, t);

   if(obj_o && !obj_o->is_editable(t->get_data()["user_object"]))
   {
	response->flash("msg", LOCALE(399,"You do not have permission to edit this object."));
        response->redirect(id->referrer);		
	return;
   }
   else if(!obj_o)
   {
     np = model->find_nearest_parent(args*"/");
     if(!np) 
     {
        object acl = Fins.Model.find.acls_by_id(1);
        if(!acl)
        {
	  response->flash("msg", LOCALE(400,"No default ACL found."));
	  response->redirect(id->referrer);
          return;
        }
        if(!acl->has_xmit(t->get_data()["user_object"], "write", 0))
	{
	  response->flash("msg", LOCALE(400,"You do not have permission to create this object."));
	  response->redirect(id->referrer);
          return;
	}
     }
     else if(!np->is_writeable(t->get_data()["user_object"]))
     {
	response->flash("msg", LOCALE(400,"You do not have permission to create this object."));
        response->redirect(id->referrer);		
	return;
     }
   }

   datatype = id->variables->datatype;
   if(arrayp(id->variables->datatype)) datatype = id->variables->datatype[0];  
   else
   datatype = id->variables->datatype;

   if(!datatype && obj_o)  datatype = obj_o["datatype"]["mimetype"];
   else if(!datatype)
   {
     datatype = app->new_string_pref(t->get_data()["user_object"]["username"] + ".new.default_mimetype", "text/wiki")->get_value();
   }

   if(id->variables->action)
   {
      object dto;
      contents = id->variables->contents;
      subject = id->variables->subject ||"";
      switch(id->variables->action)
      {
	 case "Cancel":
            response->flash("msg", LOCALE(401,"Edit cancelled."));
	    response->redirect("/space/" + obj);
	    return;
	            break;
         case "Preview":
            t->add("preview", app->render(contents, obj_o, id));
            break;
         case "Save":
            if(!obj_o)
            {
               Log.debug("Looking for " + datatype );
               array dtos = find.datatypes((["mimetype": datatype]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", LOCALE(402,"Internal Database Error, unable to save."));
                  break;
               }
              
               dto = dtos[0];
               obj_o = Fins.DataSource._default.new("object");
               obj_o["is_attachment"] = 0;
               obj_o["datatype"] = dto;
               obj_o["author"] = find.users_by_id(id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = obj;

               // we make the acl of this object the same as our nearest 
               // parent. we can change this later.
               if(np) obj_o["acl"] = np["acl"];

               obj_o->save();
            }

            object obj_n = Fins.DataSource._default.new("object_version");
            obj_n["contents"] = contents;

            int v;
            object cv;

            obj_o->refresh();

            if(cv = obj_o["current_version"])
            { 
              v = cv["version"];
            }
            obj_n["version"] = (v+1);
            obj_n["object"] = obj_o;  
            if(subject && sizeof(subject))
              obj_n["subject"] = subject;
            obj_n["author"] = find.users_by_id(id->misc->session_variables->userid);
            obj_n->save();
            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));
            string dtp = obj_o["datatype"]["mimetype"];
            if(dtp == "text/template")
            {
               view->flush_template(args[2..]*"/");            }

            response->flash("msg", LOCALE(367,"Succesfully Saved."));
            response->redirect("/space/" + obj + "?" + time());

            app->trigger_event("postSave", id, obj_o);
            break;

         default:
            response->set_data(sprintf(LOCALE(403,"Unknown edit action %[0]s"), id->variables->action));
            return;
            break;
      }
   }
   else
   {
      if(obj_o)
      {
         contents = obj_o->get_object_contents(id);
         subject = obj_o["current_version"]["subject"];
         if(!subject || subject == "0") subject = "";
      }
      else
      {
         contents = "";
	 subject = "";
      }
   }

   t->add("contentswidget", app->get_widget_for_type(t, datatype, contents));
   t->add("subject", subject);
   t->add("datatype", datatype);
   t->add("title", title);
   t->add("obj", obj);
   
   response->set_view(t);
}

public void publish(Request id, Response response, mixed ... args)
{
//   Log.debug("PUBLISH: %O -> %O\n", id, id->variables);
   string contents, subject, obj, trackbacks, createddate;
   object obj_o;
   int just_saving = 0;

   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(404,"You must login to publish."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
   
   obj_o = model->get_fbobject(args, id);
   if(!obj_o || obj_o["is_attachment"] != 3)
   {
     response->flash("msg", LOCALE(405,"Object doesn't exist, or isn't a WIP weblog entry."));
     response->redirect(id->referrer);
     return;
   }

   if(!obj_o->is_postable(app->get_current_user(id)))
   {
     response->flash("msg", LOCALE(406,"You don't have permission to publish (post) this object."));
     response->redirect(id->referrer);
     return;
   }

   // ok, what are the rules for publishing?
   // we assume that the following will happen upon publication:
   //
   // 1. the is_attachment flag will be set properly.
   // 2. the acl will be set to that of the parent.
   // 3. the parent (weblog) will be flushed.
   // 4. the postSave event will be triggered.
   //
   // TODO:
   //
   // we need to revisit the whole post/save blog/save article
   // relationship to better understand what events we should be
   // triggering and the context of the events. for example,
   // we probably don't want wip blog entries to be full text
   // searchable.

  obj_o["is_attachment"] = 2;
  obj_o["acl"] = obj_o["parent"]["acl"];

  cache->clear(app->get_renderer_for_type(obj_o["parent"]["datatype"]["mimetype"])->make_key(obj_o["parent"]->get_object_contents(), 
                                                     obj_o["parent"]["path"]));

  app->trigger_event("postSave", id, obj_o);

  response->flash("msg", LOCALE(407,"Object published successfully."));
  response->redirect(id->referrer);
}

//! we don't check to make sure that a page has a {weblog}
//! entry, so malicious people could theoretically create post 
//! objects to a non-existent weblog (though the page must exist
//! and the user must have post permission, so this limits the
//! danger of this shortcoming.
public void post(Request id, Response response, mixed ... args)
{
   Log.debug("POST: %O -> %O\n", id, id->variables);
   string contents, subject, obj, trackbacks, createddate;
   object obj_o;
   int just_saving = 0;

   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(408,"You must login to post."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
   
   obj_o = model->get_fbobject(args, id);

   obj = args*"/";
   subject = "";
   contents = "";
   trackbacks = "";
   createddate = "";

   object t;
   if(id->variables->ajax)
   {
     t = view->get_idview("exec/_post", id);
     t->add("ajax", 1);
   }
   else t = view->get_idview("exec/post", id);

   t->add("object", obj_o);
   t->add("showcreated", "disabled=\"1\"");
   t->add("createchecked", "selected=\"0\"");
   
   app->set_default_data(id, t);

   if(!obj_o->is_postable(t->get_data()["user_object"]))
   {
     if(id->variables->ajax)
     {
       response->set_data(LOCALE(409,"You are not authorized to post to this weblog."));
     }
     else
     {
       response->flash("msg", LOCALE(409,"You are not authorized to post to this weblog."));
       response->redirect(id->referrer || "/space/");
     }
     return;     
   }

   if(id->variables->action)
   {
      contents = id->variables->contents;
      subject = id->variables->subject;
      trackbacks = id->variables->trackbacks;
      switch(id->variables->action)
      {
	 case "Cancel":
            if(id->variables->ajax)
            {
              response->set_data(LOCALE(410,"Blog posting cancelled."));
            }
            else
            {
              response->flash("msg", LOCALE(411,"Blog Posting cancelled."));
  	      response->redirect("/space/" + obj);
            }
	    return;
            break;
         case "Preview":
			if(id->variables->createddate)
			{
				catch 
				{
					object c = Calendar.Gregorian.dwim_day(id->variables->createddate);
					createddate = c->format_ymd();
					t->add("showcreated", "");
  				    t->add("createchecked", "checked=\"1\"");
				};
			}
            t->add("preview", app->render(contents, obj_o, id));
				array bu = (replace(trackbacks, "\r", "")/"\n" - ({""}));
				if(id->misc->permalinks)
				{
					foreach(id->misc->permalinks, string url)
					{
						string l;
						l = FinScribe.Blog.detect_trackback_url(url);
						if(l && search(bu, l)==-1)
						  bu += ({l});
					}
				}
				trackbacks = Array.uniq(bu)*"\n";

            break;
         case "Save":
             Log.info("Saving entry.");
             just_saving = 1;
         case "Post":
               object c;
            // posting should always create a new entry; afterwards it's a standard object
            // that you can edit normally by editing its object content.
            {
               array dtos = find.datatypes((["mimetype": "text/wiki"]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", LOCALE(402,"Internal Database Error, unable to save."));
                  break;
               }

	       // let's get the next blog path name...              
               string path = "";
               array r = obj_o->get_blog_entries();
               int seq = 1;
               if(id->variables->createddate && sizeof(id->variables->createddate))
                 c = Calendar.Gregorian.dwim_day(id->variables->createddate)->second();
 			   else 
                 c = Calendar.ISO.Second();
               string date = sprintf("%04d-%02d-%02d", c->year_no(), c->month_no(),  c->month_day());
               if(sizeof(r))
               {
                 foreach(r;;object entry) 
                 {
//		   write("LOOKING AT " + entry["path"] + "; does it match " + obj + "/" + date + "/ ?\n");
                   // we assume that everything in here will be organized chronologically, and that no out of 
                   // date order pathnames will show up in the list.
                   if(has_prefix(entry["path"], obj + "/" + date + "/"))
                     seq++;
                   else break;
                 }
               }

               path = combine_path(obj, date + "/" +  seq);

               // this is the parent, to which the new entry is associated.
               object p = obj_o;

               object dto = dtos[0]; 
               obj_o = Fins.DataSource._default.new("object");
               obj_o["datatype"] = dto;
               obj_o["author"] = Fins.Model.find.users_by_id(id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o["parent"] = p;
               if(just_saving)
               {
                 array s_a = Fins.DataSource._default.find.acls("acl", (["name": "Work In Progress Object"]));
                 object s_acl;
                 if(sizeof(s_a))
                   s_acl = s_a[0];
                 else
                   s_acl = p["acl"];

                 obj_o["acl"] = s_acl;
               }
               else
                 obj_o["acl"] = p["acl"];
               obj_o["created"] = c;
               if(just_saving)
                 obj_o["is_attachment"] = 3;
               else
                 obj_o["is_attachment"] = 2;
               obj_o->save();
            }

            object obj_n = Fins.DataSource._default.new("object_version");
            obj_n["contents"] = contents;
            obj_n["subject"] = subject;
            obj_n["created"] = c;
            int v;
            object cv;

            obj_o->refresh();

            if(cv = obj_o["current_version"])
            { 
              v = cv["version"];
            }
            obj_n["version"] = (v+1);
            obj_n["object"] = obj_o;            
            if(id->variables->subject)
              obj_n["subject"] = id->variables->subject;            
            obj_n["author"] = Fins.Model.find.users_by_id(id->misc->session_variables->userid);
            obj_n->save();

            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));

            if(!just_saving)
            {	
              // we use this object for both trackback and pingback processing.
              object u = Standards.URI(app->get_sys_pref("site.url")->get_value());
  	      u->path = combine_path(u->path, "/space");

	      if(sizeof(trackbacks))
	      {
                Thread.Thread(do_trackback_ping, (trackbacks/"\n")-({""}), obj_o, u);
  	      }
            }
         cache->clear(app->get_renderer_for_type(obj_o["parent"]["datatype"]["mimetype"])->make_key(obj_o["parent"]->get_object_contents(), 
                                                     obj_o["parent"]["path"]));

         app->trigger_event("postSave", id, obj_o);


         if(id->variables->ajax)
         {
            response->set_data(LOCALE(367,"Succesfully Saved.") + "<div style=\"display:none;\" id=\"result\">" + LOCALE(412,"Success") + "</div>");
//            response->redirect("/space/" + obj);
            return;
         }
         else
         {
            response->flash("msg", LOCALE(367,"Succesfully Saved."));
            response->redirect("/space/" + obj);
            return;
         }
            break;

         default:
            response->set_data(LOCALE(413,"Unknown post action %[0]s"), id->variables->action);
            return;
            break;
      }
   }
   else
   {
      if(obj_o)
      {
        contents = "";
//         contents = obj_o->get_object_contents(id);
      }
      else
      {
         response->set_data(LOCALE(414,"You cannot post to a non-existent page."));
      }
   }

   t->add("contents", contents);
   t->add("createddate", createddate);
   t->add("trackbacks", trackbacks);
   t->add("subject", subject);
   t->add("obj", obj);
   
   response->set_view(t);
}

private void do_trackback_ping(array trackbacks, object obj_o, object u)
{
  foreach(trackbacks;; string url)
    Thread.Thread(FinScribe.Blog.trackback_ping, obj_o, u, url);

}

public void diff(Request id, Response response, mixed ... args)
{
   object obj_o;

   obj_o = model->get_fbobject(args, id);
   if(!obj_o)
   {
     response->set_data(LOCALE(415,"unable to find object %[0]s."), args*"/");
     return;
   } 

    object t = view->get_idview("exec/diff", id);
   
    app->set_default_data(id, t);

   int from, to;
   string cfrom, cto;
   array os;

   to = (int)id->variables->to;
   from = (int)id->variables->from;

   if(!to)
     cto = obj_o["current_version"]["contents"];
   else
   {
     os = Fins.Model.find.object_versions((["object": obj_o, "version": to]));
     if(!sizeof(os))
     {
       response->set_data(LOCALE(416,"version %[0]s does not exist.\n"), to);
       return;
     }
     cto = os[0]["contents"];
   }

   os = Fins.Model.find.object_versions((["object": obj_o, "version": from]));
   if(!sizeof(os))
   {
     response->set_data(LOCALE(417,"version %[0]s does not exist."), to);
     return;
   }
   cfrom = os[0]["contents"];

   cfrom = replace(cfrom, "\r", "");
   cto = replace(cto, "\r", "");
   array old, new;
   old = cfrom/"\n";
   new = cto/"\n";

   array diff = Array.diff(old, new);

   string resultStr = "";
   array newTokens, oldTokens;

   newTokens = diff[0];
   oldTokens = diff[1];

    int i, j, szo, szn;
    i = j = 0;
    szo = sizeof(oldTokens);
    szn = sizeof(newTokens);
    if ( szn > szo )
        oldTokens += allocate(szn-szo);
    else if ( szo > szn )
        newTokens += allocate(szo-szn);

    int line1, line2;
    line1 = line2 = 1;
resultStr = "<table>\n";
    while ( i < szn && j < szo )
    {
      resultStr +="<tr>\n";
        if ( newTokens[i] == oldTokens[j] ) {
resultStr +="<td>&nbsp;</td><td>";
            line1 += sizeof(newTokens[i]);
            line2 += sizeof(oldTokens[j]);
            if(arrayp(oldTokens[j]))
              resultStr += (oldTokens[j] * "<br/>\n") ;
            else
              resultStr += (oldTokens[j]+ "<br/>\n") ;
            i++;
            j++;
resultStr +="</td>";
        }
        else {
            if ( !arrayp(newTokens[i]) || sizeof(newTokens[i])  == 0 ) {
//                resultStr += "#" + line2 + ": <br />";
                resultStr += "<td>-</td><td bgcolor=\"pink\">" + (oldTokens[j]*"<br />") + "<br/></td>";
                line2 += sizeof(oldTokens[j]);
            }
            else if ( !arrayp(oldTokens[j]) || sizeof(oldTokens[j]) == 0 ) {
//                resultStr += "#" + line1 + ": <br />";
                resultStr += "<td><b>+</b></td><td bgcolor=\"lightgreen\">" + (newTokens[j]*"<br />") + "<br /></td>";
                line1 += sizeof(newTokens[i]);
            }
            else {
//                resultStr += "#" + line1 + ": <br />";
                resultStr += "<td><b>+</b></td><td bgcolor=\"lightgreen\">" + (newTokens[j]*"<br />") + "<br /></td></tr>\n<tr>";
                resultStr += "<td><b>-</b></td><td bgcolor=\"pink\">" + (oldTokens[j]*"<br />") + "<br /></td>";
                line1 += sizeof(newTokens[i]);
                line2 += sizeof(oldTokens[j]);
            }
            i++;
            j++;
        }
      resultStr +="</tr>\n";
    }

   resultStr += "</table>\n";
   t->add("object", obj_o);
   t->add("diff", resultStr);
   response->set_view(t);
}

public void versions(Request id, Response response, mixed ... args)
{
   object obj_o;

   obj_o = model->get_fbobject(args, id);
   if(!obj_o)
   {
     response->set_data(LOCALE(415,"unable to find object %[0]s."), args*"/");
     return;
   } 

   object t = view->get_idview("exec/versions", id);
   
   app->set_default_data(id, t);


   t->add("object", obj_o);
   array a = Fins.Model.find.object_versions((["object": obj_o]), 
                                      Fins.Model.Criteria("ORDER BY VERSION DESC"));
   t->add("versions", a);
   
   response->set_view(t);
}

public void display_trackbacks(Request id, Response response, mixed ... args)
{
    object obj_o = model->get_fbobject(args, id);
    if(!obj_o)
    {
      response->set_data(LOCALE(418,"Unable to find object %[0]s."), args*"/");
      return;
    } 

    object t = view->get_idview("exec/display_trackbacks", id);
   
    app->set_default_data(id, t);
	t->add("object", obj_o);
    t->add("trackbacks", obj_o["md"]["trackbacks"]);

    response->set_view(t);
}

public void display_pingbacks(Request id, Response response, mixed ... args)
{
    object obj_o = model->get_fbobject(args, id);
    if(!obj_o)
    {
      response->set_data(LOCALE(418,"Unable to find object %[0]s."),args*"/");
      return;
    } 

    object t = view->get_idview("exec/display_pingbacks", id);
   
    app->set_default_data(id, t);
    t->add("object", obj_o);
    t->add("pingbacks", (array)(obj_o["md"]["pingbacks"] || ({})));

    response->set_view(t);
}

public void pingback(Request id, Response response, mixed ... args)
{
        mapping m;
        int off = search(id->raw, "\r\n\r\n");

        if(off<=0) error("invalid request format.\n");

        object X;

        if(catch(X=Protocols.XMLRPC.decode_call(id->raw[(off+4) ..])))
        {
                error("Error decoding the XMLRPC Call. Are you not speaking XMLRPC?\n");
        }
        mixed resp;

        mixed err = catch {
          if(X->method_name != "pingback.ping")
            throw(Error.Generic("Invalid method request: not a valid method name.\n"));
          resp = register_pingback(id, response, @X->params);
        };

  if(err)
  {
    response->set_data(Protocols.XMLRPC.encode_response_fault(1, err[0]));
  }
  else
  {
    if(stringp(resp))
      response->set_data(Protocols.XMLRPC.encode_response(({resp})));
    else if(arrayp(resp))
      response->set_data(Protocols.XMLRPC.encode_response_fault(@resp));
  }
   response->set_type("text/xml");

   return;
}

private string|array register_pingback(object id, object response, string sourceurl, string targeturl)
{
  // are we pingback enabled?
  if(!app->get_sys_pref("blog.pingback_receive")->get_value())
  { 
    return ({0, "we are not pingback enabled. go away!"});
  }

  // first, is the target ours?
  object oururl = Standards.URI("/space/", app->get_sys_pref("site.url")->get_value());

  if(!has_prefix(targeturl, (string)oururl))
  {
    // it's not a valid url, so it can't possibly exist.
    return ({32, "specified target url doesn't exist, or isn't ours."});
  }

  string obj = targeturl[sizeof((string)oururl)..];

  object obj_o;
  array a = Fins.Model.find.objects( (["path": obj]));

  if(!sizeof(a)) return ({32, "specified target url doesn't exist."});

  obj_o = a[0];

  // second, is the source valid?

  string cnt = FinScribe.Blog.get_url_data(sourceurl);
  
  if(!cnt) return ({16, "source uri does not exist, or has no contents."});

  // third, does the source contain our target url?
  

  Log.info("PINGBACK: looking for %O\n in %O\n", targeturl, cnt);
  if(search(cnt, targeturl)==-1)
  {
    return ({17, "You didn't link to us, no PingBack for you!"});
  }  

  // do we already have a pingback for this?

  a = obj_o["md"]["pingbacks"];

  if(!a) obj_o["md"]["pingbacks"] = (< sourceurl >);
  else if(obj_o["md"]["pingbacks"][sourceurl])
  {
    return ({48, "the source url provided has already been registered for this target."});
  }
  else
    obj_o["md"]["pingbacks"][sourceurl] = 1;

    return "thanks!";
}

public void trackback(Request id, Response response, mixed ... args)
{
  response->set_type("text/xml");

  if(id->request_type != "POST")
  {
    response->set_data(trackback_error("TrackBacks must be submitted as a HTTP POST."));
    return;
  }

  else
  { 
    if(!id->variables->url)
    {
      response->set_data(trackback_error("TrackBacks must include a 'url' field."));
      return;
    }

    object obj_o = model->get_fbobject(args, id);
    if(!obj_o)
    {
      response->set_data(trackback_error("Unable to find object " + args*"/" + "."));
      return;
    } 

    object url;
    string contents;

    if(catch(url = Standards.URI(id->variables->url)) || ! url)
    {
      response->set_data(trackback_error("Invalid URL: " + id->variables->url + "."));
      return;
    }

    if(!(contents = Protocols.HTTP.get_url_data(url)))
    {
      response->set_data(trackback_error("Unable to fetch URL: " + id->variables->url + "."));
      return;
    }

    object md = obj_o["md"];

    if(!md->trackbacks || search(md->trackbacks, (string)id->variables->url) == -1)
    {
      // ok, we don't already have a trackback for this url, let's try to add one.

      // first, we see if they've been kind enough to link to us (should be a prerequisite, right?)
      object lookingfor = Standards.URI("/space/" + args*"/", app->get_sys_pref("site.url")->get_value());
      Log.info("TRACKBACK: looking for %O\n in %O\n", lookingfor, contents);
      if(search(contents, (string)lookingfor)==-1)
      {
        response->set_data(trackback_error("You didn't link to us, no TrackBack for you!"));
        return;
      }

      
		mapping tb = (["url": url]);
		if(id->variables->title)
			tb->title = FinScribe.Blog.make_excerpt(id->variables->title);
		if(id->variables->blog_name)
			tb->blog_name = FinScribe.Blog.make_excerpt(id->variables->blog_name);
		if(id->variables->excerpt)
			tb->excerpt = FinScribe.Blog.make_excerpt(id->variables->excerpt);


      if(!md->trackbacks) md->trackbacks = ({ tb });
      else md->trackbacks += ({ tb });
   }

    response->set_data("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<response>\n<error>0</error>\n</response>\n");
  }
}

private string trackback_error(string e)
{
  Log.warn("TRACKBACK ERROR: %O\n", e);
  return ("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<response>\n<error>1</error>\n<message>" + e + "</message>\n</response>\n");

}

public void json_userlist(Request id, Response response, mixed ... args)
{ 
  array userlist;
  if(id->variables->startswith)
    userlist = Fins.Model.find.users((["name" : Fins.Model.LikeCriteria(id->variables->startswith + "%")]));
  else
    userlist = Fins.Model.find.users_all();
   
  array list = allocate(sizeof(userlist));   
  foreach(userlist;int i;object u)
  {
    list[i] = (["name": u["name"], "username": u["username"]]);
  }

  string json = Tools.JSON.serialize((["users": list]));
   
  response->set_data(json);
}   

public void doctree(Request id, Response response, mixed ... args)
{
  object t = view->get_idview("exec/tree", id);

  app->set_default_data(id, t);
  response->set_view(t);
}

public void tree(Request id, Response response, mixed ... args)
{
  if(id->variables->action && id->variables->action == "getChildren")
  {
      array data = ({});
    mapping d = Tools.JSON.deserialize(id->variables->data);
    array prefixes = ({});
    array nodes = ({});   
    string props_url = action_url(object_properties_menu) + "/";

    if(d->node && d->node->widgetId && d->node->widgetId == "pageroot")
    {
     
      array x =  Fins.Model.find.objects((["path": NotCriteria(LikeCriteria("%/%"))]));
       foreach(x;;object p)   
       {
           data += ({ (["title":  "<img src='/static/images/attachment/" + p["icon"] + "'> " + p["title"], "object_title": p["title"], 
                        "props_url": props_url + p["path"], "data": p["link"], "widgetId": "tree_" + p["id"], "isFolder": sizeof(p["children"]) ]) });
       }
    }  
    else if(d->node && d->node->widgetId)
    {
      array x =  Fins.Model.find.objects((["parent": (int)d->node->widgetId[5..] ]));
//Fins.Model.AndCriteria(({Fins.Model.LikeCriteria(d->node->widgetId[5..] + 
//"/%"),  Fins.Model.NotCriteria(Fins.Model.LikeCriteria(d->node->widgetId[5..] + "/%/%"))}))

      int q = sizeof(d->node->widgetId[5..] / "/");
      foreach(x;;object p)
      {
	if(sizeof(p["children"]))
          prefixes += ({ p });
        else
          nodes += ({p});
      }
      prefixes = Array.uniq(prefixes);
      
      
      if(sizeof(prefixes))
        foreach(prefixes;; object p)
          data += ({ (["title":  "<img src='/static/images/attachment/" + p["icon"] + "'> " + p["title"] , "object_title": p["title"], 
"props_url": props_url + p["path"], "data": p["parent"]["link"], "widgetId": "tree_" + p["id"], "isFolder": 1 ]) });
      if(sizeof(nodes))foreach(nodes;; object p)
          data += ({ (["title": "<img src='/static/images/attachment/" + p["icon"] + "'> " + p["title"], "object_title": p["title"], 
"props_url": props_url + p["path"], "data": p["link"], "widgetId": "treepage_" + p["id"], "isFolder": 0 ]) });
          
}         
      response->set_data(Tools.JSON.serialize(data));
      response->set_type("text/json");
      
  }
}
