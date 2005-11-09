import Fins;
inherit Fins.FinsView;

program template;

static mapping templates = ([]);
static mapping simple_macros = ([]);

static void create()
{
  template = (program)"blog_template";
}

//!
public Template.Template get_template(program templateType, string templateName, void|object context)
{
  object t;

werror("GET_TEMPLATE\n");
  if(!sizeof(templateName))
    throw(Error.Generic("get_template(): template name not specified.\n"));

  if(!templates[templateType])
  {
    templates[templateType] = ([]);
  }

  if(!templates[templateType][templateName])
  {
    t = templateType(templateName, context);

    if(!t)
    {
      throw(Error.Generic("get_template(): unable to load template " + templateName + "\n"));
    }

    templates[templateType][templateName] = t;
  }

  return templates[templateType][templateName];

}

//!
public int flush_template(string templateName)
{
   foreach(templates;; mapping templateT)
   if(templateT[templateName])
   {
      m_delete(templateT, templateName);
      return 1;
   }
   return 0;
}

