inherit Fins.FinsBase;

int run()
{
  object readline = Stdio.Readline();

  // first, let's create an admin user.
  string password, email;
  write("Please enter a password for the user 'admin': ");
  password = readline->read();
  write("Please enter the email address for 'admin': ");
  email = readline->read();

  write("\nAdmin User Details\n");
  write("--------------------\n");
  write("Username: admin\n");
  write("Password: " + password + "\n");
  write("Email: " + email + "\n");
  write("\n");

  string resp;

  while(1)
  {
    write("Correct? (y/n) ");
    resp = readline->read();
    if(lower_case(resp) == "n") { write("aborting.\n"); return 0; }
    else if (lower_case(resp) == "y")
       break;
  }

  write("Creating admin user...\n");
  object u = FinScribe.Model.User(UNDEFINED);
  u["UserName"] = "admin";
  u["Password"] = password;
  u["Name"] = "Admin User";
  u["Email"] = email;
  u["is_active"] = 1;
  u["is_admin"] = 1;
  u->save();
 
  populate();  
}

void populate()
{
  // then, we create the datatypes
  cd(combine_path(app->config->app_dir,"theme"));
  write("Loading datatypes...\n");
  foreach(Stdio.read_file("datatypes.conf")/"\n", string dt)
  {
    object d;
    dt = String.trim_whites(dt);
    if(dt=="") continue;
    d = model->find("datatype", (["mimetype": dt]));
    if(d && sizeof(d))
       continue;
    else
      d = FinScribe.Model.Datatype(UNDEFINED);
    d["mimetype"] = dt;
    d->save();
  }

  write("Loading predefined wiki objects...\n");
  foreach(glob("*.wiki", get_dir(".")), string fn)
  {
    model->new_from_string(combine_path("themes/default/", fn[..sizeof(fn)-6]), 
              Stdio.read_file(fn), "text/wiki");
  }

  array a = model->find("object", (["path": Fins.Model.LikeCriteria("%-index")]));
 
  // move all "*-index" objects up to the root.
  foreach(a;; object i)
    i["path"] = (i["path"]/"/")[-1];

  write("Loading stylesheets...\n");
  foreach(glob("*.css", get_dir(".")), string fn)
  {
    model->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/css", 1);
  }

  foreach(glob("*.js", get_dir(".")), string fn)
  {
    model->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "application/javascript", 1);
  }

  // then we load up the start object.

  write("Loading initial objects...\n");
  model->new_from_string("start", "1 Welcome to FinScribe.\n\nTo get started, log in and click the edit button.\n\n{weblog}", "text/wiki", 0, 1);

}
