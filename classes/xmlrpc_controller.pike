import Fins;
inherit Fins.FinsController;

public void metaweblog(Request id, Response response, mixed ... args)
{
  	mapping m;
	int off = search(id->raw, "\r\n\r\n");

	if(off<=0) error("invalid request format.\n");
	werror("%O", id->raw[(off+4) ..]);

	object X;

	if(catch(X=Protocols.XMLRPC.decode_call(id->raw[(off+4) ..])))
	{
	 	error("Error decoding the XMLRPC Call. Are you not speaking XMLRPC?\n");  
 	}
	mixed resp = ({});
   mixed err = catch {
   switch(X->method_name)
   {
		case "metaWeblog.getCategories":
			resp = get_categories(X, id);
	}
	
	};
	
	 if(err)
	{
		werror("sending error\n");
       response->set_data(Protocols.XMLRPC.encode_response_fault(1, err[0]));
   }
  else
       	{
	werror("sending response : %O\n", Protocols.XMLRPC.encode_response(({resp})));
				response->set_data(Protocols.XMLRPC.encode_response(({resp})));
		}
		response->set_type("text/xml");

   return;
}


private array get_categories(object call, Request id)
{
array u = ({});	
	werror("get_categories: %O", call->params);
//   array u = model()->find("user", (["UserName": call->params[1], "Password": call->params[2], "is_active": 1]));
   if(!sizeof(u))
	{
//		throw("Login incorrect.\n");
	}
	
	array r = model()->get_categories();
	array cats = ({});
	
	foreach(r;; mixed cat)
	{
		cats+= ({(["categoryId": cat["id"], "categoryName": cat["category"], "description": cat["category"], "htmlUrl": "/exec/category/" + cat["category"], "rssUrl": "foo"])});
	}
	
	return cats;
}