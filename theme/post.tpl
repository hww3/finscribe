<html>
<head>
   <link rel="STYLESHEET" type="text/css" href="/space/themes/default/default.css" />
<title>Posting: {title}</title>
</head>
<body>
{include:tagline.tpl}

{include:pagebegin.tpl}
   <h3>Posting: {title}</h3>


<form action="" method="post">
Subject: <input type="text" name="subject" size="40" value="{subject}"/>
<br/>
<textarea rows="20" cols="80" name="contents">{contents}</textarea>
<br/>
<input type="submit" name="action" value="Preview"/>
<input type="submit" name="action" value="Save"/>
</form>

{if:preview:data->preview}
<b>Preview:</b><p/>
{preview}
{endif:preview}

{include:footer.tpl}
