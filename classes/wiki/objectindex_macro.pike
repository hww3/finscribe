import Public.Web.Wiki;
import Fins;

inherit Macros.Macro;

string describe()
{
   return "Generates an index of objects";
}

void evaluate(String.Buffer buf, Macros.MacroParameters params)
{
//werror("%O\n", mkmapping(indices(params), values(params)));

  array o = Model.find("object", (["is_attachment": 0]));

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
      buf->add("<h4>");
      buf->add(upper_case(sprintf("%c", e[i][0])));
      buf->add("</h4>\n");
    }
    buf->add("<a href=\"/space/");
    buf->add(p[0]);
    buf->add("\">");
    buf->add(p[1]);
    buf->add("</a><br>\n");
    prev = p[1][0];
  }  
}
