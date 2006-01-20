//! this is a template for a FinScribe plugin

Fins.Application app;

constant name = "";
constant description = "";

void create(Fins.Application _app)
{
	app = _app;
}

int installed()
{
	return 0;
}

int enabled()
{
	return 0;
}

void start()
{
	
}

void stop()
{
	
}

array query_event_callers()
{
	return ({});
}

array query_macro_callers()
{
	return ({});
}

array query_type_callers()
{
	return ({});
}

array query_path_callers()
{
	return ({});
}

array query_preferences()
{
	return ({});
}