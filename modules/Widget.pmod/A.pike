constant FXN_PROFILE = (< "contact", "acquaintance", "friend", "met", "co-worker", "colleague", "co-resident", "neighbour", "child", "parent", "sibling", "spouse", "kin", "muse", "crush", "date", "sweetheart", "me" >);
constant FXN_URI = "http://www.gmpg.org/xfn/11";

multiset VALID_CHILDREN = (< "text" >);

inherit Widget.Node;
static array _rel = ({});

void create(void|Standards.URI href) {
  set_name("a");
  if (href)
    set_href(href);
}

Standards.URI set_href(Standards.URI href) {
  set_attribute("href", href);
  return href;
}

Standards.URI get_href() {
  return get_attribute("href");
}

string add_rel(string rel) {
  if (FXN_PROFILE[rel]) {
    object profile = .Profile(Standards.URI(FXN_URI));
    root()->add_child(profile);
  }
  _rel += ({ rel });
  set_attribute("rel", get_rel());
  return get_rel();
}

string rm_rel(string rel) {
  _rel -= ({ rel });
  set_attribute("rel", get_rel());
  return get_rel();
}

string get_rel() {
  return _rel * " ";
}
