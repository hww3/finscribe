import Tools.Logging;
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
  object u = FinScribe.Objects.User(UNDEFINED);
  u["username"] = "admin";
  u["password"] = password;
  u["name"] = "Admin User";
  u["email"] = email;
  u["is_active"] = 1;
  u["is_admin"] = 1;
  u->save();
 
  populate();  
}

void populate()
{
  // then, we create the datatypes
  master()->cd(combine_path(app->config->app_dir,"theme"));
  Log.info("Loading datatypes.");
  foreach(Stdio.read_file("datatypes.conf")/"\n", string dt)
  {
    object d;
    dt = String.trim_whites(dt);
    if(dt=="") continue;
    d = model->context->find->datatypes((["mimetype": dt]));
    if(d && sizeof(d))
       continue;
    else
      d = FinScribe.Objects.Datatype(UNDEFINED);
    d["mimetype"] = dt;
    d->save();
  }

  Log.info("Creating users.");
  create_groups();
  Log.info("Creating ACLs.");
  create_acls();
  Log.info("Creating Templates.");
  create_templates();

  Log.info("Loading predefined wiki objects.");
  foreach(glob("*.wiki", get_dir(".")), string fn)
  {
    model->new_from_string(combine_path("themes/default/", fn[..sizeof(fn)-6]), 
              Stdio.read_file(fn), "text/wiki");
  }

  array a = model->context->find->objects((["path": Fins.Model.LikeCriteria("%-index")]));
 
  // move all "*-index" objects up to the root.
  foreach(a;; object i)
  {
    Log.debug("moving %s to the root.", i["path"]);
    i["path"] = (i["path"]/"/")[-1];
  }
  // then we load up the start object.

  write("Loading initial objects...\n");
  model->new_from_string("start", "1 Welcome to FinScribe.\n\nTo get started, log in and click the edit button.\n\n{weblog}", "text/wiki", 0, 1);

}


// set up the default template.
void create_templates()
{
  object t;

  t = FinScribe.Objects.Template();
  t["name"] = "Default";
  t->save();
}

// set up the default groups.
void create_groups()
{
  object g;

  g = FinScribe.Objects.Group();
  g["name"] = "Editors";
  g->save();
}

// set up the default acls.
void create_acls()
{
  object a;
  object r;

  a = FinScribe.Objects.ACL();
  a["name"] = "Default ACL";
  a->save();

  r = FinScribe.Objects.ACLRule();
  r["class"] = 4; // guests have browse, read, comment
  r["xmit"] = 35;

  r->save();
  a["aclrules"] += r;

  r = FinScribe.Objects.ACLRule();
  r["class"] = 2; // users have browse, read, version, create, comment.
  r["xmit"] = 47;
  r->save();
  a["aclrules"] += r;

  r = FinScribe.Objects.ACLRule();
  r["class"] = 1; // owners have browse, read, version, create, delete, comment, post and lock.
  r["xmit"] = 255;
  r->save();
  a["aclrules"] += r;

  r = FinScribe.Objects.ACLRule();
  r["class"] = 0; // Editors have browse, read, version, create, delete, comment, post and lock.
  r["xmit"] = 255;
  r->save();
  object e = model->context->find->groups((["name": "Editors"]))[0];
    if(!e) werror("no editors!\n");
  else 
    r["groups"] = e;
  a["aclrules"] += r;


  a = FinScribe.Objects.ACL();
  a["name"] = "Work In Progress Object";
  a->save();

  r = FinScribe.Objects.ACLRule();
  r["class"] = 1; // owners have browse, read, version, create, comment, post and lock.
  r["xmit"] = 239;
  r->save();
  a["aclrules"] += r;

  r = FinScribe.Objects.ACLRule();
  r["class"] = 0; // Editors have browse, read, version, create, delete, comment, post and lock.
  r["xmit"] = 255;
  r->save();
  e = model->context->find->groups((["name": "Editors"]))[0];
    if(!e) werror("no editors!\n");
  else 
    r["group"] = e;
  a["aclrules"] += r;
}
