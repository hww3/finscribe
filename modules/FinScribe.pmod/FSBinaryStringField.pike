inherit Fins.Model.BinaryStringField;


mixed decode(mixed value, void|Fins.Model.DataObjectInstance i)
{
  catch
  {
    if(i && has_prefix(i["object"]["datatype"]["mimetype"], "text/"))
     return utf8_to_string(value);
    else return value;
  };

  return value;
}         
