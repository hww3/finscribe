import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Handles internal/external links";
}

array evaluate(Macros.MacroParameters params)
{
  if(!sizeof(params->parameters))
  {
    return ({"INVALID LINK"});
  }

  string link, name, img;
  array res = ({});
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
        return ({"INVALID LINK PARAMETER: " + elem});
     }
     else
     {
        array b = elem/"=";

        switch(b[0])
        {
           case "img":
             img = b[1];
             break;
            default:
             link = elem;
             break;
        }
     }
  }

  if(!img)
  {  
     res+=({"<img height=\"9\" width=\"8\" src=\""});
     res+=({"/static/images/Icon-Extlink.png\" alt=\"&#91;external]\"/>"});
  }
 res+=({"<a href=\""});
  res+=({link});

  	if(params->extras->request)
  	{
		if(!params->extras->request->misc->permalinks) params->extras->request->misc->permalinks = ({});
                if(search(link, "://") != -1)
		    params->extras->request->misc->permalinks += ({ link 
});
	}

  res+=({"\">"});
  res+=({name});
  res+=({"</a>"});

  return res;
}
