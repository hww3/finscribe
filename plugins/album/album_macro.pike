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

int is_cacheable()
{
  return 0;
}

string describe()
{
   return "Displays all attachments of a page as an album";
}

array evaluate(Public.Web.Wiki.Macros.MacroParameters params)
{
  array res = ({ });
  
  object obj;
  if(params->extras->request)
    obj = params->extras->request->misc->current_page_object || 0;

  if(!obj) return ({});

  array r2 = ({});

  foreach(obj->get_attachments();;object o)
  {
     object u = Standards.URI(app->get_sys_pref("site.url")->get_value());
            u->path = combine_path(u->path, "/space/", o["path"]);
    int is_image = 0;

    if(has_prefix(o["datatype"]["mimetype"], "image/"))
      is_image = 1;
    
    r2 += ({
"<div class='fullslide' style='width: 160px;'>"
"<div class='outer' style='width: 140px; height: 140px;'>"
"<a" + (is_image?(" rel=\"lightbox\" title=\"" + 
                 o["title"]+ "\""):"") + " href=\"" + 
                 (string)u + "\">"+ make_thumb(o, is_image) + "</a>"
"<div>" + o["title"] + "</div>"
"</div>"
"</div>\n\n"
});

  }

  foreach(r2/5.0;;array x)
  {
    string z = "";
    z+= "<tr>";

    foreach(x;;string y)
     z+= "<td>" + y + "</td>";

    z+= "</tr>";
    

    res += ({ z });
  }

  return ({"<link rel=\"STYLESHEET\" type=\"text/css\" href=\"/_internal/static/Album/style.css\"/>"
  "<link rel=\"STYLESHEET\" type=\"text/css\" href=\"/_internal/static/Album/lightbox.css\"/>"
  "<p><div class=\"album-display\"><table>"}) + res + 
({"</table></div><p>"
           "<script type=\"text/javascript\" src=\"/_internal/static/Album/lightbox.js\"></script>"});

}

string make_thumb(object o, int is_image)
{
  if(!is_image)
    return o["title"];

  string retval="";

  retval="<img alt=\"" + o["title"] + "\" src=\"/_internal/getthumb/" + o["path"] + "\">";

  return retval;
}


}
