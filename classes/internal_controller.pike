import Fins;
inherit Fins.FinsController;

// compression is a good thing, so let's offer it.
static void start()
{
  after_filter(Fins.Helpers.Filters.Compress());
}


// provides a mount point for plugin supplied filesystem paths.

function `-> = `[];

static mixed `[](mixed a)
{
//werror("`->[%O]\n", a);
//werror("internal_path_handlers=%O\n", app->internal_path_handlers);
  mixed v;

   if(v = ::`[](a, 2))
   {
     return v;
   }
   else
     return app->internal_path_handlers[a];
}
