//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)


import Fins;
import Tools.Logging;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
  object v = view->get_idview("install/wizard");

  v->add("dbs", available_dbs());
  response->set_view(v);

}

public void populateprefs(Request id, Response response, mixed ... args)
{
  mixed e = catch {
  foreach(glob("pref.*", indices(id->variables));; string p)
  {
    int pt;
    switch(id->variables["type." + p[5..]])
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
    app->new_pref(p[5..], id->variables[p], pt);
  }
  };

  if(e)
  {
    Log.exception("Error occurred while populating database.", e);
    response->set_data(((array)e)[0]);  
  }
  else
    response->set_data("true");
}

public void createadminuser(Request id, Response response, mixed ... args)
{
    object u;
  mixed e = catch {
    u = FinScribe.Objects.User();
    u["UserName"] = id->variables->adminuser;
    u["Name"] = id->variables->adminuser;
    u["Password"] = id->variables->adminpassword;
    u["Email"] = id->variables->adminemail;
    u["is_admin"] = 1;
    u["is_active"] = 1;
    u->save();

    u = FinScribe.Objects.User();
    u["UserName"] = "anonymous";
    u["Name"] = "Anonymous";
    u["Password"] = "*LCK*";
    u["Email"] = "";
    u["is_admin"] = 0;
    u["is_active"] = 0;
    u->save();

    // now, we populate the starter objects.
    object o = ((program)"install")(app);
    o->populate();
  };



  if(e)
  {
    Log.exception("Error while creating admin user.", e);
    response->set_data(((array)e)[0]);  
  }
  else
  {
    response->set_data("true");
    app->controller->install = 0;
  }
}

public void verifyandcreate(Request id, Response response, mixed ... args)
{
  string dbtype;
  string splitter;
  object sql;
  Log.debug("creating connection to database " + id->variables->dburl);
  mixed e = (catch(sql=Sql.Sql(id->variables->dburl)));
  if(e) 
  {
    Log.exception("An error occurred while connecting to the database "+ id->variables->dburl + ".", e);
    response->set_data(((array)e)[0]);
    return;
  }

  // SQLite will happily allow you to create a database somewhere it can't
  // look. So, we need to try to get it to access the database before we
  // declare success.
  e = catch(sql->list_tables());
  if(e) 
  {
    Log.exception("An error occurred while communicating with the database "+ id->variables->dburl + ".", e);
    response->set_data(((array)e)[0]);
    return;
  }

  Log.debug("connection to database " + id->variables->dburl + " successful.");
  switch(id->variables->dburl[0..1])
  {
    case "SQ":
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
      Log.error("Unknown database type: %s", id->variables->dburl);
      response->set_data("Unknown database type.");
      return;
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
      tables[table_name] = command;
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
      response->set_data(((array)e)[0]);
      return;
    }
  }

  Log.debug("starting model.");

  // now, we restart the model.
  config->set_value("application", "installed", 1);
  config->set_value("model", "datasource", id->variables->dburl);

  view->default_template = (program)"themed_template";

  app->kick_model();
  app->load_plugins();

  response->set_data("true");

}

public void makedburl(Request id, Response response, mixed ... args)
{
  string url = "";
  if(args[0] == "SQLite")
  {
    url = sprintf("SQLite://%s", id->variables->sqlitepath);
  }
  else if(args[0] == "mysql")
  {
    url = sprintf("mysql://%s:%s@%s/%s", 
                     id->variables->mysqluser,
                     id->variables->mysqlpassword,
                     id->variables->mysqlhost,
                     id->variables->mysqldatabase);
  }

  else if(args[0] == "postgres")
  {
    url = sprintf("postgres://%s:%s@%s/%s", 
                     id->variables->postgresuser,
                     id->variables->postgrespassword,
                     id->variables->postgreshost,
                     id->variables->postgresdatabase);
  }

  response->set_data(url);
}

public void getdburlconfigurator(Request id, Response response, mixed ... 
args)
{
  if(!args || !args[0])
    response->set_data("Invalid db type.");
  else if (!(<"mysql", "postgres", "SQLite">)[args[0]])
  {
    response->set_data("Unsupported database type.");
  }
  else
  {
    object v = view->get_idview("install/" + args[0]);
    response->set_view(v);
  }
}

private array available_dbs()
{
  array r = ({});


  if(haveit("Sql.Provider.SQLite"))
  {
    r += ({"SQLite"});
  }

  if(haveit("Mysql.mysql"))
  {
    r += ({"mysql"});
  }

  if(haveit("Postgres.postgres"))
  {
    r += ({"postgres"});
  }

  return r;
}

private int haveit(string sym)
{
  int x = !zero_type(all_constants()[sym]) ||
    !zero_type(master()->resolv(sym));
  return x;
}
