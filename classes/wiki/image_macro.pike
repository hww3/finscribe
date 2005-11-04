import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Handles images";
}

void evaluate(String.Buffer buf, Macros.MacroParameters params)
{
//werror("%O\n", mkmapping(indices(params), values(params)));
  if(!sizeof(params->parameters))
  {
    buf->add("INVALID IMAGE");
    return;
  }

  string link, image, alt, align;
  
  array a = params->parameters/"|";
  
  foreach(a;int i; string elem)
  { 
     if(!i && search(elem, "=") == -1)
     {
        image = elem;
       if(params->extras->obj && params->extras->obj)
{
         image = combine_path("/space/" + params->extras->obj["path"], image);
}
     }
     else if(search(elem, "=")== -1)
     {
        buf->add("INVALID IMAGE PARAMETER: " + elem);
        return;
     }
     else
     {
        array b = elem/"=";
        if(!sizeof(b)==2)
        {
           buf->add("INVALID IMAGE PARAMETER: " + elem);
           return;
        }

        switch(b[0])
        {
           case "link":
             link = b[1];
             break;
            case "alt":
              alt = b[1];
              break;
            case "align":
               align = b[1];
               break;
           case "img":
             image = combine_path("/static/images/", b[1]+".png");
             break;
            default:
            {
               buf->add("INVALID IMAGE PARAMETER: " + elem);
               return;
            }
        }
     }
  }
  
  if(link)
  {
     buf->add("<a href=\"");
     buf->add(link);
     buf->add("\">");
  }
     buf->add("<img src=\"");
     buf->add(image);
     buf->add("\"");
     if(alt)
     {
        buf->add(" alt=\"");
        buf->add(alt);
        buf->add("\"");
     }
     if(align)
     {
        buf->add(" align=\"");
        buf->add(align);
        buf->add("\"");
     }

     buf->add(">");
  if(link)
  {
     buf->add("</a>");
  }
}
