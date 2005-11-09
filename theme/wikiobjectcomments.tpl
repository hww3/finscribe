<html>
<head>
   <link rel="STYLESHEET" type="text/css" href="/space/themes/default/default.css" />
   <title>FinBlog :: {title}</title>
</head>
<body>
{include:tagline.tpl}

   <div id="page-wrapper">
    <div id="page-content">

   <h3>{title}</h3>
   Created by {author_username}. Last updated by {editor_username}, 
{when}. 
Version #{version}.
   <br/>
   
   {if:loggedin:data->user}<div class="snip-buttons"> [ <a href="/exec/edit/{obj}">edit</a> ] </div>
   {endif:loggedin} 
   <br/>
   
   <font color="red">{!flash:msg}</font>
   <p/>
   
   <div class="snip-wrapper">
      <div class="snip-content">
         <div>
         {content}
         
         <p/>
         <b>{numcomments} Comments</b> | <a href="/exec/comments/{obj}">Post a Comment</a>
         <p/>
         {foreach:comments}
<a name="{comments:comments.id}"></a>
<img src="/static/images/Icon-Comment.png" width="15" height="11" 
border="0"></a>
Posted by {comments:comments.author.Name}, {comments:comments.nice_created}.
<a href="/comments/{obj}#{comments:comments.id}"><img 
src="/static/images/Icon-Permalink.png" width="8" height="9" 
alt="permalink" border="0"/></a>
<p/>
         {comments:comments.wiki_contents}
         <p/>
         {end:comments}
         </div>
      </div>
      </div>
      </div>
         <div id="page-portlet-1-wrapper">
          <div id="page-portlet-1">
         {!snip:themes/default/portlet-1}
         </div>
         </div>
         
</div>

<div id="page-bottom"><a href="/space/contact+info">contact info</a> | Copyright 1995-2005 Bill Welliver</div>
</body>
</html>
