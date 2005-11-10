inherit Fins.FinsBase;

int run()
{
 
  // then, we create the datatypes
  cd("templates");
  foreach(Stdio.read_file("datatypes.conf")/"\n", string dt)
  {
    object d = Fins.model()->new("datatype");
    d["mimetype"] = String.trim_whites(dt);
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
    model()->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/css", 1);
  }

  foreach(glob("*.js", get_dir(".")), string fn)
  {
    model()->new_from_string(combine_path("themes/default/", fn), 
              Stdio.read_file(fn), "text/javascript", 1);
  }

  // then we load up the start object.

}

