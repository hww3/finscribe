import Fins;
import Fins.Model;

inherit Model.DataObject;
	
static void define()
{
  set_table_name("categories");
  set_instance_name("category");
  add_field(PrimaryKeyField("id"));
  add_field(StringField("category", 64, 0));
  add_field(MultiKeyReference(this, "objects", "objects_categories", "category_id", "object_id", "object", "id"));
  set_primary_key("id");
}
