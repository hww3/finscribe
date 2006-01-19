inherit Widget.Node;
multiset VALID_CHILDREN = (< "p", "form", "profile" >);

void create() {
  set_name("page");
  set_root(this_object());
}

public string set_title(string title) {
  set_attribute("title", title);
  return title;
}

public void|string get_title() {
  return get_attribute("title");
}

