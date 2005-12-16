public int trackback_ping(object obj, Standards.URI my_baseurl, string url)
{
	mapping r = ([]);
	
	r->title = obj["title"];
	r->excerpt = make_excerpt(obj["current_version"]["contents"]);

	my_baseurl->path = Stdio.append_path(my_baseurl->path, obj["path"]);
	
	r->url = (string)my_baseurl;
	r->blog_name = obj["parent"]["title"];

	string result = Protocols.HTTP.post_url_data(url, r);


   object n = Public.Parser.XML2.parse_xml(result);

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
	if(sizeof(c)<100)
  	  return c;
   int loc = search(" ", c, 100);

	// we don't have a space?
   if(loc == -1)
	{
		c = c[0..100] + "...";
	}
	else
	{
		c = c[0..loc] + "...";
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
	string s = Protocols.HTTP.get_url_data(url);
	object n = Public.Parser.XML2.parse_html(s);
	
	foreach(Public.Parser.XML2.select_xpath_nodes("//comment()", n);; object cmnt)
	{
		object r;
		array c;
		
		if(catch(r = Public.Parser.XML2.parse_xml(cmnt->get_text())))
		  continue;
		c = Public.Parser.XML2.select_xpath_nodes("//*[local-name()=\"RDF\" and namespace-uri()=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"]/*[local-name()=\"Description\"]", r);
		if(sizeof(c))
		{
			mapping m = c[0]->get_attributes();
			// we fudge it a little bit, as the libxml2 glue doesn't seem to be getting ns attributes properly.
			if(m->ping)
				return m->ping;
		}
	}
	
}

array limit(array a, int|void limit)
{
  if(!limit) limit = 10;

  int q = sizeof(a);

  if(q > limit)
    return a[..(limit-1)];
  else return a;

}
