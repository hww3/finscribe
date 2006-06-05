inherit Fins.Model.DirectAccessInstance;

string type_name = "aclrule";
object repository = FinScribe.Repo;


string format_nice()
{
  string desc = "";

  array a = this["user"];

  if(this["class"])
  {
    if(this["all_users"])
      desc+="All Users";
    else if(this["owner"])
      desc+="Owner";
    else if(this["anonymous"])
      desc+="Anonymous";
    
    desc += ": ";
  }
  else if(sizeof(a))
  {
    desc+=("User: " + a[0]["Name"] + " ");
  }
  else
  {
    a = this["group"];
    if(sizeof(a))
    {
      desc+=("Group: " + a[0]["Name"] + " ");
    }
    else
    {
      desc = "Invalid rule.";
      return desc;
    }

  }

  array privs = ({});

  foreach((<"browse", "read", "version", "write", "delete", "comment", "post", "lock">);string e;)
  {
    if(this[e]) privs += ({ upper_case(e) });
  }

  desc += privs * ",";


  return desc;
}

mapping format_data()
{
  mapping data = ([]);


  array a = this["user"];

  if(this["class"])
  {
    if(this["all_users"])
      data["all_users"] = 1;
    else if(this["owner"])
      data["owner"] = 1;
    else if(this["anonymous"])
      data["anonymous"] = 1;
    
  }
  else if(sizeof(a))
  {
    data["user"] = a[0]["UserName"];
  }
  else
  {
    a = this["group"];
    if(sizeof(a))
    {
      data["group"] = a[0]["Name"] + " ";
    }
    else
    {
      data["error"] = "Invalid rule.";
      return data;
    }

  }

  array privs = ({});

  foreach((<"browse", "read", "version", "write", "delete", "comment", "post", "lock">);string e;)
  {
    if(this[e]) data[e] = 1;
  }

  return data;
}
