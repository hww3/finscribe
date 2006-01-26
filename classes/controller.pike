import Fins;
inherit Fins.FinsController;

Fins.FinsController exec;
Fins.FinsController space;
Fins.FinsController comments;
Fins.FinsController admin;
Fins.FinsController xmlrpc;
Fins.FinsController rss;
Fins.FinsController _internal;

static void create(Fins.Application a)
{
  ::create(a);
  exec = ((program)"exec_controller")(a);
  space = ((program)"app_controller")(a);
  comments = ((program)"comment_controller")(a);
  admin = ((program)"admin_controller")(a);
  xmlrpc = ((program)"xmlrpc_controller")(a);
  rss = ((program)"rss_controller")(a);
  _internal = ((program)"internal_controller")(a);
}

public void index(Request id, Response response, mixed ... args)
{
werror("ARGS: %O\n", args);
  if(!sizeof(args))
     response->redirect("space");
  else if(object_program(id) == Fins.FCGIRequest)
     response->not_found("/" + args*"/");
}
