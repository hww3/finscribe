<html>
<head>
    <link rel="STYLESHEET" type="text/css" href="/space/themes/default/default.css" />
<title>Login</title>
</head>
<body>
{include:tagline.tpl}
{include:pagebegin.tpl}
   <h3>Login</h3>

   <p>
<form action="" method="post">
<input type="hidden" name="return_to" value="{return_to}"/>
Login: <input type="string" name="UserName" value="{UserName}"/><br/>
Password: <input type="password" name="Password"/>
<p/>
<input type="submit" name="action" value="Login"/>
<input type="submit" name="action" value="Cancel"/>
</form>
<p/>
<a href="/exec/forgotpassword">Forgot password?</a>
{if:autocreate:data->autocreate}
|
<a href="/exec/createaccount">Create an account</a>
{endif:autocreate}

{include:footer.tpl}
