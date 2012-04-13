inherit FinScribe.Plugin;
import Tools.Logging;

constant name = "HTML content type support";
constant typename = "HTML";

int _enabled = 1;

mapping macros = ([]);
object wiki; // the app
object parser;

void start()
{
  Log.info("starting html rendering engine");

  parser = Parser.HTML();

  call_out(register_macros, 0);
  wiki = app;
}

void register_macros()
{
  add_macro("code", ((program)"wiki/code_macro")());
  foreach(app->render_macros + app->engines["text/wiki"]->macros;string macro_name; object 
macro_object)
    add_macro(macro_name, macro_object);
}

mapping query_macro_callers()
{
  return ([]);
}

mapping query_type_callers()
{
  return (["text/html" : this]);
}


void add_to_list(object view, string list, string value)
{
    mixed d = view->get_data();
    if(!d[list]) d[list] = ({});
    d[list] += ({ value });
}

string get_widget(object view, string contents)
{

    add_to_list(view, "jsfooter", "dojo.require('dijit.Editor');");
    add_to_list(view, "jsfooter", "dojo.require('dijit._editor.plugins.ViewSource');");
	add_to_list(view, "jsfooter", "dojo.connect(dojo.byId('editform'), 'onsubmit', function(){dojo.byId('contents').value =dijit.byId('htmleditor').get('value');});");
     return 
//                        "< style=\"background-color: #ffffff; height: 400px; width: 100%; border-width: 1px; border-style: dashed; border-color: #999999\">"
        "<input id=\"contents\" type=\"hidden\" name=\"contents\">"
		"<div data-dojo-type=\"dijit.Editor\" data-dojo-props=\"extraPlugins:[{name: 'dijit._editor.plugins.ViewSource', command:'viewsource'}]\" id=\"htmleditor\">" + 
                        (contents||"Edit your document contents here.") + "</div>";

}

void add_macro(string n, object m)
{
  Log.info("HTML Tag registration: %s", n);
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
  params->engine = this;  
  
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
  params->engine = this;  
  array res = m->evaluate(params);

  return output(res, extras);
}

string render(string s, mixed|void extras, int|void force)
{
werror("Render: %O\n", extras);
  object my_parser = parser->clone();
   my_parser->set_extra(extras, force);

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
