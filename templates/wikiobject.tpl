<html>
<head>
  {include:header.tpl}
   <title>{config.site.name} :: {title}</title>
</head>
<body>
{include:tagline.tpl}
   <div id="page-wrapper">
    <div id="page-content">
      {if:isblog:data->object_is_weblog}
      {else:isblog}
   <h3>{title}</h3>
   Created by {author_username}. Last updated by {editor_username}, 
{when}. Version #{version}.

<!-- {include:trackback.tpl} -->

     {endif:isblog}
<div class="snip-buttons"> [ 
{if:loggedin:data->user}
{if:locked:data->metadata["locked"]!=1 || data->UserName == data->object["author"]["UserName"]} <a 
href="/exec/edit/{obj}">edit</a>{else:locked} edit{endif:locked} | 
{if:a:data->UserName == data->object["author"]["UserName"] || data->is_admin}
{if:l:data->metadata["locked"]} <a href="/exec/toggle_lock/{object.path}">unlock</a> {else:l} <a href="/exec/toggle_lock/{object.path}">lock</a> {endif:l} {else:a} {if:nl:data->metadata["locked"]} unlock {else:nl} lock {endif:nl} {endif:a}
| <a href="/exec/new">new</a> |
{endif:loggedin}
<a href="/exec/versions/{obj}">versions</a> ] </div>
<div class="flash-message">{!flash:msg}</div>
   <div class="snip-wrapper">
      <div class="snip-content">
   {include:attachmentform.tpl}
   {include:categoryform.tpl}
         {content}
<p/>
{if:weblog:data->object_is_weblog}
{else:weblog}
         <b>{if:comments:data->numcomments}
                 <a href="/comments/{obj}">{numcomments} comments</a></b>
            {else:comments}
                 No comments 
            {endif:comments}
 | <a href="/exec/comments/{obj}">Post a Comment</a> | <a href="/rss/{object.path}?type=comments">RSS Feed</a>
 | <a href="/exec/display_trackbacks/{object.path}">{numtrackbacks} TrackBacks</a>
         <p/>
{endif:weblog}
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
