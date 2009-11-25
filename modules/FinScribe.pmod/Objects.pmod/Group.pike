inherit Fins.Model.DirectAccessInstance;

string type_name = "Group";

//!
int is_member(object user)
{
  // this is sort of brute force, a more elegant way is left to the user.
  foreach(this["users"];; object u)
    if(u == user) return 1;

  return 0;
}
