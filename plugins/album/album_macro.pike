import Tools.Logging;
import Fins;

inherit FinScribe.Plugin;

constant name="Album";

int _enabled = 1;

mapping(string:mixed) query_ipath_callers()
{
  return([ "getthumb": ((program)"thumbnail_controller")(app) ]);
}

mapping(string:object) query_macro_callers()
{
  return ([ "album": album_macro() ]);
}

class album_macro
{

inherit Public.Web.Wiki.Macros.Macro;

string describe()
{
   return "Displays all attachments of a page as an album";
}

array evaluate(Public.Web.Wiki.Macros.MacroParameters params)
{
  string doc;
  int limit;
  int hidetitle;

  array res = ({ });
  
  object obj;
  if(params->extras->request)
    obj = params->extras->request->misc->current_page_object || 0;

  if(!obj) return ({});



  foreach(obj->get_attachments();;object o)
  {
     object u = Standards.URI(app->get_sys_pref("site.url")->get_value());
            u->path = combine_path(u->path, "/space/", o["path"]);
werror("rendering for " + o["path"] + "\n");
    int is_image = 0;

    if(has_prefix(o["datatype"]["mimetype"], "image/"))
      is_image = 1;
    
    res += ({
"<div class='block-cell'><div class='fullslide' style='width: 160px;'>"

"<div class='outer' style='width: 140px; height: 140px;'>"
"<span></span>"
"<a" + (is_image?(" rel=\"lightbox\" title=\"" + 
                 o["title"]+ "\""):"") + " href=\"" + 
                 (string)u + "\">"+ make_thumb(o, is_image) + "</a>"
"</div>"

"<div>" + o["title"] + "</div>"
"</div>"
});
  }
  return ({"<p><div class=\"album-display\">"}) + res + ({"</div><p>"
           "<script type=\"text/javascript\" src=\"/static/javascripts/lightbox.js\"></script>"});

}

string make_thumb(object o, int is_image)
{
  if(!is_image)
    return o["title"];

  string retval="";

  retval="<img src=\"/_internal/getthumb/" + o["path"] + "\">";

  return retval;
}


}
