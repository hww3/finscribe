import Fins;

inherit FinScribe.Plugin;

constant name = "Parent Fixer";

int _enabled = 1;

int is_running = 0;

void start()
{
  logger->debug("starting parent fixer.");

  app->call_out(app->create_thread, 0, update_parents);
}

void update_parents()
{
  logger->info("Parent updater thread started.");
  if(is_running) return;

  is_running = 1;

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

  // okay, now we need to find any objects which have a slash, but no parent.
  array orphans = Fins.DataSource._default.find.objects( (["parent": 0, "path": Fins.Model.LikeCriteria("%/%")]));

  foreach(orphans;; object orp)
  {
    object p = app->model->find_nearest_parent(orp["path"]);
    if(p) orp["parent"] = p;
  }

  is_running = 0;
  app->call_out(app->create_thread, 3600*24, update_parents);

}

void process_object(object o, int|void immediate)
{
	logger->debug("finding children for %s", o["path"]);
  array x = Fins.DataSource._default.find.objects( (["path": Fins.Model.AndCriteria(({Fins.Model.LikeCriteria(o["path"] + "/%"), 
Fins.Model.NotCriteria(Fins.Model.LikeCriteria(o["path"] + "/%/%") ) })) ]));

  foreach(x;; object c)
  {
  	logger->debug("  -- parent of %s is %s.", c["path"], o["path"]);
    c["parent"] = o;
  }
}
