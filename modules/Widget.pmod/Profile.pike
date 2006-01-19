inherit Widget.Node;

multiset VALID_CHILDREN = (<>);

void create(Standards.URI uri) {
  set_name("profile");
  set_attribute("uri", uri);
}

