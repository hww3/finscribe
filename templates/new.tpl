<html>
<head>
   <link rel="STYLESHEET" type="text/css" href="/space/themes/default/default.css" />
<title>{config.name} :: creating object</title>
</head>
<body>
{include:tagline.tpl}

{include:pagebegin.tpl}
   <h3>Create new object</h3>

<form action="" method="post">
Object path: <input type="text" size="40" name="title" value="{title}"/><br>
<br>
<input type="submit" name="action" value="Create">
</form>

{include:footer.tpl}
