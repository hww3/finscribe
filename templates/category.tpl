<html>
<head>
  {include:header.tpl}
   <title>{config.site.name} :: Category {category.category}</title>
</head>
<body>
{include:tagline.tpl}
   <div id="page-wrapper">
    <div id="page-content">
   <h3>{category.category}</h3>
{if:loggedin:data->user}<div class="snip-buttons"> [ <a href="/exec/edit/{obj}">edit</a> ] </div> 
<div class="flash-message">{!flash:msg}</div>
   <div class="snip-wrapper">
      <div class="snip-content">
Items in this category:
<ul>
{foreach:objects}
  <li> <a href="/space/{objects:objects.path}">{objects:objects.title}</a>
{end:objects}
</ul>
<p/>
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
