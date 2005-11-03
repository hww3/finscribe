import Fins;
inherit Fins.Controller;

Fins.Controller exec = ((program)"exec_controller.pike")();
Fins.Controller space = ((program)"app_controller.pike")();
Fins.Controller comments = ((program)"comment_controller.pike")();

public void index(Request id, Response response, mixed ... args)
{
   response->redirect("space");
}
