inherit "admin/preference_controller";

protected string vtype = "account";


static void start()
{
  before_filter(app->user_filter);
}


protected string get_root(object id)
{
  return app->get_current_user(id)["username"] + ".";
}
