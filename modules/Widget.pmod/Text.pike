inherit Widget.Node;
import Public.Parser;

multiset VALID_CHILDREN = (<>);

static string _content;
static int _editable, _rows, _cols;

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

int editable() {
  return _editable;
}

int set_editable(int editable) {
  _editable = editable;
  set_attribute("editable", editable?"true":"false");
  return editable;
}

int get_rows() {
  return _rows;
}

int set_rows(int rows) {
  if (rows) {
    _rows = rows;
    set_attribute("rows", (string)rows);
  }
  return rows;
}

int get_cols() {
  return _cols;
}

int set_cols(int cols) {
  if (cols) {
    _cols = cols;
    set_attribute("cols", (string)cols);
  }
  return cols;
}

XML2.Node render(XML2.Node parent) {
  if (editable() && !get_rows())
    set_rows(sizeof((get_content()||"") / "\n"));
  object me = ::render(parent);
  me->set_content(get_content());
  return me;
}
