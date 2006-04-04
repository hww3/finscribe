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

static void create(Fins.Application a)
{
  ::create(a);
  exec = ((program)"exec_controller")(a);
  space = ((program)"app_controller")(a);
  comments = ((program)"comment_controller")(a);
  admin = ((program)"admin_controller")(a);
  xmlrpc = ((program)"xmlrpc_controller")(a);
  rss = ((program)"rss_controller")(a);
  theme = ((program)"theme_controller")(a);
  _internal = ((program)"internal_controller")(a);

  if(!config["app"] || !config["app"]["installed"])
    install = ((program)"install_controller")(a);
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
