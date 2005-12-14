<html>
<head>
   <link rel="STYLESHEET" type="text/css" href="/space/themes/default/default.css" />
<title>Versions: {object.title}</title>
</head>
<body>
{include:tagline.tpl}

{include:pagebegin.tpl}
   <h3>Versions: {object.title}</h3>
<form action="/exec/diff/{object.path}" method="post">
<table>
<tr>
<td>Version</td>
<td>Date Saved</td>
<td>Author</td>
<td>Diff from</td>
<td>Diff to</td>
</tr>
{foreach:versions}
<tr>
<td>
  {versions:versions.version} </td><td>
  {versions:versions.nice_created} </td><td>
  {versions:versions.author.UserName} </td><td>
  <input type="radio" name="from" value="{versions:versions.version}"/></td><td>
  <input type="radio" name="to" value="{versions:versions.version}"/></td>
  <td><a href="/space/{object.path}?show_version={versions:versions.version}">Show</a></td>
  </tr>
{end:versions}
</table>
<br/>
<input type="submit" name="submit" value="Show Differences"/>
</form>

{include:footer.tpl}
