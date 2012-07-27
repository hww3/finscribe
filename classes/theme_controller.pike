//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Fins;
import Fins.Model;
inherit Fins.StaticController;

// provides a static file controller that accesses files in themes/

string root;

object create_filesystem()
{
  if(!static_dir) static_dir = Stdio.append_path(app->config->app_dir, "themes/");

  return ::create_filesystem();
}

public void index(Request id, Response response, mixed ... args)
{
  if(!args || !sizeof(args))
  {
     response->set_data(LOCALE(421,"You must provide a file to retrieve."));
     return;
  }

  low_static_request(id, response, args * "/");

}
