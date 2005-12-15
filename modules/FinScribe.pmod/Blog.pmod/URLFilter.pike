import Public.Web.Wiki;
inherit Public.Web.Wiki.Filters.RegexFilter;

  public void filter(String.Buffer buf, string match, array|void components, RenderEngine engine, mixed|void context)
  {
     if(!dest)
       dest = predef::replace(extra->print, "\\n", "\n");

       if(components){
                        array replacements = ({"$0"});
         for(int i=1; i<=sizeof(components); i++)
            replacements+=({"$"+i});
         buf->add(predef::replace(dest ,replacements, ({match})+components));
			if(!context->request->misc->permalinks)
				context->request->misc->permalinks = ({});
			context->request->misc->permalinks += ({components[1]});

      }
      else
         buf->add(dest);
         
  }
