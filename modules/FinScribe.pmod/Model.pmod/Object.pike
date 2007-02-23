import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static mapping metadata = ([]);

   static void define()
   {  
      set_table_name("objects");
      set_instance_name("object");
      add_field(PrimaryKeyField("id"));
      add_field(KeyReference("author", "author_id", "user"));
      add_field(KeyReference("datatype", "datatype_id", "datatype"));
      add_field(KeyReference("acl", "acl_id", "acl"));
      add_field(KeyReference("parent", "parent_id", "object", UNDEFINED, 1));
      add_field(StringField("path", 128, 0));
      // 0 = not attachment
      // 1 = is attachment
      // 2 = blog entry
      // 3 = wip blog entry
      add_field(IntField("is_attachment", 0, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(TransformField("title", "path", get_title));
      add_field(TransformField("tinylink", "id", get_tinylink));
      add_field(TransformField("link", "id", get_link));
      add_field(TransformField("outlinks", "current_version", get_outlinks));
      add_field(TransformField("inlinks", "md", get_inlinks));
      add_field(TransformField("icon", "datatype", get_icon));
      add_field(TransformField("category_links", "categories", get_cat_links));
      add_field(TransformField("outlinks_links", "outlinks", get_out_links));
      add_field(TransformField("inlinks_links", "inlinks", get_out_links));
      add_field(TransformField("nice_created", "created", format_created));
      add_field(CacheField("current_version", "current_version_uncached", context));
      add_field(BinaryStringField("metadata", 1024, 0, ""));
      add_field(TransformField("md", "metadata", get_md));
      add_field(InverseForeignKeyReference("current_version_uncached", "object_version", "object", Model.Criteria("ORDER BY version DESC LIMIT 1"), 1));
      add_field(InverseForeignKeyReference("versions", "object_version", "object"));
      add_field(InverseForeignKeyReference("comments", "comment", "object"));
      add_field(InverseForeignKeyReference("children", "object", "parent"));
      add_field(TransformField("attachments", "id", get_attachments));
      add_field(MultiKeyReference(this, "categories", "objects_categories", "object_id", "category_id", "category", "id"));
      set_primary_key("id");

      set_alternate_key("path");
      add_default_value_object("acl", "acl", (["Name": "Default ACL"]), 1);
   }

   static object created()
   {
     return Calendar.Second();
   }

   object get_md(mixed md, object i)
   {
     if(!metadata[i->get_id()] || !metadata[i->get_id()][1])
     {
       object md = MetaData(md, i);
       metadata[i->get_id()][1] = md;
       return md;
     }
     else return metadata[i->get_id()][1];
   }

   static mixed get_attachments(mixed n, object i)
   {
     return find((["parent": n, "is_attachment": 1]), UNDEFINED, i);
   }

   static string get_icon(mixed n, object i)
   {
     string mt = n["mimetype"];

     switch(mt)
     {
       case "text/xml":
         return "xml.gif";
       case "text/html":
         return "html.gif";
       case "application/pdf":
         return "pdf.gif";
       case "application/msword":
         return "word.gif";
       case "application/vnd.ms-powerpoint":
         return "powerpoint.gif";
       case "application/vnd.ms-excel":
         return "excel.gif";
     }

     switch((mt/"/")[0])
     {
       case "text":
        return "text.gif";
       case "image":
        return "image.gif";
     }

     return "file.gif";
   }

   array get_inlinks(mixed n, object i)
   {
     array x;
     x = n["backlinks"];
     if(!x) x = ({});
     string au = context->app->url_for_action(context->app->controller->space);
     foreach(x; int i; mixed v) x[i] = combine_path(au, v);
     return x;
   }

   array get_outlinks(mixed n, object i)
   {
      string c = context->app->render(i["current_version"]["contents"], i);
      array ol = ({});
      object p = Parser.HTML();
      p->add_container("a", lambda(object o, mapping a, string 
c){a->href[0]=='/'?(ol+=({a->href})):(ol = ({a->href}) + ol);});
      p->finish(c); 
      return ol;
   }

   string get_title(mixed n, object i)
   {
     string a;
     catch {
        a = i["current_version"]["subject"];
     };
     if(a && sizeof(a)) return a;
     else return (n/"/")[-1];
   }

   string get_link(mixed n, object i)
   {
     string a;
     a = combine_path(context->app->context_root,
context->app->url_for_action(context->app->controller->space), 
i["path"]);
   return a;

   }

   string get_tinylink(mixed n, object i)
   {
     string a;
     a = combine_path(context->app->context_root,
context->app->url_for_action(context->app->controller->exec->x), 
MIME.encode_base64((string)n));     

     object u = Standards.URI(context->app->get_sys_pref("site.url")["Value"]);
     u->path = a;
     return (string)u;
   }

   array get_cat_links(mixed n, object i)
   {
     return map(Array.uniq(i["categories"]["category"]), lambda(string a){return "<a href=\"/exec/category/" + a + "\">"+ a + "</a>";});
   }

   array get_out_links(mixed n, object i)
   {
     return map(Array.uniq(n), make_outlink);
   }

   string make_outlink(string l)
   {
     string au = context->app->url_for_action(context->app->controller->space);
     if(au[-1] != '/') au+="/";
     if(has_prefix(l, au))
     {
       object o;
       array ar;
       ar = context->app->model->find("object", (["path": l[sizeof(au)..] ]));

       if(sizeof(ar))
       {
         o = ar[0];
         return "<img src=\"/static/images/attachment/" + o["icon"] + "\"> <a href=\"" + au + o["path"] + "\">" + o["title"] + "</a>";
       }
       else
       {
         return l[sizeof(au)..] + " (broken)";
       }
     }
     else if(l[0] == '/')
     {
       return "<img src=\"/static/images/Icon-Extlink.png\"> <a href=\"" + l + "\">"+ l + "</a>";
     }
     else
     {
        return "<img src=\"/static/images/Icon-Extlink.png\"> <a href=\"" + l + "\">" + l + "</a>";
     }
   }

   string format_created(object c, object i)
   {
     return c->format_ext_ymd();
   }

   class MetaData
   {
     mapping metadata = ([]);
     object obj;

     static int(0..1) _is_type(string tn)
     {
        if(tn =="mapping")
          return 1;
        else 
          return 0;
     }

     static void create(mixed data, object i)
     {
       obj = i;

       if(data && strlen(data))
       {
         catch {
           metadata = decode_value(MIME.decode_base64(data));
         };
       }
     }

    Iterator _get_iterator()
    {
      return Mapping.Iterator(metadata);
    }


     array _indices()
     {
       return indices(metadata);
     }

     array _values()
     {
       return values(metadata);
     }

     mixed _m_delete(mixed arg)
     {
       if(!metadata[arg] && !zero_type(metadata[arg]))
       {
         m_delete(arg, metadata);
         save();
       }
     }
  

     mixed `[](mixed a)
     {
       return `->(a);
     }

     mixed `[]=(mixed a, mixed b)
     {
       return `->=(a,b);
     }

     mixed `->(mixed a)
     {
       if(a == "dump")
         return dump;
       if(a == "save")
         return save;

       if(metadata)
         return metadata[a];
       else return 0;
     }

     mixed `->=(mixed a, mixed b)
     {
       metadata[a] = b;
       save();
     }

   int save()
   {
      obj["metadata"] = dump(); 
      return 1;
   }


   string dump()
   {
     return MIME.encode_base64(encode_value(metadata));
   }

 }

  void add_ref(Fins.Model.DataObjectInstance o)
  {
    ::add_ref(o);
    // FIXME: we shouldn't have to do this in more than one location!
    if(!metadata[o->get_id()])
    {
      metadata[o->get_id()] = ({0, 0});
    }

    metadata[o->get_id()][0]++;

}

  void sub_ref(Fins.Model.DataObjectInstance o)
  {
    if(!o->is_initialized()) return;

    if(!metadata[o->get_id()]) return;

    metadata[o->get_id()][0]--;

    if(metadata[o->get_id()][0] == 0)
    {
      m_delete(metadata, o->get_id());
    }

    ::sub_ref(o);
  }



