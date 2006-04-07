//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Fins;
import Fins.Model;
inherit Fins.FinsController;


public void index(Request id, Response response, mixed ... args)
{
  if(!args || !sizeof(args))
  {
     response->set_data("You must provide a file to retrieve.");
     return;
  }

  string path = Stdio.append_path(app->config->app_dir, "themes/" + args*"/");


  app->low_static_request(id, response, path);

}
