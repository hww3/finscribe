import Public.Web.Wiki;
import Fins;

inherit Macros.Macro;

string describe()
{
   return "Generates an index of objects";
}

array evaluate(Macros.MacroParameters params)
{
//werror("%O\n", mkmapping(indices(params), values(params)));

  if(params->extras && params->extras->request)
    params->extras->request->misc->object_is_index = 1;

  if(!params->args) params->make_args();

  array o = Fins.DataSource._default.find.objects((["is_attachment": 0]));
  if (params->args->showblog)
    o += Fins.DataSource._default.find.objects(([ "is_attachment" : 2]));
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
//	 werror("current: %O\n", e);
    if(sizeof(e[i]) && prev != e[i][0])
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
    if(sizeof(e[i]))
      prev = e[i][0];
//	werror("prev: %O ", prev);
  }  
  return res;
}
