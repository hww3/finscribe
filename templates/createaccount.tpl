<html>
<head>
    <link rel="STYLESHEET" type="text/css" href="/space/themes/default/default.css" />
<title>Login</title>
</head>
<body>
{include:tagline.tpl}
{include:pagebegin.tpl}
   <h3>Create account</h3>

   <p>
       {foo}
<form action="" method="post">
<input type="hidden" name="return_to" value="{return_to}"/>
Login: <input type="string" name="UserName" value=""/><br/>
Password: <input type="password" name="Password"/>
<p/>
<input type="submit" name="action" value="Login"/>
<input type="submit" name="action" value="Cancel"/>
</form>
<p/>
{include:footer.tpl}
