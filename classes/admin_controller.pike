import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
	if(!app()->is_admin_user(id, response))
          return;

	Template.Template t;
        Template.TemplateData d;
        [t, d] = view()->prep_template("admin/adminindex.phtml");

        app()->set_default_data(id, d);

	response->set_template(t, d);
}

public void shutdown(Request id, Response response, mixed ... args)
{
	if(!app()->is_admin_user(id, response))
          return;
	
		Template.Template t;
	        Template.TemplateData d;
	
		if(!id->variables->really_shutdown)
	        [t, d] = view()->prep_template("admin/confirmshutdown.phtml");
		else
		{
		    [t, d] = view()->prep_template("admin/shutdown.phtml");
			// this is bad, we should have a better way of doing this...
			call_out(exit, 5, 0);
		}
	        app()->set_default_data(id, d);
	
		response->set_template(t,d);
	
}

public void listusers(Request id, Response response, mixed ... args)
{
	if(!app()->is_admin_user(id, response))
          return;

	Template.Template t;
        Template.TemplateData d;
        [t, d] = view()->prep_template("admin/listusers.phtml");

        app()->set_default_data(id, d);

	mixed ul;

	if(!id->variables->limit)
		ul = model()->find("user",([]));
	
	d->add("users", ul);
	
	response->set_template(t, d);
}

public void edituser(Request id, Response response, mixed ... args)
{
	if(!app()->is_admin_user(id, response))
          return;

	Template.Template t;
        Template.TemplateData d;
        [t, d] = view()->prep_template("admin/edituser.phtml");
	
        app()->set_default_data(id, d);
  	response->set_template(t, d);
}

public void deleteuser(Request id, Response response, mixed ... args)
{
	if(!app()->is_admin_user(id, response))
          return;

  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", "No user provided.");
  }
  if(!(u = model()->find_by_id("user", (int)id->variables->userid)))
  {
    response->flash("msg", "User id " + id->variables->userid + " does not exist.");
  }
  else
  {
    string n = u["Name"];
    u->delete();
    response->flash("msg", "User " + n + " deleted.");
  }
  response->redirect("listusers");

}

public void toggle_useractive(Request id, Response response, mixed ... args)
{
	if(!app()->is_admin_user(id, response))
          return;
  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", "No user provided.");
  }
  if(!(u = model()->find_by_id("user", (int)id->variables->userid)))
  {
    response->flash("msg", "User id " + id->variables->userid + " does not exist.");
  }
  else
  {
    u["is_active"] = !u["is_active"];
    
    string pre = "";
    if(!u["is_active"]) pre = "de";
    response->flash("msg", "User " + u["Name"] + " " + pre + "activated.");
  }
  response->redirect("listusers");
}


public void toggle_useradmin(Request id, Response response, mixed ... args)
{
	if(!app()->is_admin_user(id, response))
          return;
  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", "No user provided.");
  }
  if(!(u = model()->find_by_id("user", (int)id->variables->userid)))
  {
    response->flash("msg", "User id " + id->variables->userid + " does not exist.");
  }
  else
  {
    u["is_admin"] = !u["is_admin"];
    
    string pre = "granted";
    if(!u["is_admin"]) pre = "revoked";
    response->flash("msg", "User administrative rights " + pre + " for " + 
       u["Name"] + ".");
  }
  response->redirect("listusers");
}
