import Fins;
inherit Fins.FinsController;

Fins.FinsController exec = ((program)"exec_controller.pike")();
Fins.FinsController space = ((program)"app_controller.pike")();
Fins.FinsController comments = ((program)"comment_controller.pike")();

public void index(Request id, Response response, mixed ... args)
{
  if(!sizeof(args))
   response->redirect("space");
  else response->not_found("/" + args*"/");
}
