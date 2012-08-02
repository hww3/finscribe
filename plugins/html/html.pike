inherit FinScribe.Plugin;

constant name = "HTML content type support";
constant type = "html";
int _enabled = 1;
constant startup_priority = 250;

// distinct from "type" identifier above, used for content type rendering.
constant typename = "HTML";

mapping macros = ([]);
object wiki; // the app
object parser;

void start()
{
  logger->info("starting html rendering engine");

  parser = Parser.HTML();

  call_out(register_macros, 0);
  wiki = app;
}

void register_macros()
{
//  add_macro("code", ((program)"wiki/code_macro")());

  mapping macros = app->render_macros;
  if(app->engines["text/wiki"]) macros += app->engines["text/wiki"]->macros;
  foreach(macros; string macro_name; object macro_object)
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

int exists(string _file)
{
  array res;

  if(wiki->cache->get("PATHdata_" + _file)) return 1;

  res = Fins.DataSource._default.find.objects((["path": _file]));

  if(!sizeof(res)) return 0;
  else
  {
    wiki->cache->set("PATHdata_" + _file, 1, 1200);
    return 1;
  }
}


void appendLink(String.Buffer buf, string name, string view, string|void anchor)
{
  //werror("appendLink: %O %O %O\n", name, view, anchor);
  buf->add("<a href=\"/space/");
  buf->add(name + (anchor?("#" + anchor):""));
  buf->add("\">");
  buf->add(wiki->model->get_object_name(view));
  buf->add("</a>");
}
 
void appendCreateLink(String.Buffer buf, string name, string view)
{
  //werror("appendCreateLink: %O %O\n", name, view); 
  buf->add("&#");
  buf->add((string)'[');
  buf->add("; create <a href=\"/exec/edit/");
  buf->add(name);
  buf->add("\">");
  buf->add(view);
  buf->add("</a>]");
}
   
string make_key(string s, string fn)
{
  if(String.width(s) != 8)
    s = string_to_utf8(s);
  string h = MIME.encode_base64(Crypto.MD5.hash(s));

  return "HTMLCOMPILER_" + fn + "_" + h;
}

void add_to_list(object view, string list, string value)
{
    mixed d = view->get_data();
    if(!d[list]) d[list] = ({});
    d[list] += ({ value });
}

string get_widget(object view, string contents)
{
//    add_to_list(view, "jsfooter", "dojo.require('dojox.editor.plugins.PasteFromWord');");
    add_to_list(view, "jsfooter", "dojo.require('dojox.editor.plugins.SafePaste');");
    add_to_list(view, "jsfooter", "dojo.require('dojox.editor.plugins.PrettyPrint');");
    add_to_list(view, "jsfooter", "dojo.require('dojox.editor.plugins.NormalizeStyle');");
    add_to_list(view, "jsfooter", "dojo.require('dijit._editor.plugins.ViewSource');");
    add_to_list(view, "jsfooter", "dojo.require('dijit._editor.plugins.FontChoice');");
    add_to_list(view, "jsfooter", 
#"//load editor and ensure that the contents are submitted when appropriate.\nrequire([\"dijit/Editor\"], function(editor){
        	dojo.connect(dojo.byId('editform'), 
		'onsubmit', function(){dojo.byId('contents').value =dijit.byId('htmleditor').get('value');});

});
"
	);

     return 
	"<link rel=\"stylesheet\" type=\"text/css\" href=\"http://ajax.googleapis.com/ajax/libs/dojo/1.7.2/dojox/editor/plugins/resources/css/PasteFromWord.css\">"
//                        "< style=\"background-color: #ffffff; height: 400px; width: 100%; border-width: 1px; border-style: dashed; border-color: #999999\">"
        "<input id=\"contents\" type=\"hidden\" name=\"contents\">"
#"<div data-dojo-type=\"dijit.Editor\" data-dojo-props=\"
extraPlugins:[
'normalizestyle', 'prettyprint', 'safepaste', 'formatBlock', 'removeFormat',
{name: 'dijit._editor.plugins.ViewSource', command: 'viewsource'
}]
\" id=\"htmleditor\">" 
  + (contents||"Edit your document contents here.") + "</div>";

}

void add_macro(string n, object m)
{
  logger->info("HTML Tag registration: %s", n);
  if(m->is_container)
    parser->add_container(n, lambda(object o, mapping args, string c, mixed ... a) { return render_container(n, o, args, c, @a); });
  else
    parser->add_tag(n, lambda(object o, mapping args, mixed ... e){ return render_tag(n, o, args, @e);});

  macros[n] = m;
}

mixed render_container(string name, object parser, mapping args, string 
contents, mixed extras, int force)
{
  // we don't want to parse macros that happen to have the same name as an html tag.
  if(name == "table") return ({contents}); 
  // ... or things that have been parsed already.
  if(args->_parsed) return 0;

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
  if(args->_parsed) return 0;
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
  object my_parser = parser->clone();
   my_parser->set_extra(extras, force);

  string res = my_parser->finish(s)->read();

  destruct(my_parser);
  return res;
}

string output(array input, mixed|void extras)
{
  String.Buffer buf = String.Buffer();

  foreach(input;; mixed item)
  {
    if(arrayp(item))
      buf->add(output(item, extras));
    else if(stringp(item))
//werror("%O\n",item);
      buf->add(item);
    else
      foreach(item->render(this, extras);;mixed i)
      {
//                              werror("%O\n", i);
        if(stringp(i))
          buf->add(i);
        else if(arrayp(i))
          buf->add(output(i, extras));
        else if(objectp(i)) 
          buf->add(output(i->render(this, extras), extras));
        else error("invalid result.\n");
      }
  }

  string r = buf->get();
  destruct(buf);
  return r;
}
