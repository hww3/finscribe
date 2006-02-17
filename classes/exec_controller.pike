//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Tools.Logging;
import Fins;
import Fins.Model;   
inherit Fins.FinsController;

int i=0;

public void index(Request id, Response response, mixed ... args)
{
  response->set_data(LOCALE(2, "hello from exec, perhaps you'd like to choose a function?\n"));
}


public void notfound(Request id, Response response, mixed ... args)
{
     object t = view->get_view("exec/objectnotfound");

     app->set_default_data(id, t);

/*

     array f = FinScribe.model.find("object", (["path": Fins.Model.LikeCriteria((args*"/")+ "/%")]) );

     if(f & sizeof(f))
       t->add("dir", f);
*/
     t->add("obj", args*"/");
     response->set_view(t);
}

public void actions(Request id, Response response, mixed ... args)
{

  object obj = model->get_fbobject(args, id);
  object t = view->get_view("exec/actions");

  app->set_default_data(id, t);

  t->add("object", obj);
  t->add("islocked", obj["md"]["locked"]);
  t->add("iseditable", obj->is_editable(t->get_data()["user_object"]));
  t->add("isdeleteable", obj->is_deleteable(t->get_data()["user_object"]));
  t->add("islockable", obj->is_lockable(t->get_data()["user_object"]));
  t->add("comments_closed", obj["md"]["comments_closed"]);

  response->set_view(t);

}

public void getcomments(Request id, Response response, mixed ... args)
{

  object obj = model->get_fbobject(args, id);

  mapping data = ([]);

  data->obj = obj["path"];

  app->set_default_data(id, data);

Log.debug("INFO: %O", data);
  string r = view->render_partial("exec/_comments", data, "comment", obj["comments"]);
     
  response->set_data(r);

}

public void editcategory(Request id, Response response, mixed ... args)
{
   if(!args || !sizeof(args))
   {
     response->set_data("You must provide an object to modify categories for.\n");
     return;
   }
   if(!id->misc->session_variables->userid)
   {
     response->set_data("You must login to edit a category.");
     return;
   }

  string path = args*"/";
  array o = model->find("object", (["path": path]));
  mapping dta = (["flash":""]);


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
      object nc = FinScribe.Repo.new("category");
      nc["category"] = category;
      nc->save();
      c=({nc});
    }
    else
    {
       c = model->find("category", (["category": category]));
    }

  array x;
  if(sizeof(c))
    x = model->find("object", (["path": path, "categories": c[0]]));

  if(!sizeof(o))
  {
    dta->flash = LOCALE(5, "Unknown object ") + path + ".";
  }
  else if(!sizeof(c))
  {
    dta->flash = LOCALE(6, "Unknown category ") + category + ".";
  }
  else if(sizeof(x) && id->variables->action == LOCALE(9, "Include"))
  {
    dta->flash = LOCALE(7, "Category ") + category + LOCALE(8, " is already assigned to this item.");
  }
  else if(id->variables->action == LOCALE(9, "Include"))
  {
    o[0]["categories"]+=c[0];
    model->clear_categories();
    dta->flash = LOCALE(10, "Added to ") + category + ".";
  }

  else if(id->variables->action == LOCALE(11, "Remove"))
  {
    o[0]["categories"]-=c[0];
    model->clear_categories();
    dta->flash = LOCALE(12, "Removed from ") + category + ".";
  }

  }

  app->set_default_data(id, dta);
  dta->obj = o[0]["path"];
  dta->object = o[0];
  dta["existing-categories"] = model->get_categories();

  response->set_data(view->render_partial("space/_categoryform", dta));


}

public void category(Request id, Response response, mixed ... args)
{
   if(!args || !sizeof(args))
   {
     response->set_data(LOCALE(13, "You must provide a category to view.\n"));
   }

    object t = view->get_view("exec/category");

   app->set_default_data(id, t);

   array c = model->find("category", (["category": args[0]]));
  
   if(!c || !sizeof(c))
   {
     response->set_data(LOCALE(7, "Category ") + args[0] + LOCALE(14, " does not exist.\n"));
     return;
   }

   t->add("category", c[0]);
   t->add("objects", c[0]["objects"]);

   response->set_view(t);
}

public void deletecomment(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(15, "You must login to delete comments."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
  
   if(!id->variables->id)
   {
      response->flash("msg", "You provide a comment id to delete.");
      response->redirect(id->referrer || "/space/");
      return;
   }

   object c = model->find_by_id("comment", (int)id->variables->id);

   if(!c)
   {
      response->flash("msg", "Comment #" + id->variables->id + " does not exist.");
      response->redirect(id->referrer || "/space/");
      return;
   }

   // we need to add a check for admin privs here.
   // user["is_admin"]
   object us = model->find_by_id("user", (int)id->misc->session_variables->userid);
   if(us["is_admin"] || (us["id"] == c["object"]["author"]["id"]))
   {
     // we can delete!
      c->delete();
      response->flash("msg", "Comment deleted successfully.");
      response->redirect(id->referrer || "/space/");
      return;

   }
   else
   {
      response->flash("msg", "Only administrators and page owners can delete comments.");
      response->redirect(id->referrer || "/space/");
      return;
   }

     response->flash("msg", "How'd we get here?.");
}

public void createaccount(Request id, Response response, mixed ... args)
{
   object t = view->get_view("exec/createaccount");

   app->set_default_data(id, t);

   string Name, UserName, Email, Password, Password2, return_to;

	Name = "";
	UserName = "";
	Email = "";
	Password = "";
   return_to = "/space/start";
	
	if(id->variables->action)
	{
		Name = id->variables->Name;
		UserName = id->variables->UserName;
		Email = id->variables->Email;
		Password = id->variables->Password;
		Password2 = id->variables->Password2;
		return_to = id->variables->return_to;

		if(id->variables->action == "Create")
		{
			// check the username
			if(sizeof(Name)< 2)
			{
				response->flash("msg", "You must provide a username with at least 2 characters.\n");
			}
			else if(sizeof(model->find("user", (["UserName": UserName]))) != 0)
			{
				response->flash("msg", "The username you have chosen is already in use by another user.\n");
			}
			else if(!sizeof(Name) || !sizeof(Email))
			{
				response->flash("msg", "You must provide a Real name and e-mail address.\n");
			}
			else if(sizeof(Password)<4 || (Password != Password2))
			{
				response->flash("msg", "Your password must be typed identically in both fields, and must be at least 4 characters long.\n");
			}
			else
			{
				// if we got here, everything should be good to go.
				object u = FinScribe.Repo.new("user");
				u["UserName"] = UserName;
				u["Name"] = Name;
				u["Email"] = Email;
				u["Password"] = Password;
            u["is_active"] = 1;
				u->save();
				response->flash("msg", "User created successfully.\n");
				response->redirect("/space/start");
				
				object p = FinScribe.Repo.find("object", (["path": "themes/default/newuser"]))[0];
				
				object up = FinScribe.Repo.new("object");
				up["path"] = u["UserName"];
				up["author"] = u;
				up["datatype"] = p["datatype"];
				up["is_attachment"] = 0;
				
				up->save();
				up["md"]["locked"] = 1;
				
				object uv = FinScribe.Repo.new("object_version");
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
			response->flash("msg", "Unknown action " + id->variables->action);
		}
	}

   t->add("Name", Name);
   t->add("UserName", UserName);
   t->add("Email", Email); 
   t->add("Password", Password);

   response->set_view(t);
}

public void forgotpassword(Request id, Response response, mixed ... args)
{
    object t = view->get_view("exec/forgotpassword");

     app->set_default_data(id, t);

	 t->add("UserName", "");

		if(id->variables->UserName)
		{
			t->add("UserName", id->variables->UserName);
			array a = model->find("user", (["UserName": id->variables->UserName]));

			if(!sizeof(a))
			{
				response->flash("msg", "Unable to find a user account with that username. Please try again.\n");
			}
			
			else
			{

                object tp = view->get_view("exec/sendpassword");

				
				tp->add("password", a[0]["Password"]);
				
				string mailmsg = tp->render();
				
				Protocols.SMTP.Client(app->get_sys_pref("mail.host"))->simple_mail(a[0]["Email"], 
																											"Your FinScribe password", 
										app->get_sys_pref("mail.return_address"), 
																											mailmsg);
				
				response->flash("msg", "Your password has been located and will be sent to the email address on record for your account.\n");
				response->redirect("/exec/login");
			}
			
		}
     response->set_view(t);
}

public void logout(Request id, Response response, mixed ... args)
{
  if(id->misc->session_variables->userid)
  {
     m_delete(id->misc->session_variables, "userid");
  }

  response->redirect(id->referrer||"/space/");
}

public void upload(Request id, Response response, mixed ... args)
{
  if(!id->variables->root || !strlen(id->variables->root)) 
  {
    response->set_data("No attachment location specified.\n");
    return;
  }
  
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to upload.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   } 

  string path = Stdio.append_path(id->variables->root, id->variables["save-as-filename"]);
  string obj=id->variables->root;
  array a = model->find("object", (["path": obj ]));
  object obj_o;
  object p;
  if(sizeof(a)) p = a[0];
  else 
  {
    throw(Error.Generic("Unable to find root object to attach this document to.\n"));
  }
  
               array dtos = model->find("datatype", (["mimetype": id->variables["mime-type"]]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", "Mime type " + id->variables["mime-type"] + " not valid.");
               }
               else{              
               object dto = dtos[0];
               obj_o = FinScribe.Repo.new("object");
               obj_o["datatype"] = dto;
               obj_o["is_attachment"] = 1;
               obj_o["parent"] = p;
               obj_o["author"] = model->find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o->save();

            object obj_n = FinScribe.Repo.new("object_version");
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
            obj_n["author"] = model->find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));
            response->flash("msg", "Succesfully Saved.");

            }

            response->redirect("/space/" + obj);
}

public void editattachments(Request id, Response response, mixed ... args)
{

  int viaframe = 0;

  if(!args || !sizeof(args)) 
  {
    response->set_data("No attachment location specified.\n");
    return;
  }
  
   if(!id->misc->session_variables->userid)
   {
      response->set_data("You must login to upload.");
      return;
   } 


  object t = view->get_view("exec/_editattachments");
  t->add("flash", "");

    string obj=args*"/";
    array a = model->find("object", (["path": obj ]));
    object p;
    if(sizeof(a)) p = a[0];
    else 
    {
      response->set_data("Unable to find root object to attach this document to.\n");
      return;
    }

  if(id->variables->action == "Delete") 
  {
    viaframe = 1;
    if(!id->variables["save-as-filename"])
    {
      t->add("flash", "No filename specified to delete.");
    }
    else
    {
      array o = model->find("object", (["path": id->variables["save-as-filename"]]));
      if(!sizeof(o))
      {
        t->add("flash", "Cannot find file " + id->variables["save-as-filename"]);
      }
      else
      {
        o[0]->delete(1);
        t->add("flash", "Sucessfully deleted " + id->variables["save-as-filename"]);
      }
    }
  }
  if(id->variables->action == "Add") 
  {
    viaframe = 1;
    string path = Stdio.append_path(obj, id->variables["save-as-filename"]);
    object obj_o;
  
    array dtos = model->find("datatype", (["mimetype": id->variables["mime-type"]]));
    if(!sizeof(dtos))
    {
       t->add("flash", "Mime type " + id->variables["mime-type"] + " not valid.");
    }
    else
    {       
      object dto = dtos[0];
      obj_o = FinScribe.Repo.new("object");
      obj_o["datatype"] = dto;
      obj_o["is_attachment"] = 1;
      obj_o["parent"] = p;
      obj_o["author"] = model->find_by_id("user", id->misc->session_variables->userid);
      obj_o["datatype"] = dto;
      obj_o["path"] = path;
      obj_o->save();

      object obj_n = FinScribe.Repo.new("object_version");
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
      obj_n["author"] = model->find_by_id("user", id->misc->session_variables->userid);
      obj_n->save();
      cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));

      t->add("flash", "Attachment added.");
    }

  }

  array o = model->find("object", ([ "is_attachment": 1, "parent": p ]));
  array datatypes = model->get_datatypes();  
  t->add("object", p);
  t->add("numattachments", sizeof(o));
  t->add("attachments", o);
  t->add("datatypes", datatypes);

   if(viaframe)
   {
     string s = "<html><head></head><body><textarea>" + t->render() + "</textarea></body></html>";
     response->set_data(s);
     response->set_type("text/html");
   }
   else
     response->set_view(t);

}

public void login(Request id, Response response, mixed ... args)
{
     object t;

   if(id->variables->ajax)
   {
     t = view->get_view("exec/_login");
     t->add("ajax", 1);
   }
   else t = view->get_view("exec/login");


   app->set_default_data(id, t);

   if(!id->variables->return_to)
   {
      id->variables->return_to = ((id->misc->flash && id->misc->flash->from) || 
                               id->variables->referrer || id->referrer || 
	                               "/space/");
   }

   if(!id->variables->UserName)
      t->add("UserName", "");


   if(app->get_sys_pref("admin.autocreate") && 
         app->get_sys_pref("admin.autocreate")->get_value())
	{

werror("AUTOCREATE");
		t->add("autocreate", 1);
	}
	else
	{
werror("NO AUTOCREATE");
		t->add("autocreate", 0);
	}
	
   if(id->variables->action)
   {
      if(id->variables->action == "Cancel")
      {
         response->redirect(id->variables->return_to);
         return;
      }
      
      array r = model->find("user", (["UserName": id->variables->UserName, 
                                        "Password": id->variables->Password, 
                                        "is_active": 1]));
      if(r && sizeof(r))
      {
         // success!
         id->misc->session_variables["userid"] = r[0]["id"];
         response->redirect(id->variables->return_to);
         return;
      }
      else
      {
         response->flash("msg", "Login Incorrect.");
         t->add("UserName", id->variables->UserName);
         
      }
   }
   
         t->add("return_to", id->variables->return_to);
   response->set_view(t);
}

public void comments(Request id, Response response, mixed ... args)
{
   string contents, title, obj;
   object obj_o;

   int anonymous = app->get_sys_pref("comments.anonymous")->get_value();
 
   if(!id->misc->session_variables->userid && 
             !anonymous)
   {
     if(id->variables->ajax)
     {
       response->set_data("You must login to comment.");
       return;
     }
      response->flash("msg", "You must login to comment.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
   else if(!id->misc->session_variables->userid && anonymous)
   {
     anonymous = 1;
   }
   else anonymous = 0;

   obj_o = model->get_fbobject(args, id);

   if(obj_o["md"]["comments_closed"] == 1)
   {
     if(id->variables->ajax)
     {
       response->set_data("Comments for this article have been closed.");
       return;
     }
     response->flash("msg", "Comments for this article have been closed.");
     response->redirect("/comments/" + obj_o["path"]);
     return;
   }
 
  title = obj_o["title"];
   obj = args*"/";
  
  object t;

   if(id->variables->ajax)
   {
     t = view->get_view("exec/_comment");
     t->add("ajax", 1);
   }
   else t = view->get_view("exec/comment");

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
          if(anonymous && id->variables->check_value != 
                     id->misc->session_variables[id->variables->check])
          {
             response->flash("msg", "Incorrect check image value.");
             break;
          }
          else
          {
              m_delete(id->misc->session_variables, id->variables->check);
          }
          if(anonymous && ! (id->variables->email && id->variables->name))
          {
             response->flash("msg", "Name and Email are required for posting without logging in.");
             break;
          }

          if(anonymous && (!sizeof(id->variables->email) || !sizeof(id->variables->name)))
          {
             response->flash("msg", "Name and Email are required for posting without logging in.");
             break;
          }
          object obj_n = FinScribe.Repo.new("comment");
            obj_n["contents"] = contents;
            obj_n["object"] = obj_o;
            if(anonymous)
            {
              obj_n["author"] = model->find("user", (["UserName": "anonymous"]))[0];
            }
            else
              obj_n["author"] = model->find_by_id("user", id->misc->session_variables->userid);

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
	      	  response->flash("msg", "Succesfully Saved.");
              response->redirect("/space/" + obj);
			}
			else
			{
				response->set_data("OK");
				return;
			}
          break;
       default:
          response->set_data("Unknown comment action %s", id->variables->action);
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

  if(!id->misc->session_variables[args[0]])
    v = "INVALID REQUEST";

  else 
    v = id->misc->session_variables[args[0]];

  object img = Image.Fonts.open_font("goo", 48,0, 1)
                    ->write(v);

  string i = Image.GIF.encode(img->phaseh());

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
      response->flash("msg", "You must login to lock objects.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

  object obj_o = model->get_fbobject(args, id);

	if(!obj_o)
	{
		response->flash("msg", "Object " + args*"/" + " does not exist.");
      response->redirect(id->referrer);		
 		return;
	}

   if((obj_o["author"]["id"] != id->misc->session_variables->userid) && !model->find_by_id("user", id->misc->session_variables->userid)["is_admin"])
	{
		response->flash("msg", "A locked object can only be toggled by its owner or an administrator.");
      response->redirect(id->referrer);		
		return;
	}
	
	obj_o["md"]["locked"] = !obj_o["md"]["locked"];

   response->flash("msg", "Object successfully " + (obj_o["md"]["locked"]?"":"un") + "locked.");
   response->redirect(id->referrer);
}

public void toggle_comments(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to toggle comments.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

  object obj_o = model->get_fbobject(args, id);

	if(!obj_o)
	{
		response->flash("msg", "Object " + args*"/" + " does not exist.");
      response->redirect(id->referrer);		
		return;
	}

   if((obj_o["author"]["id"] != id->misc->session_variables->userid) && !model->find_by_id("user", id->misc->session_variables->userid)["is_admin"])
	{
		response->flash("msg", "Comments on an object can only be toggled by its owner or an administrator.");
      response->redirect(id->referrer);		
		return;
	}
	
	obj_o["md"]["comments_closed"] = !obj_o["md"]["comments_closed"];

   response->flash("msg", "Comments successfully " + (obj_o["md"]["comments_closed"]?"dis":"en") + "abled.");
   response->redirect(id->referrer);
}

public void new(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to edit content.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   if(id->variables->title)
   {
     response->redirect("/exec/edit/" + id->variables->title + "?datatype=" + id->variables->datatype);
     return;
   }   

      object t = view->get_view("exec/new");

     app->set_default_data(id, t);

     mixed p = app->new_string_pref(t->get_data()["UserName"] + ".new.default_mimetype", "text/wiki");

     array mimetypes = ({});

     foreach(app->engines; string ty; mixed e)
     { 
       mapping t = ([]);
       t->mimetype = ty;
       if(e->typename) t->name = e->typename;

       mimetypes+= ({t});
     }

     t->add("datatypes", mimetypes);
     t->add("datatype", p->get_value());
     response->set_view(t);
}

public void move(Request id, Response response, mixed ... args)
{
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to move content.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   object obj_o; 
   object t;
   string newpath;
   string movesub;

   t = view->get_view("exec/move");
   obj_o = model->get_fbobject(args, id);

   app->set_default_data(id, t);

   if(!obj_o)
   {
      response->flash("msg", "This is a non-existent object: " + args*"/");
      response->redirect(id->referrer);		
      return;
   }

   if(obj_o && !obj_o->is_deleteable(t->get_data()["user_object"]))
   {
      response->flash("msg", "You do not have permission to move this object");
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
     response->flash("msg", "Move operation cancelled.");
     response->redirect("/space/" + (args*"/"));
     return;
   }

   if(id->variables->action == "Move")
   {
     if(newpath == obj_o["path"])
     {
       response->flash("msg", "You must specify a location to move to.");
     }
     else
     {
       string oldpath = obj_o["path"];

       if(id->variables->movesub)
         a = FinScribe.Repo.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += FinScribe.Repo.find("object", ([ "path": oldpath, 
                 "type": Fins.Model.Criteria("is_attachment = 2") ]));

       a += FinScribe.Repo.find("object", ([ "path": oldpath ]));

       array overlaps = ({});

       foreach(a;;mixed p)
       {
         // is it really as simple as just renaming the path?
         string pth = p["path"];
         pth = newpath + ((sizeof(pth) > sizeof(newpath))?(pth[sizeof(newpath)-1..]):"");
Log.debug("Checking to see if %s has an overlap at %s...", p["path"], pth);
         if(!p->is_deleteable(t->get_data()["user_object"]) || 
                   sizeof(FinScribe.Repo.find("object", ([ "path": pth]))))
         {
           overlaps += ({pth});
         }
       }

       if(sizeof(overlaps))
       {
         response->flash("msg", "One or more objects already exist in the location you're moving to or cannot be moved because of permissions: <p/>" + (overlaps*"<br>") );
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
         a = FinScribe.Repo.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += FinScribe.Repo.find("object", ([ "path": oldpath, 
                 "type": Fins.Model.Criteria("is_attachment = 2") ]));

     a += FinScribe.Repo.find("object", ([ "path": oldpath ]));

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

     t->add("msg", n + " objects moved.");
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
      response->flash("msg", "You must login to delete content.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   object obj_o; 
   object t;
   string newpath;
   string movesub;

   t = view->get_view("exec/delete");
   obj_o = model->get_fbobject(args, id);

   app->set_default_data(id, t);

   if(!obj_o)
   {
      response->flash("msg", "This is a non-existent object: " + args*"/");
      response->redirect(id->referrer);	
      return;
   }

   if(obj_o && !obj_o->is_deleteable(t->get_data()["user_object"]))
   {
      response->flash("msg", "You do not have permission to delete this object");
      response->redirect(id->referrer);		
      return;
   }

   array a = ({});

   if(id->variables->action == "Delete")
   {
       string oldpath = obj_o["path"];

     if(id->variables->movesub)
         a = FinScribe.Repo.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += FinScribe.Repo.find("object", ([ "path": oldpath + "/%", 
                 "type": Fins.Model.Criteria("is_attachment = 2") ])) || ({});

       a += FinScribe.Repo.find("object", ([ "path": oldpath ])) || ({});

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
         response->flash("msg", "You do not have permission to delete one or more objects: <p/>" + (overlaps*"<br>") );
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
         a = FinScribe.Repo.find("object",
             ([ "path": Fins.Model.LikeCriteria(oldpath + "/%"), 
                "type": Fins.Model.Criteria("is_attachment != 2")])) 
           || ({});     

       a += FinScribe.Repo.find("object", ([ "path": oldpath + "/%", 
                 "type": Fins.Model.Criteria("is_attachment = 2") ])) || ({});

     a += FinScribe.Repo.find("object", ([ "path": oldpath ])) || ({});

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

     t->add("msg", n + " objects deleted.");
     response->redirect("/space/" + newpath);
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
      response->flash("msg", "You must login to edit content.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
   
   obj_o = model->get_fbobject(args, id);
   title = args[-1];
   obj = args*"/";

   object t = view->get_view("exec/edit");

   app->set_default_data(id, t);


   if(obj_o && !obj_o->is_editable(t->get_data()["user_object"]))
   {
	response->flash("msg", "You do not have permission to edit this object");
      response->redirect(id->referrer);		
		return;
   }

  
   datatype = id->variables->datatype;
   if(!datatype && obj_o)  datatype = obj_o["datatype"]["mimetype"];
   else if(!datatype)
     datatype = "text/wiki";

   if(id->variables->action)
   {
      object dto;
      contents = id->variables->contents;
      subject = id->variables->subject ||"";
      switch(id->variables->action)
      {
	 case "Cancel":
            response->flash("msg", "Edit cancelled.");
	    response->redirect("/space/" + obj);
	    return;
	            break;
         case "Preview":
            t->add("preview", app->render(contents, obj_o, id));
            break;
         case "Save":
            if(!obj_o)
            {
               array dtos = model->find("datatype", (["mimetype": id->variables->mimetype || "text/wiki"]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", "Internal Database Error, unable to save.");
                  break;
               }
              
               dto = dtos[0];
               obj_o = FinScribe.Repo.new("object");
               obj_o["is_attachment"] = 0;
               obj_o["datatype"] = dto;
               obj_o["author"] = model->find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = obj;
               obj_o->save();
            }

            object obj_n = FinScribe.Repo.new("object_version");
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
            obj_n["author"] = model->find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));
            string dtp = obj_o["datatype"]["mimetype"];
            if(dtp == "text/template")
            {
               view->flush_template(args[2..]*"/");            }

            response->flash("msg", "Succesfully Saved.");
            response->redirect("/space/" + obj);
            app->trigger_event("postSave", id, obj_o);
            break;

         default:
            response->set_data("Unknown edit action %s", id->variables->action);
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

   t->add("contentswidget", app->get_widget_for_type(datatype, contents));
   t->add("subject", subject);
   t->add("datatype", datatype);
   t->add("title", title);
   t->add("obj", obj);
   
   response->set_view(t);
}

//! we don't check to make sure that a page has a {weblog}
//! entry, so malicious people could theoretically create post 
//! objects to a non-existent weblog (though the page must exist
//! and the user must have post permission, so this limits the
//! danger of this shortcoming.
public void post(Request id, Response response, mixed ... args)
{
   string contents, subject, obj, trackbacks, createddate;
   object obj_o;

   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to post.");
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
     t = view->get_view("exec/_post");
     t->add("ajax", 1);
   }
   else t = view->get_view("exec/post");

   t->add("object", obj_o);
   t->add("showcreated", "disabled=\"1\"");
   t->add("createchecked", "selected=\0\"");
   
   app->set_default_data(id, t);

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
              response->set_data("Blog posting cancelled.");
            }
            else
            {
              response->flash("msg", "Blog Posting cancelled.");
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
               object c;
            // posting should always create a new entry; afterwards it's a standard object
            // that you can edit normally by editing its object content.
            {
               array dtos = model->find("datatype", (["mimetype": "text/wiki"]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", "Internal Database Error, unable to save.");
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
//		   write("LOOKING AT " + entry["path"]);
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
               obj_o = FinScribe.Repo.new("object");
               obj_o["datatype"] = dto;
               obj_o["author"] = model->find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o["parent"] = p;
               obj_o["created"] = c;
               obj_o["is_attachment"] = 2;
               obj_o->save();
            }

            object obj_n = FinScribe.Repo.new("object_version");
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
            obj_n["author"] = model->find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();

            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));

	    if(sizeof(trackbacks))
	    {
		object u = Standards.URI(app->get_sys_pref("site.url"));
		u->path = combine_path(u->path, "/space");

		foreach((trackbacks/"\n")-({""});; string url)
			FinScribe.Blog.trackback_ping(obj_o, u, url);
	   }

	   if(app->get_sys_pref("blog.weblog_ping"))
	   {
		FinScribe.Blog.weblogs_ping(obj_o["title"], 
			(string)Standards.URI("/space/" + obj_o["path"], app->get_sys_pref("site.url")));
					
	   }

           cache->clear(app->get_renderer_for_type(obj_o["parent"]["datatype"]["mimetype"])->make_key(obj_o["parent"]->get_object_contents(), 
                                                     obj_o["parent"]["path"]));

         if(id->variables->ajax)
         {
            response->set_data("Succesfully Saved.");
//            response->redirect("/space/" + obj);
            return;
         }
         else
         {
            response->flash("msg", "Succesfully Saved.");
            response->redirect("/space/" + obj);
            return;
         }
            break;

         default:
            response->set_data("Unknown post action %s", id->variables->action);
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
         response->set_data("You cannot post to a non-existent page.\n");
      }
   }

   t->add("contents", contents);
   t->add("createddate", createddate);
   t->add("trackbacks", trackbacks);
   t->add("subject", subject);
   t->add("obj", obj);
   
   response->set_view(t);
}

public void diff(Request id, Response response, mixed ... args)
{
   object obj_o;

   obj_o = model->get_fbobject(args, id);
   if(!obj_o)
   {
     response->set_data("unable to find object " + args*"/");
     return;
   } 

    object t = view->get_view("exec/diff");
   
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
     os = model->find("object_version", (["object": obj_o, "version": to]));
     if(!sizeof(os))
     {
       response->set_data("version " + to + " does not exist.\n");
       return;
     }
     cto = os[0]["contents"];
   }

   os = model->find("object_version", (["object": obj_o, "version": from]));
   if(!sizeof(os))
   {
     response->set_data("version " + to + " does not exist.\n");
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
     response->set_data("unable to find object " + args*"/");
     return;
   } 

   object t = view->get_view("exec/versions");
   
   app->set_default_data(id, t);


   t->add("object", obj_o);
   array a = model->find("object_version", (["object": obj_o]), 
                                      Fins.Model.Criteria("ORDER BY VERSION DESC"));
   t->add("versions", a);
   
   response->set_view(t);
}

public void display_trackbacks(Request id, Response response, mixed ... args)
{
    object obj_o = model->get_fbobject(args, id);
    if(!obj_o)
    {
      response->set_data(trackback_error("Unable to find object " + args*"/" + "."));
      return;
    } 

    object t = view->get_view("exec/display_trackbacks");
   
    app->set_default_data(id, t);
	t->add("object", obj_o);
    t->add("trackbacks", obj_o["md"]["trackbacks"]);

    response->set_view(t);
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
      object lookingfor = Standards.URI("/space/" + args*"/", app->get_sys_pref("site.url"));
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
    userlist = model->find("user", (["Name" : Fins.Model.LikeCriteria(id->variables->startswith + "%")]));
  else
    userlist = model->find("user", ([]));
   
  array list = allocate(sizeof(userlist));   
  foreach(userlist;int i;object u)
  {
    list[i] = (["name": u["Name"], "username": u["UserName"]]);
  }

  string json = Tools.JSON.serialize((["users": list]));
   
  response->set_data(json);
}   
