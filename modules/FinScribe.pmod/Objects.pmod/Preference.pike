inherit Fins.Model.DirectAccessInstance;

string type_name = "preference";
object repository = Fins.Model.module;


mixed get_value()
{
  mixed val;

  switch((int)this["Type"])
  {
    case FinScribe.INTEGER:
      val = (int)this["Value"];
      break;
    case FinScribe.STRING:
      val = this["Value"];
      break;
    case FinScribe.BOOLEAN:
      val = ((int)this["Value"])?1:0;
      break;
  }

  return val;
}
