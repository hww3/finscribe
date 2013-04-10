inherit Fins.RESTController;

constant __uses_session = 0;
string model_component = "Object";

// data we don't want to expose, or which would likely cause circular references.
protected multiset fields_to_filter = (< "objects", "object_versions", "versions", 
	"comments", "current_version_uncached", "current_version", "attachments", 
	"inlinks_links", "outlinks_links", "metadata">);

protected function(array|object:array|mapping|object) transform_function = transform_object;

protected array|mapping|object transform_object(array|object item)
{
  if(arrayp(item))
  {
    foreach(item; int i; mixed data)
      item[i] = transform_object(data);
    return item;
  }
  else
  {
    mapping data = ([]);
    data->id = item["path"];
    data->name = item["title"];

    data->children = allocate(sizeof(item["children"]));
    foreach(item["children"];int x;object child)
    {
	  data->children[x] = (["id": child["path"], "name": child["title"], "stub": 1, "children": sizeof(child["children"])]);
    }

    return data;
  }
}
