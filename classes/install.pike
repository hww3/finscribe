
int run()
{
  // first, we create the user
  object u = Fins.Model.new("user");
  u["Name"] = "Bill Welliver";
  u["Password"] = "foo";
  u["UserName"] = "bill";
  u["Email"] = "foo@bar.com";
  u->save();
 
  // then, we create the datatypes
  cd("templates");
  foreach(Stdio.read_file("datatypes.conf")/"\n", string dt)
  {
    object d = Fins.Model.new("datatype");
    d["mimetype"] = String.trim_whites(dt);
    d->save();
  }

  // then we load up the templates
  foreach(glob("*.tpl", get_dir(".")), string fn)
  {
    application->model->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/template");
  }

  foreach(glob("*.wiki", get_dir(".")), string fn)
  {
    application->model->new_from_string(combine_path("themes/default/", fn[..sizeof(fn)-6]), 
              Stdio.read_file(fn), "text/wiki");
  }

  foreach(glob("*.css", get_dir(".")), string fn)
  {
    application->model->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/css");
  }

  foreach(glob("*.js", get_dir(".")), string fn)
  {
    application->model->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/javascript");
  }

  // then we load up the start object.
   application->model->new_from_string("start", "1 Welcome to FinBlog.\n\nTo get started, log in and click the edit button.", "text/wiki");
   application->model->new_from_string("object-index", "{object-index}", "text/wiki");

}

