inherit Fins.FinsController;

Fins.FinsController user;
Fins.FinsController document;
Fins.FinsController datatype;

void start()
{
 user = load_controller("rest/user_controller");
 document = load_controller("rest/object_controller");
 datatype = load_controller("rest/datatype_controller");
}
