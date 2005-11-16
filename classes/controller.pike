import Fins;
inherit Fins.FinsController;

Fins.FinsController exec;
Fins.FinsController space;
Fins.FinsController comments;
Fins.FinsController admin;

static void create(Fins.Application a)
{
  ::create(a);
  exec = ((program)"exec_controller")(a);
  space = ((program)"app_controller")(a);
  comments = ((program)"comment_controller")(a);
//  admin = ((program)"admin_controller")(a);
}

public void index(Request id, Response response, mixed ... args)
{
  if(!sizeof(args))
   response->redirect("space");
}
