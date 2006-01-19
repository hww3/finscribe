inherit Widget.Node;

multiset VALID_CHILDREN = (< "p", "input", "button" >);

void create(void|Standards.URI action) {
  set_name("form");
  if (action)
    set_action(action);
}

Standards.URI set_action(Standards.URI action) {
  set_attribute("action", action);
  return action;
}

Standards.URI get_action() {
  return get_attribute("action");
}
