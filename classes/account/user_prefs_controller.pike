inherit "admin/preference_controller";

protected string vtype = "admin";


static void start()
{
  before_filter(app->user_filter);
}


