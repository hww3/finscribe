inherit Fins.RESTController;

string model_component = "User";

protected multiset fields_to_filter = (<"objects", "versions", "comments", "password">);
