import Fins;
inherit Fins.FinsController;

Fins.FinsController exec;
Fins.FinsController space;
Fins.FinsController comments;
Fins.FinsController admin;
Fins.FinsController xmlrpc;
Fins.FinsController rss;
Fins.FinsController theme;
Fins.FinsController _internal;
Fins.FinsController install;
Fins.FinsController whee;

void start()
{
  whee = load_controller("whee_controller");
  exec = load_controller("exec_controller");
  space = load_controller("app_controller");
  comments = load_controller("comment_controller");
  admin = load_controller("admin_controller");
  xmlrpc = load_controller("xmlrpc_controller");
  rss = load_controller("rss_controller");
  theme = load_controller("theme_controller");
  _internal = load_controller("internal_controller");

  if(!config["app"] || !config["app"]["installed"])
  {
    install = load_controller("install_controller");
    view->default_template = Fins.Template.Simple;
  }
}

public void index(Request id, Response response, mixed ... args)
{
  if(!config["app"] || !config["app"]["installed"])
    response->redirect("install");
  else if(!sizeof(args))
     response->redirect("space");
  else if(object_program(id) == Fins.FCGIRequest)
     response->not_found("/" + args*"/");
}
