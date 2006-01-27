import Fins;
inherit Fins.FinsController;

static mixed `[](mixed a)
{
   return app->internal_path_handlers[a];
}
