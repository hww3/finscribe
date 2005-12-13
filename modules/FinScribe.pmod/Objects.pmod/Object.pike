inherit Fins.Model.DirectAccessInstance;

string type_name = "object";
object repository = FinScribe.Repo;



public array get_blog_entries(int|void max)
{
werror("get_blog_entries()\n");
  array o = FinScribe.Repo.find("object", ([ "is_attachment": 2, "parent": this]),
                        Fins.Model.Criteria("ORDER BY path DESC" + (max?(" LIMIT " + max) : "")));

  return o;
}

public string get_object_contents(Fins.Request|void id)
{

   return this["current_version"]["contents"];
}


