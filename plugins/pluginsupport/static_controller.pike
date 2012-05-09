inherit Fins.FinsController;

static object logger = Tools.Logging.get_logger("finscribe.plugins.pluginsupport");

void index(object id, object response, mixed ... args)
{
  if(!sizeof(args) || sizeof(args) < 2) 
  {
    response->set_data("Invalid request for plugin static data: " + args*"/");
    return;
  }

  if(!app->plugins[args[0]] || !file_stat(app->plugins[args[0]]->module_dir + "/static"))
  {
    response->not_found(args*"/");
    return;
  }

  else
  {
    string f = Stdio.append_path(app->plugins[args[0]]->module_dir, "/static", args[1..]*"/");

    logger->debug("Does %s exist?", f);

    app->low_static_request(id, response, f);

    return;

  }

}
