import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Handles images";
}

array evaluate(Macros.MacroParameters params)
{
  if(!sizeof(params->parameters))
  {
    return ({"INVALID IMAGE"});
  }

  string link, image, alt, align;
  array res = ({});

  if(!params->args) params->make_args();
 
  array a = indices(params->args);

  if(params->args[a[0]] == "1")
    image = a[0];
  else if(params->args->src)
    image = params->args->src;
  else return ({"INVALID IMAGE SRC"});

  if(params->args->link)
    link = params->args->link;
  if(params->args->alt)
    alt = params->args->alt;
  if(params->args->align)
    align = params->args->align;
  if(params->args->img)
    img = combine_path("/static/images/", params->args->img +".png");


  if(params->extras->obj && objectp(params->extras->obj))
  {
    image = combine_path("/space/" + params->extras->obj["path"], image);
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
