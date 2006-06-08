inherit Fins.Model.DirectAccessInstance;

string type_name = "aclrule";
object repository = FinScribe.Repo;

constant xmits = ([
   "browse": 1,
   "read": 2,
   "version": 4,
   "write": 8,
   "delete": 16,
   "comment": 32,
   "post": 64,
   "lock": 128
]);

array get_available_xmits()
{
      // permit bits are follows:
      //    bit 1: browse
      //    bit 2: read
      //    bit 3: version
      //    bit 4: write (create)
      //    bit 5: delete
      //    bit 6: comment/annotate
      //    bit 7: post
      //    bit 8: lock

  return indices(xmits);

}

void add_xmit(string xmit)
{
  this["xmit"] = this["xmit"] | xmits[xmit];
}

void revoke_xmit(string xmit)
{
  this["xmit"] = this["xmit"] & ~ xmits[xmit];
}


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

  desc += privs * ", ";


  return desc;
}

mapping format_data()
{
  mapping data = ([]);


  array a = this["user"];

  if(this["class"])
  {
    if(this["all_users"])
      data->class="all_users";
    else if(this["owner"])
      data->class="owner";
    else if(this["anonymous"])
      data->class="anonymous";
    
  }
  else if(sizeof(a))
  {
    data->class="user";
    data["user"] = a[0]["id"];
  }
  else
  {
    data->class="group";
    a = this["group"];
    if(sizeof(a))
    {
      data["group"] = a[0]["id"];
    }
    else
    {
      data["error"] = "Invalid rule.";
      return data;
    }
  }

  data["id"] = this["id"];
  array privs = ({});

  foreach((<"browse", "read", "version", "write", "delete", "comment", "post", "lock">);string e;)
  {
    if(this[e]) data[e] = 1;
  }

  return data;
}
