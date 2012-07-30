inherit Fins.StaticController;

static object logger = Tools.Logging.get_logger("finscribe.plugins.pluginsupport");

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

    string plugindir = combine_path(app->plugins[plugin]->module_dir, "/static");
    st = file_stat(plugindir);

    if(!st || !st->isdir)
    {
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
    response->not_found(args*"/");
    return;
  }
  else
  {
    string f = Stdio.append_path("/", args * "/");

    logger->debug("Does %s exist?", f);

    return low_static_request(id, response, f, _pluginfs[plugin]);
  }

}


protected Filesystem.Base create_filesystem()
{
  return 0;
}
