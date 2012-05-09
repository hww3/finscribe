//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name="reCAPTCHA support";

int _enabled = 1;

void start()
{
}

mapping query_event_callers()
{
  return (["prePostComment": check_recaptcha_anon,
           "preCreateAccount": check_recaptcha_always ]);
}

mapping query_preferences()
{
  return ([
             "public-key": (["type": FinScribe.STRING, "value": "NO_KEY_YET"]),
             "private-key": (["type": FinScribe.STRING, "value": "NO_KEY_YET"])
          ]);
}

int check_recaptcha_anon(string event, object id, object obj)
{
  int anonymous = id->misc->anonymous;

  if(anonymous) return check_recaptcha_always(event, id, obj);

}

int check_recaptcha_always(string event, object id, object obj)
{
     if(!get_preference("private-key"))
        logger->info("skipping reCAPTCHA; no private-key set.");  
     else
     {
        logger->info("checking reCAPTCHA.");  
        // if we've got a recaptcha key, we assume it will be used.
        if(!id->variables->recaptcha_challenge_field ||
           !id->variables->recaptcha_response_field)
        {
            if(id->variables->ajax)
              throw(Error.Generic(LOCALE(424,"Error: No reCAPTCHA data provided.")));
            else
              throw(Error.Generic(LOCALE(424,"Error: No reCAPTCHA data provided.")));
        }

        else
        {
          logger->debug("reCAPTCHA data: %O %O",                    
                 id->variables->recaptcha_response_field,
                 id->variables->recaptcha_challenge_field);

          object rc = FinScribe.Recaptcha(get_preference("private-key")["value"]);
          if(!rc->validate(id->variables->recaptcha_challenge_field,
                   id->variables->recaptcha_response_field,
                   id->get_client_addr()))
          {
              logger->info("rejected reCAPTCHA from %s.", id->get_client_addr());
              throw(Error.Generic(LOCALE(0,"Error: reCAPTCHA failure: " + rc->get_error())));
          }


          }
       }
  logger->info("reCAPTCHA success from %s.", id->get_client_addr());
  return FinScribe.success;
}
