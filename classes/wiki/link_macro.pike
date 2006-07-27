import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Handles internal/external links";
}

array evaluate(Macros.MacroParameters params)
{
  string link, name, img;
  array res = ({});

  if(!params->args) params->make_args();

  if(params->args->img) 
    img = params->args->img;

  array a = indices(params->args);

  // why, oh why do we do positional parameters???

  if(sizeof(params->args) > 1) 
  {
    link = a[-2];
    name = a[-1];
  }
  else
  {
    link = a[-1];
    name = a[-1];
  }

  res+=({"<a href=\""});
  res+=({link});

  	if(params->extras->request)
  	{
		if(!params->extras->request->misc->permalinks) params->extras->request->misc->permalinks = ({});
                if(search(link, "://") != -1)
		    params->extras->request->misc->permalinks += ({ link });
	}

  res+=({"\" "});
  if (!img)
    res += ({ "class=\"wiki_link_external\" " });
  res += ({ ">" });
  res+=({name});
  res+=({"</a>"});

  return res;
}
