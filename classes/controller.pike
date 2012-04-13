import Fins;
inherit Fins.FinsController;

Fins.FinsController objects;

Fins.FinsController account;
Fins.FinsController exec;
Fins.FinsController space;
Fins.FinsController comments;
Fins.FinsController admin;
Fins.FinsController xmlrpc;
Fins.FinsController rss;
Fins.FinsController atom;
Fins.FinsController theme, themes;
Fins.FinsController _internal;
Fins.FinsController install;
Fins.FinsController rest;

// if we are started in install mode (that is, if the application->installed variable
//  is zero or not present), load up the installer only. otherwise load up the real
//  controllers.
void start()
{
  if(!config["application"] || !(int)config["application"]["installed"])
  {
    Tools.Logging.Log.info("Starting in install mode.");
    install = load_controller("install_controller");
    view->default_template = Fins.Template.Simple;
  }
  else
  {
    account = load_controller("account/account_controller");
    objects = load_controller("objects_controller");
    rest = load_controller("rest_controller");
    exec = load_controller("exec_controller");
    space = load_controller("app_controller");
    comments = load_controller("comment_controller");
    admin = load_controller("admin_controller");
    xmlrpc = load_controller("xmlrpc_controller");
    rss = load_controller("rss_controller");
    atom = load_controller("atom_controller");
    theme = load_controller("theme_controller");
    themes = theme;
    _internal = load_controller("internal_controller");
  }

 ::start();
}

// redirect the request to the appropriate controller
public void index(Request id, Response response, mixed ... args)
{
  if(!config["application"] || !(int)config["application"]["installed"])
    response->redirect("install");
  else if(!sizeof(args))
     response->redirect("space");
  else if(object_program(id) == Fins.FCGIRequest)
     response->not_found("/" + args*"/");
}
