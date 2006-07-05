import Public.Web.Wiki;
inherit Public.Web.Wiki.Filters.RegexFilter;

public array filter(string match, array|void components, RenderEngine engine, mixed|void context)
{
  array res = ({});

  if(!dest)
    dest = predef::replace(extra->print, "\\n", "\n");

  if(components){
    array replacements = ({"$0"});
    for(int i=1; i<=sizeof(components); i++)
      replacements+=({"$"+i});
    res+=({predef::replace(dest ,replacements, ({match})+components) });
    if(context->request && !context->request->misc->permalinks)
      context->request->misc->permalinks = ({});
    if(context->request && context->request->misc)
      context->request->misc->permalinks += ({components[1]});

  }
  else
    res+=({dest});

  return res;
}
