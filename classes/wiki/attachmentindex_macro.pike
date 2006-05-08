import Public.Web.Wiki;
import Fins;

inherit Macros.Macro;

string describe()
{
   return "Generates an index of objects marked as attachments";
}

array evaluate(Macros.MacroParameters params)
{
//werror("%O\n", mkmapping(indices(params), values(params)));

  if(params->extras && params->extras->request)
    params->extras->request->misc->object_is_index = 1;

  array o = params->engine->wiki->model->find("object", (["is_attachment": 1]));
  array res = ({});
  array e = ({});
  array f = ({});

  foreach(o;; object elem)
  {
    string subject;
    object j = elem["current_version"];
    if(j) subject = j["subject"];
    if(!subject || !sizeof(subject))
      subject = (elem["path"]/"/")[-1];
    e += ({ lower_case(subject) });
    f += ({ ({ elem["path"], subject }) });
  }

  sort(e,f);
  int prev;
  foreach(f; int i; array p)
  {
    if(prev != e[i][0])
    {
      res+=({"<h4>"});
      res+=({upper_case(sprintf("%c", e[i][0]))});
      res+=({"</h4>\n"});
    }
    res+=({"<a href=\"/space/"});
    res+=({p[0]});
    res+=({"\">"});
    res+=({p[1]});
    res+=({"</a><br>\n"});
    prev = p[1][0];
  }  
  return res;
}
