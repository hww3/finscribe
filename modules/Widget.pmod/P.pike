inherit Widget.Node;

multiset VALID_CHILDREN = (< "br", "text", "img", "object", "a" >);

void create() {
  set_name("p");
}

