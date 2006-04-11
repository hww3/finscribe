inherit Fins.FinsController;

void index(object id, object response, mixed ... args)
{
  object o = model->get_fbobject(args);
  if(!o)
  {
    response->not_found();
    return;
  }
  
  string dta, type;

  [dta, type] = _makethumb(o);
  response->set_type(type);
  response->set_data(dta);
}

mixed _makethumb(object file) {
  int thumbx,thumby;

  thumbx=120;
  thumby=120;

  string data = file["current_version"]["contents"];

  object img = Image.ANY.decode(data);
  int origx = img->xsize();
  int origy = img->ysize();

  object alpha;
  catch(alpha = Image.ANY.decode_alpha(data));

    if ((img->xsize() > thumbx) || (img->ysize() > thumby)) {
         img = rescale(img, thumbx, thumby); 
         alpha = rescale(alpha, thumbx, thumby);
    }

  if ((origx != img->xsize()) || (origy != img->ysize())) {
    string outtype, outdata;
    switch(file["datatype"]["mimetype"]) {
      case "image/jpeg":
	outtype = "image/jpeg";
	outdata = Image.JPEG.encode(img);
	break;
      case "image/png":
	outtype = "image/png";
	outdata = Image.PNG.encode(img, ([ "alpha" : alpha ]));
	break;
      case "image/gif":
	outtype = "image/gif";
	if (objectp(alpha))
	  outdata = Image.GIF.encode_trans(img, alpha);
	else
	  outdata = Image.GIF.encode(img);
	break;
    }
    return ({outdata, outtype});
  }
}

void|object rescale(object i, int x, int y) {
  if (!objectp(i))
    return 0;
  float ratio;
  if (i->xsize() == i->ysize()) {
    /* Orientation is square */
    i = i->scale(x, y);
  }
  else if (i->xsize() > i->ysize()) {
    /* Orientation is landscape */
    ratio = (float)x / (float)i->xsize();
    i = i->scale(x, (int)(ratio * i->ysize()));
  }
  else if (i->xsize() < i->ysize()) {
    /* Orientation is portrait */
    ratio = (float)y / (float)i->ysize();
    i = i->scale((int)(ratio * i->xsize()), y);
  }
  return i;
}
