import Fins;
inherit Fins.Template.Simple;

string load_template(string templatename)
{
  string path = combine_path("themes/default", templatename);

  array dt = context->application->model->find("datatype", (["mimetype": "text/template"]));
  if(!sizeof(dt))
    throw(Error.Generic("unable to load standard datatype. database corrupt.\n"));

  object datatype = dt[0];

  array r = context->application->model->find("object", (["path": path, "datatype": datatype ]));

  if(!sizeof(r)) return 0;
 
  else return r[0]["current_version"]["contents"];
}

