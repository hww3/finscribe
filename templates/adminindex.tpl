<html>
<head>
  {include:header.tpl}
   <title>FinBlog :: admin</title>
</head>
<body>
{include:tagline.tpl}
   <div id="page-wrapper">
    <div id="page-content">
   <h3>{title}</h3>
 
<div class="snip-buttons"> [] </div> 

<div class="flash-message">{!flash:msg}</div>
   <div class="snip-wrapper">
      <div class="snip-content">

          <h1>Admin</h1>
        
	<ul>
		<li><a href="userlist">Edit Users</a>
	</ul>
          
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

<div id="page-bottom"><a href="/space/contact+info">contact info</a> | Copyright 1995-2005 Bill 
Welliver</div>
</body>
</html>

