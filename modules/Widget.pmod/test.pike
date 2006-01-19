
void main() {
  object page = Widget.Page();
  page->set_title("this is a test page");
  object p = Widget.P();
  page->add_child(p);
  object text = Widget.Text("I am some test text");
  p->add_child(text);
  object a = Widget.A(Standards.URI("http://helicopter.geek.nz/"));
  p->add_child(a);
  a->add_rel("friend");
  object text2 = Widget.Text("James' website is cool.");
  a->add_child(text2);
  object br = Widget.Br();
  p->add_child(br);
  write(page->render("xhtml11"));
  //write(page->render("xml"));
}
