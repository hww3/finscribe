public int trackback_ping(object obj, Standards.URI my_baseurl, string url)
{
	mapping r = ([]);
	
	r->title = obj["title"];
	r->excerpt = make_excerpt(obj["current_version"]["contents"]);

	my_baseurl->path = Stdio.append_path(my_baseurl->path, obj["path"]);
	
	r->url = (string)my_baseurl;
	r->blog_name = obj["parent"]["title"];

        string result;
        object q;
        int count = 0;


        result = post_url_data(url, r);

		werror("TRACKBACK PING RESULT: %O\n", result);
	if(!result || !sizeof(result))
        {
           werror("result from trackback ping returned empty!\n");
           return 1;
        }

   object n;
   if(catch(n = Public.Parser.XML2.parse_xml(result)))
   {
      werror("error parsing: " + result + "<<\n\n");
     return 1;
   }

	array na = Public.Parser.XML2.select_xpath_nodes("/response/error", n);
   if(!sizeof(na))
	{
     werror("invalid trackback ping result.\n");
		return 1;
	}
	else if(na[0]->get_text()!="0")
	{
		na = Public.Parser.XML2.select_xpath_nodes("/response/message", n);
		werror("trackback ping error: " + na[0]->get_text() + "\n");
		return 1;
	}
	
	return 0;
}

string make_excerpt(string c)
{
	if(sizeof(c)<500)
  	  return c;
   int loc = search(c, " ", 499);

	// we don't have a space?
   if(loc == -1)
	{
		c = c[0..499] + "...";
	}
	else
	{
		c = c[..loc] + "...";
	}
	
	return c;
}

//
// load a document by url and try to determine its trackback url.
// currently, this is done by searching all of the comment blocks within the
// loaded document, looking for a block of rdf embedded within the comment.
//
string detect_trackback_url(string url)
{
	string s = get_url_data(url);

   if(!s || !sizeof(s)) return 0;

	werror("TRACKBACK: got data: %O\n", s);
	
	object n = Public.Parser.XML2.parse_html(s);
	foreach(Public.Parser.XML2.select_xpath_nodes("//comment()", n) || ({});; object cmnt)
	{
		object r;
		array c;
		
		werror("Looking at a comment block...\n");
		if(catch(r = Public.Parser.XML2.parse_xml(cmnt->get_text())))
		  continue;
		werror("Parsed it: %O\n", r);
		c = Public.Parser.XML2.select_xpath_nodes("//*[local-name()=\"RDF\" and namespace-uri()=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"]/*[local-name()=\"Description\"]", r);
		foreach(c;; Public.Parser.XML2.Node rdf)
		{
			werror("Looking at a block that's RDF...\n");
			mapping m = rdf->get_attributes();
         werror("We're looking for %O, got %O\n", url, m->identifier);
			// we fudge it a little bit, as the libxml2 glue doesn't seem to be getting ns attributes properly.
			if(m->ping && m->identifier == url)
				return m->ping;
		}
	}
	
	return 0;
	
}

array limit(array a, int|void limit)
{
  if(!limit) limit = 10;

  int q = sizeof(a);

  if(q > limit)
    return a[..(limit-1)];
  else return a;

}

string get_url_data(string url)
{
	
	int count = 0;
	
	Protocols.HTTP.Query q;
	
	     object u = Standards.URI(url);
	do
        {
           u = Standards.URI(url, u);
          werror("TRACKBACK:  Getting " + (string)u);
          q = Protocols.HTTP.get_url(u);
        count++;
        }
        while(q->status == 302 && q->headers["location"] && (url = q->headers["location"]) && count < 10);

  return q->data();
   
}

string post_url_data(string url, mapping r)
{
	int count = 0;
	
	Protocols.HTTP.Query q;
	
	     object u = Standards.URI(url);
	do
        {
           u = Standards.URI(url, u);
          werror("TRACKBACK: Posting to " + (string)u);
          q = Protocols.HTTP.post_url(u, r);
        count++;
        }
        while(q->status == 302 && q->headers["location"] && (url = q->headers["location"]) && count < 10);

  return q->data();
   
}


int weblogs_ping(string site, string url)
{
	string endpoint = "http://rpc.weblogs.com/RPC2";
	string method = "weblogUpdates.ping";
	object c;
	mapping x;
	
	catch{
	  c = Protocols.XMLRPC.Client(endpoint);
	  x = c[method](site, url)[0];
   };

  if(x && x->message)
  {
	  werror("WEBLOG PING: %O\n", x->message);
  }

  return (x && x->flerror)||0;

}