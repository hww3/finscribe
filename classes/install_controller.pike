//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)


import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
  response->set_data("installer.");
}

