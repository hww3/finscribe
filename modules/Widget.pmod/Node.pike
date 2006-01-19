import Public.Parser;
multiset VALID_CHILDREN;
static array _children = ({});
static string _name = "emptynode";
static mapping _attributes = ([]);
static .Node _root;
static .Node _parent;

public array children() {
  return _children;
}

public string name() {
  return _name;
}

public string set_name(string name) {
  if (name && stringp(name))
    _name = name;
}

public void|.Node add_child(.Node child) {
  if (child && objectp(child) && (!equal(child, this_object()))) {
    if (VALID_CHILDREN && multisetp(VALID_CHILDREN) && !VALID_CHILDREN[child->name()])
      throw(Error.Generic(sprintf("Widget %O is not a valid child of widget %O.\n", child->name(), name())));
    if (sizeof(_children)) {
      int match;
      foreach(_children, object _child) {
	if (equal(_child, child)) {
	  match++;
	  break;
	}
      }
      if (!match) {
	_children += ({ child });
	child->set_parent(this_object());
	child->set_root(root());
	return child;
      }
    }
    else {
      _children += ({ child });
	child->set_parent(this_object());
	child->set_root(root());
      return child;
    }
  }
}

public void|.Node pop_child() {
  if (sizeof(_children)) {
    object n = _children[sizeof(_children)-1];
    _children = _children[0..sizeof(_children)-2];
    return n;
  }
}

public void|.Node shift_child() {
  if (sizeof(_children)) {
    object n = _children[0];
    _children = _children[1..sizeof(_children)-1];
    return n;
  }
}

public void set_attribute(string name, void|string|Standards.URI value) {
  if (value)
    _attributes[name] = value;
  else
    m_delete(_attributes, name);
}

public void|string|Standards.URI get_attribute(string name) {
  return _attributes[name];
}

public void|.Node set_root(void|.Node root) {
  if (root)
    return _root = root;
}

public void|.Node root() {
  return _root;
}

public void|.Node set_parent(void|.Node parent) {
  if (parent)
    return _parent = parent;
}

public void|.Node parent() {
  return _parent;
}

public string|XML2.Node render(void|string|XML2.Node parent) {
  object me;
  string as;
  if (parent && stringp(parent)) {
    as = parent;
    parent = 0;
  }
  if (parent && objectp(parent)) {
    me = parent->new_child(name(), "");
    me->set_ns(Widget.NS_URI);
  }
  else {
    if (Widget.ROOT_NODES[name()]) {
      me = XML2.new_xml("1.0", name());
      me->add_ns(Widget.NS_URI, Widget.NS_NAME);
      me->set_ns(Widget.NS_URI);
    }
    else 
      throw(Error.Generic(sprintf("Widget %O is not a valid root node.\n", name())));
  }
  foreach(indices(_attributes), string aname) {
    string value;
    if (objectp(_attributes[aname]))
      value = (string)_attributes[aname];
    else if (stringp(_attributes[aname]))
      value = _attributes[aname];
    if (value)
      me->set_attribute(aname, value);
  }
  foreach(children(), object widget)
    widget->render(me);
  switch(as) {
    case "xhtml11":
      object ss = XML2.parse_xslt(Widget.XHTML11_TEMPLATE, "xhtml11.xsl");
      object xformed = ss->apply(me);
      return XML2.render_xml(xformed);
    case "xml":
      return XML2.render_xml(me);
    default:
      return me;
  }
}

string _sprintf() {
  return sprintf(
      "Widget.Node(/* <%s:%s %{%s=\"%s\" %}/>%s */)",
      Widget.NS_NAME,
      name(),
      (array)_attributes,
      (sizeof(_children)?sprintf(" + %d children", sizeof(_children)):"")
    );
}
