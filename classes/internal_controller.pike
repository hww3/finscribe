import Fins;
inherit Fins.FinsController;

// compression is a good thing, so let's offer it.
static void start()
{
  after_filter(Fins.Helpers.Filters.Compress());
}


// provides a mount point for plugin supplied filesystem paths.

static mixed `[](mixed a)
{
   return app->internal_path_handlers[a];
}
