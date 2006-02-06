import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static mapping metadata = ([]);

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("objects");
      set_instance_name("object");
      add_field(PrimaryKeyField("id"));
      add_field(KeyReference("author", "author_id", "user"));
      add_field(KeyReference("datatype", "datatype_id", "datatype"));
      add_field(KeyReference("parent", "parent_id", "object", UNDEFINED, 1));
      add_field(StringField("path", 128, 0));
      add_field(IntField("is_attachment", 0, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(TransformField("title", "path", get_title));
      add_field(TransformField("nice_created", "created", format_created));
      add_field(CacheField("current_version", "current_version_uncached", c));
      add_field(BinaryStringField("metadata", 1024, 0, ""));
      add_field(TransformField("md", "metadata", get_md));
      add_field(InverseForeignKeyReference("current_version_uncached", "object_version", "object", Model.Criteria("ORDER BY version DESC LIMIT 1"), 1));
      add_field(InverseForeignKeyReference("comments", "comment", "object"));
      add_field(MultiKeyReference(this, "categories", "objects_categories", "object_id", "category_id", "category", "id"));
      set_primary_key("id");
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

   string get_title(mixed n, object i)
   {
     string a = i["current_version"]["subject"];
     if(a && sizeof(a)) return a;
     else return (n/"/")[-1];
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



