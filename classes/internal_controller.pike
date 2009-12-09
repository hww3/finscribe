import Fins;
inherit Fins.FinsController;

// provides a mount point for plugin supplied filesystem paths.

static mixed `[](mixed a)
{
   return app->internal_path_handlers[a];
}
