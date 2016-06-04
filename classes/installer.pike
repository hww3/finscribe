//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)


import Fins;
import Tools.Logging;
inherit Fins.FinsBase;

public int install(string dburl, string username, string password, string email) {
  if(verifyandcreate(dburl)) {
   if(createadminuser(username, password, email))
   {
     werror("success!");
     return 1;
   }
  }
  
  werror("failure!");
  return 0;
}

public void populateprefs(mapping variables)
{
  mixed e = catch {
  foreach(glob("pref.*", indices(variables));; string p)
  {
    int pt;
    switch(variables["type." + p[5..]])
    {
       case "string":
         pt = FinScribe.STRING;
         break;
       case "integer":
         pt = FinScribe.INTEGER;
         break;
       case "boolean":
         pt = FinScribe.BOOLEAN;
         break;
    }
    app->new_pref(p[5..], (["value": variables[p], "type": pt]));
  }
  };

  if(e)
  {
    Log.exception("Error occurred while populating database.", e);
  }
}

public int createadminuser(string username, string password, string email)
{
    object u;
  mixed e = catch {
    u = FinScribe.Objects.User();
    u["username"] = username;
    u["name"] = username;
    u["password"] = Crypto.make_crypt_md5(password);
    u["email"] = email;
    u["is_admin"] = 1;
    u["is_active"] = 1;
    u->save();

    u = FinScribe.Objects.User();
    u["username"] = "anonymous";
    u["name"] = "Anonymous";
    u["password"] = "*LCK*";
    u["email"] = "";
    u["is_admin"] = 0;
    u["is_active"] = 0;
    u->save();

    // now, we populate the starter objects.
    object o = ((program)"install")(app);
    o->populate();
  };

  if(e)
  {
//	werror("error: %O", e);
    Log.exception("Error while populating the database.", e);
   return 0;  
}
  else
  {
    app->controller->install = 0;
    app->reload_controllers();
    return 1;
  }
}

public int verifyandcreate(string dburl)
{
  string dbtype;
  string splitter;
  object sql;
  Log.debug("creating connection to database " + dburl);
  mixed e = (catch(sql=Sql.Sql(dburl)));
  if(e) 
  {
    Log.exception("An error occurred while connecting to the database "+ dburl + ".", e);
    return 0;
  }

  // SQLite will happily allow you to create a database somewhere it can't
  // look. So, we need to try to get it to access the database before we
  // declare success.
  e = catch(sql->list_tables());
  if(e) 
  {
    Log.exception("An error occurred while communicating with the database "+ dburl + ".", e);
    return 0;
  }

  Log.debug("connection to database " + dburl + " successful.");
  switch(dburl[0..1])
  {
    case "sq":
      dbtype="sqlite";
      splitter = "\\g\n";
      break;
    case "my":
      dbtype="mysql";
      splitter = ";\n";
      break;
    case "po":
      dbtype="postgres";
      splitter = "\\g\n";
      break;
    default:
      Log.error("Unknown database type: %s", dburl);
      return 0;
  }

  // now, we can populate the schema.
  string s = Stdio.read_file(Stdio.append_path(app->config->app_dir, "/config/schema." + dbtype));
  mapping tables = ([]);
  
  Log.debug("loaded schema for " + dbtype + ".");

  // Remove the #'s, if they're there.
  string _s = "";
  foreach(s / "\n"; int lnum; string line) {
    Log.debug("looking at line %d.", lnum);
    if (!sizeof(line) || line[0] == '#')
      continue;
    else
      _s += line + "\n";
  }
  s = _s;

  string command;
 
  Log.debug("parsing schema.");

  // Split it into statements;
  foreach((s / splitter) - ({ "\n" }), command) {
    string table_name;
    if (sscanf(command, "CREATE TABLE %s %*s", table_name))
    {
      Log.debug("found definition for %s.", table_name);
      tables[table_name] = String.trim_all_whites(command);
    }
  }

  // Create tables

  Log.debug("getting tables in database.");

  multiset extant_tables = (multiset)sql->list_tables();

 Log.debug("have tables.\n");

  foreach(indices(tables), string name) {
    Log.debug("command: %s", tables[name]);
    if (extant_tables[name])
      continue;
   else
     Log.debug("executing.");
    e = catch(sql->query(tables[name]));
    if (e) {
      Log.exception("An error occurred while running a command: " + tables[name] + ".", e);
      return 0;
    }
  }

  Log.debug("starting model.");

  // now, we restart the model.
  config->set_value("application", "installed", 1);
  config->set_value("model", "datasource", dburl);

  view->default_template = (program)"themed_template";

werror("app: %O\n", app);
werror("app->kick_model: %O\n", app->kick_model);

  app->kick_model();
  app->load_plugins(); 
 return 1;
}

private int haveit(string sym)
{
  int x = !zero_type(all_constants()[sym]) ||
    !zero_type(master()->resolv(sym));
  return x;
}
