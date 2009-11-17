import Tools.Logging;
import Fins;

inherit FinScribe.Plugin;

constant name = "Parent Fixer";

int _enabled = 1;

int is_running = 0;

void start()
{
  Log.debug("starting parent fixer...");

  call_out(Thread.Thread, 0, update_parents);
}

void update_parents()
{
  Log.info("Parent updater thread started.");
werror(">>>\n>>>parent updater\n>>>\n");
  if(is_running) return;

  is_running = 1;

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
	process_object(o);
    }

    cid = cid + 100;

  } while(cid < maxid);

  // okay, now we need to find any objects which have a slash, but no parent.
  array orphans = app->model->find("object", (["parent": 0, "path": Fins.Model.LikeCriteria("%/%")]));

  foreach(orphans;; object orp)
  {
    object p = app->model->find_nearest_parent(orp["path"]);
    if(p) orp["parent"] = p;
  }

  is_running = 0;
  call_out(Thread.Thread, 3600*24, update_parents);

}

void process_object(object o, int|void immediate)
{
werror("finding children for %s\n", o["path"]);
  array x = app->model->find("object", (["path": Fins.Model.AndCriteria(({Fins.Model.LikeCriteria(o["path"] + "/%"), 
Fins.Model.NotCriteria(Fins.Model.LikeCriteria(o["path"] + "/%/%") ) })) ]));

  foreach(x;; object c)
  {
  werror("  -- parent of %s is %s.\n", c["path"], o["path"]);
    c["parent"] = o;
  }
}
