import Fins;
import Fins.Model;   
inherit Fins.FinsController;


public void index(Request id, Response response, mixed ... args)
{
  response->set_data("hello from exec, perhaps you'd like to choose a function?\n");
}


public void notfound(Request id, Response response, mixed ... args)
{
     Template.Template t = view()->get_template(view()->template, "objectnotfound.tpl");
     Template.TemplateData d = Template.TemplateData();

     d->add("obj", args*"/");
     response->set_template(t, d);

}

public void createaccount(Request id, Response response, mixed ... args)
{
  	Template.Template t = view()->get_template(view()->template, "createaccount.tpl");
  	Template.TemplateData d = Template.TemplateData();

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
			else if(sizeof(Model.find("user", (["UserName": UserName]))) != 0)
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
				object u = Model.new("user");
				u["UserName"] = UserName;
				u["Name"] = Name;
				u["Email"] = Email;
				u["Password"] = Password;
				u->save();
				response->flash("msg", "User created successfully.\n");
				response->redirect("/space/start");
			}
		}
		else
		{
			response->flash("msg", "Unknown action " + id->variables->action);
		}

	}

   d->add("Name", Name);
	d->add("UserName", UserName);
	d->add("Email", Email);
	d->add("Password", Password);

	response->set_template(t, d);
}

public void forgotpassword(Request id, Response response, mixed ... args)
{
     Template.Template t = view()->get_template(view()->template, "forgotpassword.tpl");
     Template.TemplateData d = Template.TemplateData();

	  d->add("username", "");

		if(id->variables->username)
		{
			d->add("username", id->variables->username);
			array a = Model.find("user", (["UserName": id->variables->username]));

			if(!sizeof(a))
			{
				response->flash("msg", "Unable to find a user account with that username. Please try again.\n");
			}
			
			else
			{
				Template.Template tp = view()->get_template(view()->template, "sendpassword.tpl");
				Template.TemplateData dp = Template.TemplateData();
				
				dp->add("password", a[0]["Password"]);
				
				string mailmsg = tp->render(dp);
				
				Protocols.SMTP.Client(app()->config->get_value("mail", "host"))->simple_mail(a[0]["Email"], 
																											"Your FinBlog password", 
																											app()->config->get_value("mail", "return_address"), 
																											mailmsg);
				
				response->flash("msg", "Your password has been located and will be sent to the email address on record for your account.\n");
				response->redirect("/exec/login");
			}
			
		}
     response->set_template(t, d);
}

public void logout(Request id, Response response, mixed ... args)
{
  if(id->misc->session_variables->userid)
  {
     m_delete(id->misc->session_variables, "userid");
  }

  response->redirect(id->request_headers["referer"]||"/space/");
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
  object obj_o;
               array dtos = Model.find("datatype", (["mimetype": id->variables["mime-type"]]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", "Mime type " + id->variables["mime-type"] + " not valid.");
               }
               else{              
               object dto = dtos[0];
               obj_o = Model.new("object");
               obj_o["datatype"] = dto;
               obj_o["is_attachment"] = 1;
               obj_o["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o->save();

            object obj_n = Model.new("object_version");
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
            obj_n["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
            response->flash("msg", "Succesfully Saved.");

            }

            response->redirect("/space/" + obj);


}

public void login(Request id, Response response, mixed ... args)
{
   Template.Template t = view()->get_template(view()->template, "login.tpl");
   Template.TemplateData d = Template.TemplateData();
   if(!id->variables->return_to)
   {
      d->add("return_to", (id->misc->flash && id->misc->flash->from) || 
                               id->request_headers["referer"] || "/space/");
      d->add("UserName", "");
   }

   if(app()->config->get_value("administration", "autocreate") && 
         app()->config->get_value("administration", "autocreate") == "1")
	{
		d->add("autocreate", 1);
	}
	else
	{
		d->add("autocreate", 0);
	}
	
   if(id->variables->action)
   {
      if(id->variables->action == "Cancel")
      {
         response->redirect(id->variables->return_to);
         return;
      }
      
      array r = Model.find("user", (["UserName": id->variables->UserName, "Password": id->variables->Password]));
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
         d->add("UserName", id->variables->UserName);
         d->add("return_to", id->variables->return_to);
         
      }
   }
   
   response->set_template(t, d);
}

public void comments(Request id, Response response, mixed ... args)
{
   string contents, title, obj;
   object obj_o;

   write("comments\n");

   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to comment.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }

   obj_o = predef::get_object(args, id);
   title = get_object_title(obj_o, id);
   obj = args*"/";
   
   Template.Template t = view()->get_template(view()->template, "comment.tpl");
   Template.TemplateData d = Template.TemplateData();

   d->add("object", app()->engine->render(obj_o["current_version"]["contents"], 
                                                          (["request": id, "obj": obj])));
   
   if(id->variables->action)
   {
      contents = id->variables->contents;
      switch(id->variables->action)
      {
         case "Preview":
            d->add("preview", app()->engine->render(contents, (["request": id, "obj": obj])));
            break;
         case "Save":
            object obj_n = Model.new("comment");
            obj_n["contents"] = contents;
            obj_n["object"] = obj_o;
            obj_n["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
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

   d->add("contents", contents);
   d->add("title", title);
   d->add("obj", obj);
   
   response->set_template(t, d);
   
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
   
   obj_o = predef::get_object(args, id);
   title = args[-1];
   obj = args*"/";
   
   Template.Template t = view()->get_template(view()->template, "edit.tpl");
   Template.TemplateData d = Template.TemplateData();
   
   if(id->variables->action)
   {
      object dto;
      contents = id->variables->contents;
      subject = id->variables->subject ||"";
      switch(id->variables->action)
      {
         case "Preview":
            d->add("preview", app()->engine->render(contents, (["request": id, "obj": obj])));
            break;
         case "Save":
            if(!obj_o)
            {
               array dtos = Model.find("datatype", (["mimetype": id->variables->mimetype || "text/wiki"]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", "Internal Database Error, unable to save.");
                  break;
               }
              
               dto = dtos[0];
               obj_o = Model.new("object");
               obj_o["is_attachment"] = 0;
               obj_o["datatype"] = dto;
               obj_o["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = obj;
               obj_o->save();
            }

            object obj_n = Model.new("object_version");
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
            obj_n["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
            string dtp = obj_o["datatype"]["mimetype"];
            if(dtp == "text/template")
            {
               view()->flush_template(args[2..]*"/");
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
         contents = get_object_contents(obj_o, id);
         subject = obj_o["current_version"]["subject"];
         if(!subject || subject == "0") subject = "";
      }
      else
      {
         contents = "";
	 subject = "";
      }
   }

   d->add("contents", contents);
   d->add("subject", subject);
   d->add("title", title);
   d->add("obj", obj);
   
   response->set_template(t, d);
}

//! we don't check to make sure that a page has a {weblog}
//! entry, so malicious people could theoretically create post 
//! objects to a non-existent weblog (though the page must exist
//! and the user must have post permission, so this limits the
//! danger of this shortcoming.
public void post(Request id, Response response, mixed ... args)
{
   string contents, title, obj;
   object obj_o;
   
   if(!id->misc->session_variables->userid)
   {
      response->flash("msg", "You must login to post.");
      response->flash("from", id->not_query);
      response->redirect("/exec/login");
      return;
   }
   
   obj_o = predef::get_object(args, id);
   title = args[-1];
   obj = args*"/";
   
   Template.Template t = view()->get_template(view()->template, "post.tpl");
   Template.TemplateData d = Template.TemplateData();
   
   if(id->variables->action)
   {
      contents = id->variables->contents;
      switch(id->variables->action)
      {
         case "Preview":
            d->add("preview", app()->engine->render(contents, (["request": id, "obj": obj])));
            break;
         case "Save":
            // posting should always create a new entry; afterwards it's a standard object
            // that you can edit normally by editing its object content.
            {
               array dtos = Model.find("datatype", (["mimetype": "text/wiki"]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", "Internal Database Error, unable to save.");
                  break;
               }

	       // let's get the next blog path name...              
               string path = "";
               array r = get_blog_entries(obj);
               int seq = 1;
               object c = Calendar.now();
               string date = sprintf("%04d-%02d-%02d", c->year_no(), c->month_no(),  c->month_day());
               if(sizeof(r))
               {
                 foreach(r;;object entry) 
                 {
write("LOOKING AT " + entry["path"]);
                   // we assume that everything in here will be organized chronologically, and that no out of 
                   // date order pathnames will show up in the list.
                   if(has_prefix(entry["path"], obj + "/" + date + "/"))
                     seq++;
                   else break;
                 }
               }

               path = combine_path(obj, date + "/" +  seq);

               object dto = dtos[0];
               obj_o = Model.new("object");
               obj_o["datatype"] = dto;
               obj_o["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o["is_attachment"] = 2;
               obj_o->save();
            }

            object obj_n = Model.new("object_version");
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
            if(id->variables->subject)
              obj_n["subject"] = id->variables->subject;            
            obj_n["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
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
//         contents = get_object_contents(obj_o, id);
      }
      else
      {
         response->set_data("You cannot post to a non-existent page.\n");
      }
   }

   d->add("contents", contents);
   d->add("title", title);
   d->add("obj", obj);
   
   response->set_template(t, d);
}

