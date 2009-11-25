inherit Fins.Model.DirectAccessInstance;

string type_name = "Preference";

mixed get_value()
{
  mixed val;

  switch((int)this["type"])
  {
    case FinScribe.INTEGER:
      val = (int)this["value"];
      break;
    case FinScribe.STRING:
      val = this["value"];
      break;
    case FinScribe.BOOLEAN:
      val = ((int)this["value"])?1:0;
      break;
  }

  return val;
}
