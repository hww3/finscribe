import Tools.Logging;
import Fins;

inherit FinScribe.Plugin;

constant name = "Backlinks Updater";

int _enabled = 1;

int is_running = 0;
mapping backlink_mods = ([]);

void start()
{
  Log.info("starting backlinks updater...");

  call_out(Thread.Thread, 0, update_backlinks);
}


void update_backlinks()
{
  Log.info("backlink updater thread started.");

  if(is_running) return;

  is_running = 1;
  backlink_mods = ([]);

  array a = app->model->find("object", ([]), Fins.Model.Criteria("ORDER BY ID DESC LIMIT 1"));

  if (!(a && arrayp(a) && sizeof(a)))
    return;

  int maxid = a[0]["id"];
  int cid = 0;

  
  //
  // ok, we get 100 at a time
  //

  do
  {
    array objs = app->model->find("object", 
      (["id": Fins.Model.Criteria("id >= " + cid + " and id < " + (cid + 100)) ])
    );

    foreach(objs;; object o)
    {
      mapping r = (["misc": ([]), "variables": ([]) ]);

      string html = app->render(o["current_version"]["contents"], o, r);

      if(r["misc"]["object_is_weblog"] || r["misc"]["object_is_index"]) 
      {
        continue;
      }
      // now, let's parse the html for hrefs.
      object parser = Parser.HTML();

      parser->add_container("a", extract_href);
      parser->set_extra(o);

      parser->finish(html);

    }

    cid = cid + 100;

  } while(cid < maxid);

  foreach(backlink_mods; string page; array backlinks)
  {
    array a = app->model->find("object", ([ "path": page ]));

    if(!sizeof(a)) continue;

    else a[0]["md"]["backlinks"] = backlinks;
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
        if(backlink_mods[(args->href)[7..]])
         backlink_mods[(args->href)[7..]] += ({ extra[0]["path"] });
        else
         backlink_mods[(args->href)[7..]] = ({ extra[0]["path"] });
      }
    }
  }
}
