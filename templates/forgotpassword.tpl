<html>
<head>
    <link rel="STYLESHEET" type="text/css" href="/space/themes/default/default.css" />
<title>Password Retrieval</title>
</head>
<body>
{include:tagline.tpl}
{include:pagebegin.tpl}
   <h3>Password Retrieval</h3>
<p/>
Enter your username in the form below and click on "Locate." Your account password will be emailed to the address on record for that account.
   <p/>
<form action="" method="post">
Username: <input type="string" name="username" value="{username}"/><br/>
<p/>
<input type="submit" name="action" value="Locate"/>
</form>
{include:footer.tpl}
