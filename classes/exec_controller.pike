import Fins;
import Fins.Model;   
inherit Fins.Controller;


public void index(Request id, Response response, mixed ... args)
{
  response->set_data("hello from exec, perhaps you'd like to choose a function?\n");
}


public void notfound(Request id, Response response, mixed ... args)
{
     Template.Template t = Template.get_template(Template.Simple, "objectnotfound.tpl");
     Template.TemplateData d = Template.TemplateData();

     d->add("obj", args*"/");
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
               obj_o = DataObjectInstance(UNDEFINED, "object");
               obj_o["datatype"] = dto;
               obj_o["is_attachment"] = 1;
               obj_o["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o->save();

            object obj_n = DataObjectInstance(UNDEFINED, "object_version");
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
   Template.Template t = Template.get_template(Template.Simple, "login.tpl");
   Template.TemplateData d = Template.TemplateData();
   if(!id->variables->return_to)
   {
      d->add("return_to", (id->misc->flash && id->misc->flash->from) || 
                               id->request_headers["referer"] || "/space/");
      d->add("UserName", "");
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
   
   Template.Template t = Template.get_template(Template.Simple, "comment.tpl");
   Template.TemplateData d = Template.TemplateData();

   d->add("object", application->engine->render(obj_o["current_version"]["contents"], 
                                                          (["request": id, "obj": obj])));
   
   if(id->variables->action)
   {
      contents = id->variables->contents;
      switch(id->variables->action)
      {
         case "Preview":
            d->add("preview", application->engine->render(contents, (["request": id, "obj": obj])));
            break;
         case "Save":
            object obj_n = DataObjectInstance(UNDEFINED, "comment");
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
   string contents, title, obj;
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
   
   Template.Template t = Template.get_template(Template.Simple, "edit.tpl");
   Template.TemplateData d = Template.TemplateData();
   
   if(id->variables->action)
   {
      contents = id->variables->contents;
      switch(id->variables->action)
      {
         case "Preview":
            d->add("preview", application->engine->render(contents, (["request": id, "obj": obj])));
            break;
         case "Save":
            if(!obj_o)
            {
               array dtos = Model.find("datatype", (["mimetype": "text/wiki"]));
               if(!sizeof(dtos))
               {
                  response->flash("msg", "Internal Database Error, unable to save.");
                  break;
               }
              
               object dto = dtos[0];
               obj_o = DataObjectInstance(UNDEFINED, "object");
               obj_o["datatype"] = dto;
               obj_o["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = obj;
               obj_o->save();
            }

            object obj_n = DataObjectInstance(UNDEFINED, "object_version");
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
            obj_n["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
            obj_n->save();
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
      }
      else
      {
         contents = "";
      }
   }

   d->add("contents", contents);
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
   
   Template.Template t = Template.get_template(Template.Simple, "post.tpl");
   Template.TemplateData d = Template.TemplateData();
   
   if(id->variables->action)
   {
      contents = id->variables->contents;
      switch(id->variables->action)
      {
         case "Preview":
            d->add("preview", application->engine->render(contents, (["request": id, "obj": obj])));
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
               obj_o = DataObjectInstance(UNDEFINED, "object");
               obj_o["datatype"] = dto;
               obj_o["author"] = Model.find_by_id("user", id->misc->session_variables->userid);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
               obj_o["is_attachment"] = 2;
               obj_o->save();
            }

            object obj_n = DataObjectInstance(UNDEFINED, "object_version");
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

