import Fins;
inherit Fins.FinsController;


public void listusers(Request id, Response response, mixed ... args)
{
	Template.Template t = view()->get_template(view()->template, "listusers.tpl");
	Template.TemplateData d = Template.TemplateData();

	mixed ul;

	if(!id->variables->limit)
		ul = model()->find("user",([]));
	
	d->add("users", ul);
	
	response->set_template(t, d);
}

public void edituser(Request id, Response response, mixed ... args)
{
	Template.Template t = view()->get_template(view()->template, "edituser.tpl");
	Template.TemplateData d = Template.TemplateData();
	
  	response->set_template(t, d);
}

public void deleteuser(Request id, Response response, mixed ... args)
{
	Template.Template t = view()->get_template(view()->template, "deleteuser.tpl");
	Template.TemplateData d = Template.TemplateData();
	
  response->set_template(t, d);
}
