import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Handles images";
}

array evaluate(Macros.MacroParameters params)
{
//werror("%O\n", mkmapping(indices(params), values(params)));
  if(!sizeof(params->parameters))
  {
    return ({"INVALID IMAGE"});
  }

  string link, image, alt, align;
  array res = ({});
  array a = params->parameters/"|";
  
  foreach(a;int i; string elem)
  { 
     if(!i && search(elem, "=") == -1)
     {
        image = elem;
       if(params->extras->obj && objectp(params->extras->obj))
{
         image = combine_path("/space/" + params->extras->obj["path"], image);
}
     }
     else if(search(elem, "=")== -1)
     {
        return({"INVALID IMAGE PARAMETER: " + elem});
     }
     else
     {
        array b = elem/"=";
        if(!sizeof(b)==2)
        {
           return ({"INVALID IMAGE PARAMETER: " + elem});
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
               return ({"INVALID IMAGE PARAMETER: " + elem});

            }
        }
     }
  }
  
  if(link)
  {
     res+=({"<a href=\""});
     res+=({link});
     res+=({"\">"});
  }
     res+=({"<img src=\""});
     res+=({image});
     res+=({"\" alt=\""});
     if(alt)
     {
        res+=({alt});
     }
     res+=({"\""});

     if(align)
     {
        res+=({" align=\""});
        res+=({align});
        res+=({"\""});
     }

     res+=({"/>"});
  if(link)
  {
     res+=({"</a>"});
  }

  return res;
}
