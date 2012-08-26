import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Handles images";
}

// {image:path} <== an image based on its path
// {image:src=path} <== an image based on its path
// {image:img=staticimg} <== an image located in the /static/images folder, without png extenstion
//
// {image:src=path|link=url|alt=altdesc|align=aligndir}
//
// note: path is described based on the current object's path:
// if current object is my/doc, and the image path is somepic.jpg,
// the image path would be my/doc/somepic.jpg.
//
// in other words, the macro is designed to include images that are attachments
// of the current object.
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
  else if(params->args->img)
    image = combine_path("/static/images/", params->args->img +".png");
  else return ({"INVALID IMAGE SRC"});

  if(params->args->link)
    link = params->args->link;
  if(params->args->alt)
    alt = params->args->alt;
  if(params->args->align)
    align = params->args->align;


  if(params->extras->obj && objectp(params->extras->obj) && !params->args->img)
  {
    if(image[0] == '/')
      image = params->engine->wiki->url_for_action(params->engine->wiki->controller->space, ({image}));
    else
      image = params->engine->wiki->url_for_action(params->engine->wiki->controller->space, ({params->extras->obj["path"], image}));
//combine_path("/space/" + params->extras->obj["path"], image);
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
