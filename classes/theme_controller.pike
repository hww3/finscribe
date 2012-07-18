//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Fins;
import Fins.Model;
inherit Fins.FinsController;

// provides a static file controller that accesses files in themes/

string root;

public void index(Request id, Response response, mixed ... args)
{
  if(!root) root = Stdio.append_path(app->config->app_dir, "themes/");

  if(!args || !sizeof(args))
  {
     response->set_data(LOCALE(421,"You must provide a file to retrieve."));
     return;
  }

  app->low_static_request(id, response, args * "/", root);

}
