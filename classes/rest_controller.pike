inherit Fins.FinsController;

Fins.FinsController user;

void start
{
 user = load_controller("rest/user_controller");
}
