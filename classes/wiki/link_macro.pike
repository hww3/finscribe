import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Handles internal/external links";
}

void evaluate(String.Buffer buf, Macros.MacroParameters params)
{
  if(!sizeof(params->parameters))
  {
    buf->add("INVALID LINK");
    return;
  }

  string link, name, img;
  
  array a = params->parameters/"|";
  
  foreach(a;int i; string elem)
  { 
     if(i==0 && search(elem, "=") == -1)
     {
        name = elem;
        link = elem;
     }
     else if(i==1 && search(elem, "=") == -1)
     {
        link = elem;
     }
     else if(search(elem, "=")== -1)
     {
        buf->add("INVALID LINK PARAMETER: " + elem);
        return;
     }
     else
     {
        array b = elem/"=";
        if(!sizeof(b)==2)
        {
           buf->add("INVALID LINK PARAMETER: " + elem);
           return;
        }

        switch(b[0])
        {
           case "img":
             img = b[1];
             break;
            default:
            {
               buf->add("INVALID LINK PARAMETER: " + elem);
               return;
            }
        }
     }
  }

  if(!img)
  {  
     buf->add("<img height=\"9\" width=\"8\" src=\"");
     buf->add("/static/images/Icon-Extlink.png\">");
  }
  buf->add("<a href=\"");
  buf->add(link);
  buf->add("\">");
  buf->add(name);
  buf->add("</a>");
}
