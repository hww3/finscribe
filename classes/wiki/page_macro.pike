import Public.Web.Wiki;

inherit Macros.Macro;
constant is_container = 1;

string describe()
{
   return "inserts a link to a wiki page.";
}

array evaluate(Macros.MacroParameters params)
{
    string linkspec = "/";
  if(!params->args) params->make_args();
  mapping args = params->args;
  array res = ({});
//werror("%O\n", params->extras);
  object id = params->extras->request;

    if(args->linkspec)
    {
       linkspec = args->linkspec;
    }

  if(params->contents)
  {
	 array res = ({});
    string name, view, anchor;
    array c = params->contents / "#";

    if(sizeof(c) > 2) 
      error("invalid link format. too many anchors!\n");
    else if(sizeof(c) ==2)
      anchor = c[1];

    name = c[0];


    view = (name/linkspec)[-1];    

	 object buf = String.Buffer();

    if(params->engine->exists(name))
    {
       if(anchor)
         params->engine->appendLink(buf, name, view, anchor);
       else
        params->engine->appendLink(buf, name, view);
    }
    else
    {
      if(params->engine->showCreate())
      {
        params->engine->appendCreateLink(buf, name, view);
      }
      else
      {
        return({params->contents});
      }
    }
	return ({buf->get()});
}

return res;
}

