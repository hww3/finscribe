import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static mapping metadata = ([]);

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("comments");
      set_instance_name("comment");
      add_field(PrimaryKeyField("id"));
      add_field(KeyReference("object", "object_id", "object"));
      add_field(KeyReference("author", "author_id", "user"));
      add_field(StringField("contents", 1024, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(StringField("metadata", 1024, 0, "")); 
      add_field(TransformField("md", "metadata", get_md));
      add_field(TransformField("nice_created", "created", format_created));
      add_field(TransformField("wiki_contents", "contents", c->app->render_wiki));
      set_primary_key("id");
   }
   
   static string format_created(object c, object i)
   {
      string howlongago;

      c = c->distance(Calendar.now());

      if(c->number_of_minutes() < 3)
      {
         howlongago = "Just a moment ago";
      }
      else if(c->number_of_minutes() < 60)
      {
         howlongago = c->number_of_minutes() + " minutes ago";
      }
      else if(c->number_of_hours() < 24)
      {
         howlongago = c->number_of_hours() + " hours ago";
      }
      else
      {
         howlongago = c->number_of_days() + " days ago";
      }

      return howlongago;    
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
