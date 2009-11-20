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

  array o = Fins.DataSource._default.find.categories(([]));
  array res = ({});
  array e = ({});
  array f = ({});

  foreach(o;; object elem)
  {
    string subject = elem["category"];

    e += ({ lower_case(subject) });
    f += ({ ({ subject, subject }) });
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
    res+=({"<a href=\"/exec/category/"});
    res+=({p[0]});
    res+=({"\">"});
    res+=({p[1]});
    res+=({"</a><br>\n"});
    prev = e[i][0];
  }  
  return res;
}
