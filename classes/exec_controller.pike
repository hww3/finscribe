//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app()->config->app_name, id->get_lang(), X, Y)

import Fins;
import Fins.Model;   
inherit Fins.FinsController;

int i=0;

public void foo(Request id, Response response, mixed ... args)
{
  i++;
  sleep(3);
  response->set_data( "This is request " + i +".");
}

public void index(Request id, Response response, mixed ... args)
{
  response->set_data(LOCALE(2, "hello from exec, perhaps you'd like to choose a function?\n"));
}


public void notfound(Request id, Response response, mixed ... args)
{
     object t = view->get_view("exec/objectnotfound");

     app->set_default_data(id, t);

     t->add("obj", args*"/");
     response->set_view(t);
}

public void editcategory(Request id, Response response, mixed ... args)
{
   if(!args || !sizeof(args))
   {
     response->set_data(LOCALE(3, "You must provide an object to modify categories for.\n"));
   }
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", LOCALE(4, "You must login to edit a category."));
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

  if((!id->variables["existing-category"] || 
     !sizeof(id->variables["existing-category"])) && 
     (!id->variables["new-category"] ||
     !sizeof(id->variables["new-category"]))) 
  {
    response->flash("msg", "No category specified.\n");
    response->redirect(id->referrer || "/space/");
    return;
  }
  string category = id->variables["existing-category"];
  if(!category || !sizeof(category))
  { 
    category = id->variables["new-category"];
    object nc = FinScribe.Repo.new("category");
    nc["category"] = category;
    nc->save();
  }
  string path = args*"/";

  array o = model()->find("object", (["path": path]));
  array c = model()->find("category", (["category": category]));
  array x;
  if(sizeof(c))
    x = model()->find("object", (["path": path, "categories": c[0]]));

  if(!sizeof(o))
  {
    response->flash("msg", LOCALE(5, "Unknown object ") + path + ".");
  }
  else if(!sizeof(c))
  {
    response->flash("msg", LOCALE(6, "Unknown category ") + category + ".");
  }
  else if(sizeof(x))
  {
    response->flash("msg", LOCALE(7, "Category ") + category + LOCALE(8, " is already assigned to this item."));
  }
  else if(id->variables->action == LOCALE(9, "Include"))
  {
    o[0]["categories"]+=c[0];
    response->flash("msg", LOCALE(10, "Added to ") + category + ".");
  }

  else if(id->variables->action == LOCALE(11, "Remove"))
  {
    o[0]["categories"]-=c[0];
    response->flash("msg", LOCALE(12, "Removed from ") + category + ".");
  }
  response->redirect(id->referrer || "/space/");

}

public void category(Request id, Response response, mixed ... args)
{
   if(!args || !sizeof(args))
   {
     response->set_data(LOCALE(13, "You must provide a category to view.\n"));
   }

    object t = view->get_view("exec/category");

   app->set_default_data(id, t);

   array c = model()->find("category", (["category": args[0]]));
  
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
			array a = model()->find("user", (["UserName": id->variables->UserName]));

			if(!sizeof(a))
			{
				response->flash("msg", "Unable to find a user account with that username. Please try again.\n");
			}
			
			else
			{

                object tp = view->get_view("exec/sendpassword");

				
				tp->add("password", a[0]["Password"]);
				
				string mailmsg = tp->render();
				
				Protocols.SMTP.Client(config->get_value("mail", "host"))->simple_mail(a[0]["Email"], 
																											"Your FinScribe password", 
																											config->get_value("mail", "return_address"), 
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
               obj_o["author"] = model()->find_by_id("user", id->misc->session_variables->userid);
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
            obj_n["author"] = model()->find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));
            response->flash("msg", "Succesfully Saved.");

            }

            response->redirect("/space/" + obj);
}

public void login(Request id, Response response, mixed ... args)
{
     object t = view->get_view("exec/login");

     app->set_default_data(id, t);

   if(!id->variables->return_to)
   {
      t->add("return_to", (id->misc->flash && id->misc->flash->from) || 
                               id->referrer || "/space/");
      t->add("UserName", "");
   }

   if(config->get_value("administration", "autocreate") && 
         config->get_value("administration", "autocreate") == "1")
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
         t->add("return_to", id->variables->return_to);
         
      }
   }
   
   response->set_view(t);
}

public void comments(Request id, Response response, mixed ... args)
{
   string contents, title, obj;
   object obj_o;

   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to comment.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   obj_o = model->get_fbobject(args, id);
   title = obj_o["title"];
   obj = args*"/";
    
   object t = view->get_view("exec/comment");

   app->set_default_data(id, t);

   t->add("object", app->engine->render(obj_o["current_version"]["contents"], 
                                                          (["request": id, "obj": obj])));
   
   if(id->variables->action)
   {
      contents = id->variables->contents;
      switch(id->variables->action)
      {
         case "Preview":
            t->add("preview", app->engine->render(contents, (["request": id, "obj": obj])));
            break;
         case "Save":
            object obj_n = FinScribe.Repo.new("comment");
            obj_n["contents"] = contents;
            obj_n["object"] = obj_o;
            obj_n["author"] = model->find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
            response->flash("msg", "Succesfully Saved.");
            response->redirect("/space/" + obj);
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

   t->add("contents", contents);
   t->add("title", title);
   t->add("obj", obj);
   
   response->set_view(t);
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
     response->redirect("/exec/edit/" + id->variables->title);
     return;
   }   

      object t = view->get_view("exec/new");

     app->set_default_data(id, t);
     response->set_view(t);
}

public void edit(Request id, Response response, mixed ... args)
{
   string contents, title, obj, subject;
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

   if(id->variables->action)
   {
      object dto;
      contents = id->variables->contents;
      subject = id->variables->subject ||"";
      switch(id->variables->action)
      {
	 case "Cancel":
            response->flash("msg", "Blog Posting cancelled.");
	    response->redirect("/space/" + obj);
	    return;
            break;
         case "Preview":
            t->add("preview", app->engine->render(contents, (["request": id, "obj": obj])));
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
               view->flush_template(args[2..]*"/");
            }

            response->flash("msg", "Succesfully Saved.");
            response->redirect("/space/" + obj);
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

   t->add("contents", contents);
   t->add("subject", subject);
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
   string contents, subject, obj, trackbacks;
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

   object t = view->get_view("exec/post");
   
   app->set_default_data(id, t);

   if(id->variables->action)
   {
      contents = id->variables->contents;
      subject = id->variables->subject;
		trackbacks = id->variables->trackbacks;
      switch(id->variables->action)
      {
	 case "Cancel":
            response->flash("msg", "Blog Posting cancelled.");
	    response->redirect("/space/" + obj);
	    return;
            break;
         case "Preview":
            t->add("preview", app->engine->render(contents, (["request": id, "obj": obj])));
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
               object c = Calendar.now();
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
               obj_o["author"] = model()->find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o["parent"] = p;
               obj_o["is_attachment"] = 2;
               obj_o->save();
            }

            object obj_n = FinScribe.Repo.new("object_version");
            obj_n["contents"] = contents;
            obj_n["subject"] = subject;

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
            obj_n["author"] = model()->find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();

            cache->clear(sprintf("CACHEFIELD%s-%d", "current_version", obj_o->get_id()));

				if(sizeof(trackbacks))
				{
					object u = Standards.URI(app()->config->get_value("site", "url"));
					u->path = combine_path(u->path, "/space");

					foreach((trackbacks/"\n")-({""});; string url)
						FinScribe.Blog.trackback_ping(obj_o, u, url);
				}

				if((int)config->get_value("blog", "weblog_ping"))
				{
					FinScribe.Blog.weblogs_ping(obj_o["title"], 
							(string)Standards.URI("/space/" + obj_o["path"], config->get_value("site", "url")));
					
				}

            response->flash("msg", "Succesfully Saved.");
            response->redirect("/space/" + obj);
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
      object lookingfor = Standards.URI("/space/" + args*"/", config->get_value("site", "url"));
      werror("TRACKBACK: looking for %O\n in %O\n", lookingfor, contents);
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

    werror("ADDED TRACKBACK!\n");

    response->set_data("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<response>\n<error>0</error>\n</response>\n");
  }
}

private string trackback_error(string e)
{
werror("TRACKBACK ERROR: %O\n", e);
  return ("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<response>\n<error>1</error>\n<message>" + e + "</message>\n</response>\n");

}
