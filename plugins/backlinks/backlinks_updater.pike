import Tools.Logging;
import Fins;

inherit FinScribe.Plugin;

constant name = "Backlinks Updater";

int _enabled = 1;

int is_running = 0;
mapping backlink_mods = ([]);

mapping query_event_callers()
{
  return (["postSave": doUpdateBacklinks ]);
}

void start()
{
  Log.debug("starting backlinks updater...");

  app->call_out(app->create_thread, 0, update_backlinks);
}

int doUpdateBacklinks(string event, object id, object obj)
{
  process_object(obj);
}

void update_backlinks()
{
  Log.info("BackLink updater thread started.");

  if(is_running) return;

  is_running = 1;
  backlink_mods = ([]);

  array a = Fins.DataSource._default.find.objects(([]), Fins.Model.Criteria("ORDER BY ID DESC LIMIT 1"));

  if (!(a && arrayp(a) && sizeof(a)))
    return;

  int maxid = a[0]["id"];
  int cid = 0;

  
  //
  // ok, we get 100 at a time
  //

  do
  {
    array objs = Fins.DataSource._default.find.objects(
      (["id": Fins.Model.Criteria("id >= " + cid + " and id < " + (cid + 100)) ])
    );

    foreach(objs;; object o)
    {
	process_object(o);
    }

    cid = cid + 100;

  } while(cid < maxid);

  foreach(backlink_mods; string page; array backlinks)
  {
    array a = Fins.DataSource._default.find.objects(([ "path": page ]));

    if(!sizeof(a)) continue;
    else a[0]["md"]["backlinks"] = Array.uniq(backlinks);
//    Log.debug("%s: %O", a[0]["path"], a[0]["md"]["backlinks"]);
  }

  is_running = 0;
  call_out(Thread.Thread, 3600*24, update_backlinks);

}

mixed extract_href(object parser, mapping args, string content, mixed ... extra)
{
  if(args->href)
  {
    if(catch(Standards.URI(args->href)))
    {
      // we only extract local references.
      if(has_prefix(args->href, "/space/"))
      {
	if(extra[1]) // immediate mode?
        {
          string path = (args->href)[7..];
          object a;

          catch {
            a = Fins.DataSource._default.find.objects_by_alt( path );
            if(!a)
            {
              array x = a["md"]["backlinks"];
              x = Array.uniq(x);
              a["md"]["backlinks"] = x;
	      destruct(a);
            }
          };

        }
        else
        {
          if(backlink_mods[(args->href)[7..]])
           backlink_mods[(args->href)[7..]] += ({ extra[0]["path"] });
          else
           backlink_mods[(args->href)[7..]] = ({ extra[0]["path"] });
        }
      }
    }
  }
}

void process_object(object o, int|void immediate)
{
  mapping r = (["misc": ([]), "variables": ([]) ]);

  string html;

  catch(html = app->render(o["current_version"]["contents"], o, r));

  if(!html) Log.warn("Unable to render %O to html.", o["path"]);

  if(r["misc"]["object_is_weblog"] || r["misc"]["object_is_index"]) 
  {
    return;
  }

  // now, let's parse the html for hrefs.
  object parser = Parser.HTML();

  parser->add_container("a", extract_href);
  parser->set_extra(o, immediate);

  parser->finish(html);
  destruct(parser);
}
