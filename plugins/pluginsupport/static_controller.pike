inherit Fins.StaticController;

static object logger = Tools.Logging.get_logger("finscribe.plugins.pluginsupport");

int allow_directory_listings = 1;

static mapping _pluginfs = ([]);

void index(object id, object response, mixed ... args)
{
  if(!sizeof(args)) 
  {
    response->set_data("Invalid request for plugin static data: " + args*"/");
    return;
  }

  string plugin;

  [plugin, args] = Array.shift(args);

  // populate the filesystem object mapping if it's missing this plugin.
  // -1 means the plugin has no static directory.
  if(!_pluginfs[plugin])
  {
    Stdio.Stat st;

    if(!app->plugins[plugin])
    {
      logger->debug("no such plugin: %O\n", plugin);
      _pluginfs[plugin] = -1;
    }

    string plugindir = Stdio.append_path(app->plugins[plugin]->module_dir, "/static");
    st = file_stat(plugindir);

    if(!st || !st->isdir)
    {
      logger->debug("plugin has no static directory: %O %O\n", plugin, app->plugins[plugin]->module_dir);
      _pluginfs[plugin] = -1;
    }
    else
    {
      object fs = Filesystem.System(plugindir)->chroot(plugindir);
      _pluginfs[plugin] = fs;
    }    
  }

  if(_pluginfs[plugin] == -1)
  {
    response->not_found(id->not_query);
    return;
  }
  else
  {
    string f = Stdio.append_path("/", args * "/");
    object fs = _pluginfs[plugin];
    logger->debug("Does %s exist in %O?", f, fs);

    low_static_request(id, response, f, fs);
  }

}


protected Filesystem.Base create_filesystem()
{
  return 0;
}
