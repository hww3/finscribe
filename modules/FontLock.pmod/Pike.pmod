/*
 * Copyright © 2000-2005 The Caudium Group
 * Copyright © 1994-2001 Roxen Internet Software
/*
 * $Id: Pike.pmod,v 1.1 2006-01-10 23:25:28 hww3 Exp $
 */

//! Syntax highlighter for pike. Used when backtrace is done to
//! send "good looking" pike formating for the developer

//!
constant cvs_version = "$Id: Pike.pmod,v 1.1 2006-01-10 23:25:28 hww3 Exp $";

//! Default CSS class
constant defaultcss = "pre,code { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      "}\n"
                      ".stringdark { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-style: italic;\n"
                      " color: darkred;\n"
                      "}\n"
                      ".stringlight { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-style: italic;\n"
                      " color: skyblue;\n"
                      "}\n"
                      ".commentdark { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " color: red;\n"
                      "}\n"
                      ".commentlight { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " color: yellow;\n"
                      "}\n"
                      ".keyworddark { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-weight: bold;\n"
                      " color: darkblue;\n"
                      "}\n"
                      ".keywordlight { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-weight: bold;\n"
                      " color: lightblue;\n"
                      "}\n"
                      ".typedark { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-weight: bold;\n"
                      " color: darkgreen;\n"
                      "}\n"
                      ".typelight { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-weight: bold;\n"
                      " color: lightgreen;\n"
                      "}\n"
                      ".predark { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " color: brown;\n"
                      "}\n"
                      ".prelight { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " color: pink;\n"
                      "}\n"
                      ".declaratordark { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-weight: bold;\n"
                      " color: darkbrown;\n"
                      "}\n"
                      ".declaratorlight { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " font-weight: bold;\n"
                      " color: #ffeeaa;\n"
                      "}\n"
                      ".casedark { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " color: #000000;\n"
                      "}\n"
                      ".caselight { \n"
                      " font-family: \"andale mono\",\"monotype.com\",\"courier new\", monospace;\n"
                      " font-size: 90%;\n"
                      " color: aquamarine;\n"
                      "}\n";

//! Quote the string to plain text to html.
//! @param s
//!   The plain text string to quote
//! @returns
//!   The string quoted
string quote(string s)
{
  return replace(s,({ "[", "\\", "<", ">", "&", }),({"&#91;", "&#92;", "&lt;", "&gt;", "&amp;" }));
}

//! Highlight a string
//! @param s
//!   The string to highlight
//! @param m
//!   The type of highlighting. If 'dark' is give in this mapping
//!   then it will use dark fonts.
//! @returns
//!   The string highlighted
//! @seealso
//!  @[highlight_pike]
string highlight_string(string s,mapping m)
{
  if(m->css && m->dark)
    return "<span class=\"stringdark\">"+quote(s)+"</span>";
  if(m->css)
    return "<span class=\"stringlight\">"+quote(s)+"</span>";
  if(m->dark)
    return "<i><font color=darkred>"+quote(s)+"</font></i>";
  return "<i><font color=skyblue>"+quote(s)+"</font></i>";
}

//! Highlight a comment
//! @param s
//!   The string to highlight
//! @param m
//!   The type of highlighting. If 'dark' is give in this mapping
//!   then it will use dark fonts.
//! @returns
//!   The string highlighted
//! @seealso
//!  @[highlight_pike]
string highlight_comment(string s, mapping m)
{ 
  if(m->css && m->dark)
    return "<span class=\"commentdark\">"+quote(s)+"</span>";
  if(m->css)
    return "<span class=\"commentlight\">"+quote(s)+"</span>";
  if(m->dark)
    return ("<font color=red>"+quote(s)+"</font>");
  return ("<font color=yellow>"+quote(s)+"</font>");
}

//! Highlight a keyword
//! @param s
//!   The string to highlight
//! @param m
//!   The type of highlighting. If 'dark' is give in this mapping
//!   then it will use dark fonts.
//! @returns
//!   The string highlighted
//! @seealso
//!  @[highlight_pike]
string highlight_keyword(string s, mapping m)
{
  if(m->css && m->dark)
    return "<span class=\"keyworddark\">"+quote(s)+"</span>";
  if(m->css)
    return "<span class=\"keywordlight\">"+quote(s)+"</span>";
  if(m->dark)
    return ("<b><font color=darkblue>"+quote(s)+"</font></b>");
  return ("<b><font color=lightblue>"+quote(s)+"</font></b>");
}

//! Highlight a type
//! @param s
//!   The string to highlight
//! @param m
//!   The type of highlighting. If 'dark' is give in this mapping
//!   then it will use dark fonts.
//! @returns
//!   The string highlighted
//! @seealso
//!  @[highlight_pike]
string highlight_type(string s, mapping m)
{
  if(m->css && m->dark)
    return "<span class=\"typedark\">"+quote(s)+"</span>";
  if(m->css)
    return "<span class=\"typelight\">"+quote(s)+"</span>";
  if(m->dark)
    return ("<b><font color=darkgreen>"+quote(s)+"</font></b>");
  return ("<b><font color=lightgreen>"+quote(s)+"</font></b>");
}

//! Highlight a pre (?)
//! @param s
//!   The string to highlight
//! @param m
//!   The type of highlighting. If 'dark' is give in this mapping
//!   then it will use dark fonts.
//! @returns
//!   The string highlighted
//! @seealso
//!  @[highlight_pike]
string highlight_pre(string s, mapping m)
{
  if(m->css && m->dark)
    return "<span class=\"predark\">"+quote(s)+"</span>";
  if(m->css)
    return "<span class=\"prelight\">"+quote(s)+"</span>";
  if(m->dark)
    return ("<font color=brown>"+quote(s)+"</font>");
  return ("<font color=pink>"+quote(s)+"</font>");
}

//! Highlight a declarator
//! @param s
//!   The string to highlight
//! @param m
//!   The type of highlighting. If 'dark' is give in this mapping
//!   then it will use dark fonts.
//! @returns
//!   The string highlighted
//! @seealso
//!  @[highlight_pike]
string highlight_declarator(string s, mapping m)
{
  if(m->css && m->dark)
    return "<span class=\"declaratordark\">"+quote(s)+"</span>";
  if(m->css)
    return "<span class=\"declaratorlight\">"+quote(s)+"</span>";
  if(m->dark)
    return ("<b><font color=darkbrown>"+quote(s)+"</font></b>");
  return ("<b><font color=#ffeeaa>"+quote(s)+"</font></b>");
}

//! Highlight a case
//! @param s
//!   The string to highlight
//! @param m
//!   The type of highlighting. If 'dark' is give in this mapping
//!   then it will use dark fonts.
//! @returns
//!   The string highlighted
//! @seealso
//!  @[highlight_pike]
string highlight_case(string s, mapping m)
{
  if(m->css && m->dark)
    return "<span class=\"casedark\">"+quote(s)+"</span>";
  if(m->css)
    return "<span class=\"caselight\">"+quote(s)+"</span>";
  if(m->dark)
    return ("<font color=black>"+quote(s)+"</font>");
  return ("<font color=aquamarine>"+quote(s)+"</font>");
}

//! The keyword to highlight
constant keywords=({"foreach","break","constant","catch","gauge","class","continue","do","else","for","foreach","if","import","inherit","inline","lambda","nomask","private","protected","public","return","static","final", "switch","throw","while",});

//! The types to highlight
constant types=({"mapping","function","multiset","array","object","program","float","int","mixed","string","void"});

//!
array (string) find_decl(string in)
{
  string pre,decl,p2;
  sscanf(in, "%[ \t\r\n]%s", pre, in);
  if(!strlen(in)) return ({"",pre+in});
  if(in[0]==')') // Cast
    return ({"",pre+in});
  if(sscanf(in, "%[^(),; \t\n\r]%s", decl,in)==2)
    return ({ pre+decl, in });
  return ({ "", pre+in });
}

//!
string find_complex_type(string post)
{
  string p="";
  if(strlen(post) && post[0]=='(')
  {
    int level=1, i=1;
    while(level && i < strlen(post))
    {
      switch(post[i++])
      {
       case '(': level++;break;
       case ')': level--;break;
      }
    }
    p = p+post[..i-1];
    post = post[i..];
    if(sscanf(post, "|%s", post))
    {
      string q;
      if(sscanf(post, "%s(", q))
      {
	p+=q;
	post = post[strlen(q)..];
      } else if(sscanf(post, "%s%*[ \t\n\r]", post)>1) {
	p+="|"+post;
	return p;
      }
      p+="|"+find_complex_type(post);
    }
    return p;
  }
  return p;
}

//!
array (string) find_type(string in)
{
  string s,pre,post,decl;
  int min=10000000000,i;
  string mt;
  foreach(types, s)
    if(((i=search(in, s))!=-1) && i<min)
    {
      if(i) switch(in[i-1])
      {
       default:
//	perror("Invalid type thingie: '"+in[i..i]+"'\n");
	continue;
       case ' ':
       case '\n':
       case '\r':
       case '\t':
       case '(':
       case ')':
      }
      min = i;
      mt = s;
    }

  if(!(s=mt)) return 0;

  if(sscanf(in, "%s"+s+"%s", pre, post)==2)
  {
    string op = post;
    string p="";
    sscanf(post, "%[ \t\n\r]%s", p, post);

    p += find_complex_type(post);

    p = op[..strlen(p)-1];
    post = op[strlen(p)..];
//    perror("Found type: '%s' (left: %s)\n", s+p, post-"\n");
    return ({ pre, s+p, @find_decl(post) });
  }
}

//! Find a keyword
array (string) find_keyword(string in)
{
  string s,pre,post;
  foreach(keywords, s) if(sscanf(in, "%s"+s+"%s", pre, post)==2)
    if(!strlen(pre) || pre[-1]==' ' || pre[-1]=='\t' || pre[-1]==':' ||
      pre[-1]=='}' || pre[-1]==')' || pre[-1]==';' || pre[-1]=='\n')
      if(!strlen(post) || post[0]==' ' || post[0]=='\t' || post[0]=='(' ||
	post[0]=='{'|| post[0]==';'||post[0]=='\n')
	return ({ pre, s, post });
}

//! Find a string
array (string) find_string(string in)
{
  string s,pre,post;
  in = replace(in, "\\\"", "\0");
  if(sscanf(in, "%[^\"]\"%[^\"]\"%s", pre, s, post)==3)
    return ({ pre, "\""+replace(s, "\0", "\\\"")+"\"", post });
}

//! Find a comment
array (string) find_comment(string in)
{
  string s,pre,post;
  if(sscanf(in, "%s//%s\n%s", pre, post,s)==3) return ({ pre,  "//"+post+"\n",s });
  if(sscanf(in, "#!%s\n%s", post,s)) return ({ "",  "#!"+post+"\n",s });
  if(sscanf(in, "%s/*%s*/%s", pre, s, post)==3)
    return ({ pre,  "/*"+s+"*/", post });
}


//! Find a comment outside of a string
array (string) find_comment_outside_string(string in)
{
  string s,pre,post,q;
  if(sscanf(in, "%s\n//%s\n%s", pre,post,s)==3)
    return ({ pre+"\n",  "//"+post+"\n", s});
  if(sscanf(in, "//%s\n%s", post,s)==2)
    return ({ "",  "//"+post+"\n", s});
  if(sscanf(in, "%s\n%[^\"]//%s\n%s", q,pre, post,s)==4)
    return ({ q+"\n"+pre,  "//"+post+"\n", s });
  if(sscanf(in, "%[^\"]/*%s*/%s", pre, s, post)==3)
    return ({ pre,  "/*"+s+"*/", post });
}

//! Find a case
array (string) find_case(string in)
{
  string mid,pre,post;
  if(sscanf(in, "%scase%s:%s", pre, mid, post)==3)
    return ({ pre, "case", mid, ":", post });
  if(sscanf(in, "%sdefault%s:%s", pre, mid, post)==3)
    return ({ pre, "default"+mid+":", "", "", post });

  if(sscanf(in, "%scase%s", pre, post)==2)
    if(!strlen(pre) || pre[-1]==' ' || pre[-1]=='\t' || pre[-1]==':')
      if(!strlen(post) || post[0]==' ' || post[0]=='\t')
	return ({ pre, "case", post, "", "" });

  if(sscanf(in, "%sdefault%s", pre, post)==2)
    if(!strlen(pre) || pre[-1]==' ' || pre[-1]=='\t' || pre[-1]==':')
      if(!strlen(post) || post[0]==' ' || post[0]=='\t')
	return ({ pre, "default", post, "", "" });
}

//! Find a preparse
array (string) find_preparse(string in)
{
  string s,post,q;
  if(sscanf(in, "%s#%s\n%s", q,s,post)==3)
    return ({ q,"#"+s+"\n", post });
}

array highlight_patterns =
({
  ({ find_comment_outside_string,  ({ 0, highlight_comment }),}),
  ({ find_string,   ({ 0, highlight_string }),}),
  ({ find_comment,  ({ 0, highlight_comment }),}),
  ({ find_preparse, ({ 0, highlight_pre }),}),
  ({ find_type,     ({ 0, highlight_type, highlight_declarator }),}),
  ({ find_keyword,  ({ 0, highlight_keyword }),}),
  ({ find_case,     ({ 0, highlight_case, 0, highlight_case, }),}),
});
    
#define push(X) res += X

//! Highlight a line
string highlight_line(string l, mapping m)
{
  array p,r;
  string res = "";
//  perror(l+"\n");
  foreach(highlight_patterns, p)
  {
    if(r=p[0](l))
    {
//      perror("Match %O (%s, %s)\n", p[-1][-1],(r[..sizeof(p[1])-1]*""),
//	     (r[sizeof(p[1])..]*""));
      for(int i=0; i<sizeof(p[1]) && i<sizeof(r); i++)
	if(functionp(p[1][i]))
	  push(p[1][i](r[i],m));
	else
	  push(highlight_line(r[i],m));
      for(int i=sizeof(p[1]); i<sizeof(r); i++)
	push(highlight_line(r[i],m));
      return res;
    }
  }
  return quote(l);
}

//! Do the highlighting work
string do_the_highlighting(string s, mapping m)
{
  return highlight_line(s, m);
}

//! Highlight a pike program
//! @param t
//!   Not really used. You can put any string there this will be ignored
//! @param m
//!   Mapping with current options that can use this code.
//!  @mapping
//!   @member string "light"
//!     Use this for light highlighting
//!   @member string "dark"
//!     Use this for dark highlighting
//!   @member string "nopre"
//!     Do not add <pre></pre> HTML code between the rendered code.
//!   @member string "css"
//!     Use this to use CSS highlighting
//!   @member string "cssfile"
//!     Use this to when using a CSS and if you like to specify a custom CSS.
//!  @endmapping
//! @param contents
//!   The Pike code to render
//! @returns
//!   HTMLized pike code :)
string highlight(string t, mapping m, string contents)
{
  string out = "";
  if(!m->light) 
    m->dark="yep";
 // if(m->nopre)
 //   out = do_the_highlighting(contents,m);
  if(m->css) {
    out = "<style type=\"text/css\">\n<!--\n";
    if ((m->cssfile) && (stringp(m->cssfile)) && (sizeof(m->cssfile) > 0))
       out += m->cssfile;
    else
       out += defaultcss;
    out += "\n-->\n</style>\n";
  }
  if(!m->nopre)
   out += "<pre>"+do_the_highlighting(contents,m)+"</pre>";
  else
   out += do_the_highlighting(contents,m);
 // return "<pre>"+do_the_highlighting(contents,m)+"</pre>";
  return out;
}

