inherit Fins.RESTController;

string model_component = "Object";

// data we don't want to expose, or which would likely cause circular references.
protected multiset fields_to_filter = (< "objects", "object_versions", "versions", 
	"comments", "current_version_uncached", "current_version", "attachments", 
	"inlinks_links", "outlinks_links", "metadata">);

void method_get(object id, object r, mixed ... args)
{
  werror("REQUEST: %O\n", id);
  ::method_get(id, r, @args);
}