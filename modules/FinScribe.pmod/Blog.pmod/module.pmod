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