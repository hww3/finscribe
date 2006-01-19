inherit Widget.Node;
import Public.Parser;

multiset VALID_CHILDREN = (<>);

static string _content;

void create(void|string content) {
  set_name("text");
  if (content)
    _content = content;
}

void|string set_content(void|string content) {
  if (content)
    return _content = content;
}

string get_content() {
  return _content||"";
}

XML2.Node render(XML2.Node parent) {
  object me = ::render(parent);
  me->set_content(get_content());
  return me;
}
