import Tools.Logging;

inherit FinScribe.Plugin;

constant name="Full Text indexing";

mapping query_event_callers()
{
  return (["postSave": updateIndex ]);
}


int updateIndex(string event, object id, object obj)
{
  Log.info("saved " + obj["path"]);  

  object c = Protocols.XMLRPC.Client("http://buoy.riverweb.com:9001/update/?PSESSIONID=123");

  c["add"](obj["title"], obj["current_version"]["created"]->unix_time(), obj["current_version"]["contents"], obj["path"]);

  return 0;
}
