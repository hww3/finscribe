<!-- this is tagline.tpl -->
  <div id="page-logo">
    <img src="/static/images/alchemy.gif" alt="electronic.alchemy" border="0"/>   
  </div>
  <div id="page-title">
   <div id="page-tagline">where the past meets the future</div>
  <div id="page-buttons"> [
{if:start:data->obj=="start"}
 start 
{else:start}
<a href="/space/start">start</a>
{endif:start}
|
{if:index:data->obj=="object-index"}
 index 
{else:index}
<a href="/space/object-index">index</a>
{endif:index}


   {if:loggedin:data->user}
| logged in as {username} | <a href="/exec/logout">logout</a>
  {if:isblog:data->object_is_weblog}
      |  <a href="/exec/post/{obj}">post blog</a>
  {endif:isblog}

   {else:loggedin} 
| <a href="/exec/login">login</a> 
   {endif:loggedin}

]
<p/>
  {!breadcrumbs:obj}
 </div>
