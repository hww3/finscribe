import Fins;
inherit Fins.FinsView;

static mapping templates = ([]);
static mapping simple_macros = ([]);

static void create(Fins.Application a)
{
  ::create(a);
}


public array prep_template(string tn)
{
  object t;

  t = get_template(Fins.Template.Simple, tn);

  object d = Fins.Template.TemplateData();
  d->set_data((["config": app()->config])); 
  return ({t, d});
}

//!
public Template.Template get_template(program templateType, string templateName, void|object context)
{
  object t;
  if(!context) 
  {
    context = Template.TemplateContext();
    context->application = app();
  }

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

