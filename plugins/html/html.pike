inherit FinScribe.Plugin;
import Tools.Logging;

constant name = "HTML content type support";
constant typename = "HTML";

int _enabled = 1;

mapping macros = ([]);
object parser;

void start()
{
  Log.info("starting html rendering engine");

  parser = Parser.HTML();

  add_macro("code", ((program)"wiki/code_macro")());
}

mapping query_macro_callers()
{
  return ([]);
}

mapping query_type_callers()
{
  return (["text/html" : this]);
}


string get_widget(string contents)
{
     return "<script type=\"text/javascript\">dojo.require(\"fins.widget.*\"); dojo.require(\"fins.widget.RTEditor\"); </script> "
                        "<div style=\"background-color: #ffffff; height: 400px; width: 100%; border-width: 1px; border-style: dashed; border-color: #999999; overflow: auto\">"
                        "<textarea name=\"contents\" dojoType=\"fins:rteditor\">" + 
                        (contents||"Edit your document contents here.") + "</textarea></div>";

}

void add_macro(string n, object m)
{
  Log.debug("HTML Tag registration: %s", n);
  if(m->is_container)
    parser->add_container(n, lambda(object o, mapping args, string c, mixed ... a) { return render_container(n, o, args, c, @a); });
  else
    parser->add_tag(n, lambda(object o, mapping args, mixed ... e){ return render_tag(n, o, args, @e);});

  macros[n] = m;
}

mixed render_container(string name, object parser, mapping args, string 
contents, mixed extras, int force)
{
  object m = macros[name];
  if(!m) return 0;

  array a = ({});
  foreach(args; string k; string v)
    a += ({k+"="+v});

  object params = Public.Web.Wiki.Macros.MacroParameters();
  params->name = name;
  params->parameters = a*"|";
  params->contents = contents;
  params->extras = extras;
  
  array res = m->evaluate(params);

  return output(res, extras);

}

mixed render_tag(string name, object parser, mapping args, mixed extras, int force)
{
  object m = macros[name];
  if(!m) return 0;

  array a = ({});
  foreach(args; string k; string v)
    a += ({k+"="+v});
  object params = Public.Web.Wiki.Macros.MacroParameters();
  params->name = name;
  params->parameters = a*"|";
//  params->contents = contents;
  params->extras = extras;
  
  array res = m->evaluate(params);

  return output(res, extras);
}

string render(string s, mixed|void extras, int|void force)
{
  object my_parser = parser->clone(extras, force);

  return my_parser->finish(s)->read();
}

string output(array input, mixed|void extras)
{
  String.Buffer buf = String.Buffer();

  foreach(input;; mixed item)
  {
                if(arrayp(item))
                        buf->add(output(item, extras));
     else if(stringp(item))
                buf->add(item);
          else
                        foreach(item->render(this, extras);;mixed i)
                        {
//                              werror("%O\n", i);
                        if(stringp(i))
                                buf->add(i);
                        else if(arrayp(i))
                          buf->add(output(i, extras));
                        else if(objectp(i)) buf->add(output(i->render(this, extras), extras));
                        else error("invalid result.\n");
                }
  }

  return buf->get();
}
