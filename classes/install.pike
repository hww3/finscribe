inherit Fins.FinsBase;

int run()
{
 
  // then, we create the datatypes
  cd("templates");
  foreach(Stdio.read_file("datatypes.conf")/"\n", string dt)
  {
    object d;
    dt = String.trim_whites(dt);
    d = model()->find("datatype", (["mimetype": dt]));
    if(d && sizeof(d)
       continue;
    else
      d = model()->new("datatype");
    d["mimetype"] = dt;
    d->save();
  }

  // then we load up the templates
  foreach(glob("*.tpl", get_dir(".")), string fn)
  {
    model()->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/template", 1);
  }

  foreach(glob("*.wiki", get_dir(".")), string fn)
  {
    model()->new_from_string(combine_path("themes/default/", fn[..sizeof(fn)-6]), 
              Stdio.read_file(fn), "text/wiki");
  }

  foreach(glob("*.css", get_dir(".")), string fn)
  {
ˆ    model()->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/css", 1);
  }

  foreach(glob("*.js", get_dir(".")), string fn)
  {
    model()->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "application/javascript", 1);
  }

  // then we load up the start object.

   model()->new_from_string("start", "1 Welcome to FinBlog.\n\nTo get started, log in and click the edit button.", "text/wiki", 0, 1);
   model()->new_from_string("object-index", "{object-index}\n\nView [attachment-index]\n", "text/wiki", 0, 1);
   model()->new_from_string("attachment-index", "{attachment-index}", "text/wiki", 0, 1);


}

