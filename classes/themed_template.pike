import Fins;
import Fins.Template;

mapping themes = ([]);
mapping scripts = ([]);

inherit Fins.Template.Simple;

class compilecontext(string theme)
{

}


static void create(string _templatename, TemplateContext|void 
context_obj)
{
   context = context_obj;

   context->type = object_program(this);

   auto_reload = (int)(context->application->config["view"]["reload"]);
   templatename = _templatename + ".phtml";

//   reload_template();
}

static void reload_template(string theme)
{
   last_update = time();
   object ctx = compilecontext(theme);

   string template = load_template(templatename, ctx);
   string psp = parse_psp(template, theme + "/" + templatename, ctx);
   scripts[theme] = psp;

   mixed x = gauge{
     themes[theme] = compile_string(template, theme + "/" + templatename, ctx);
   };

}

static int template_updated(string templatename, int last_update, string theme)
{
  array paths = ({});

   if(theme && theme != "default")
     paths += ({combine_path(context->application->config->app_dir,
         "themes/" + theme + "/" + templatename ) });

   // the last resort is to check the default template path.
   paths += ({combine_path(context->application->config->app_dir,
                                       "templates/" + templatename)});

   foreach(paths;;string tn)
   {
     object s = file_stat(tn);

     if(s && s->mtime > last_update)
       return 1;
   }

   return 0;
}

//!
public string render(TemplateData d)
{
   String.Buffer buf = String.Buffer();

   string theme;

   theme = context->application->get_theme(d->id);
   if(!themes[theme])
   {
     reload_template(theme);
   }

   if(auto_reload && template_updated(templatename, last_update, theme))
   {
       reload_template(theme);
   }

    object t = themes[theme](context);
    t->render(buf, d);
   return buf->get();

}

//! we should really do more here...
static string load_template(string templatename, object|void compilecontext)
{
   string template;

   array paths = ({});
   if(compilecontext && compilecontext->theme != "default")
     paths += ({combine_path(context->application->config->app_dir, 
         "themes/" + compilecontext->theme + "/" + templatename ) });

   // the last resort is to check the default template path.
   paths += ({combine_path(context->application->config->app_dir,
                                       "templates/" + templatename)});


   foreach(paths;;string tn)  
   {
     template = Stdio.read_file(tn);
     if(template) break;

   }
   if(!template || !sizeof(template))
   {
     throw(Error.Generic("Template " + templatename + " is empty.\n"));
   }
   return template;
}

