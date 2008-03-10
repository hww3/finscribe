import Parser.XML.Tree;

int main(int argc, array argv)
{
  string s=Stdio.stdin->read();
  Parser.XML.Tree tree=parse_input(s);

  foreach(tree->get_children()[0]->get_children(), Node node)
  {
//  werror("name: %O\n", node->get_tag_name());
    switch(node->get_tag_name())
    {
      case "str":
      {
	Node orig_node, trans_node;
	foreach(node->get_children(), Node child)
	{
	  if(child->get_tag_name()=="o")
	    orig_node=child;
	  if(child->get_tag_name()=="t")
	    trans_node=child;
	}
//        catch {
werror("translating %s\n", orig_node[0]->get_text());
	string tr = Tools.Language.Translate.translate(orig_node[0]->get_text(),
					     "en", argv[1]);
werror("  translated to %s\n", tr);

	trans_node->add_child(Node(XML_TEXT, "",
				   ([]), tr
					));
  //      };
sleep(15);
	break;
      }
      
      case "language":
      {
	node->replace_child(node[0],
			    Node(XML_TEXT, "", ([]), argv[1]));
	break;
      }
    }
  }  
  
  write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"+tree->html_of_node());
}
