<html>
<head>
  {include:header.tpl}
   <title>FinBlog :: admin :: userlist</title>
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

          <h1>User List</h1>
        
        <table>
            <tr><td>User Name</td><td>Real Name</td><td>e-mail</td><td>Admin 
User?</td><td>Active?</td><td></td></tr>  
          {foreach:users}
        <tr>
            <td>{users:users.UserName}</td>
            <td>{users:users.Name}</td>
            <td>{users:users.Email}</td>
            <td><a href="toggle_useradmin?userid={users.id}">{!boolean:users.is_admin}</a></td>
            <td><a href="toggle_useractive?userid={users.id}">{!boolean:users.is_active}</a></td>
            <td>[<a href="edituser?userid={users:users.id}">Edit</a> | 
                <a href="deleteuser?userid={users:users.id}">Delete</a> ]</td>
        </tr>
          {end:users}
        </table>
          
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

