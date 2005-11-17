{if:weblog:data->object_is_weblog}
{else:weblog}
{if:hascategories:data->user||data->numcategories!=0}
<a id='link-categories-{obj}'
onclick="toggleVisibility('categories-{obj}')"><img
id="icon-categories-{obj}" src="/static/images/Icon-Unfold.png" 
border="0">
{numcategories} Categories</a><br/>
<div id="categories-{obj}" style="display:none;margin-left:20px">
<table>
{foreach:categories}
<tr><td><a 
href="/space/{categories:categories.category}">{categories:categories.category}</a></td></tr>
{end:categories}
</table>

 {if:loggedin:data->user}

<form action="/exec/upload" method="post" 
enctype="multipart/form-data">
<input type="hidden" name="root" value="{obj}"/>
Attachment name: <input type="text" name="save-as-filename"
size="35"/><br>
File: <input name="upload-file" type="file"/>
<br/>
MimeType: <select name="mime-type">
{foreach:datatypes}<option>{datatypes:datatypes.mimetype}
{end:datatypes}
</select>
<br/>
<input type="submit" name="action" value="Attach"/>
</form>

{endif:loggedin}
{endif:hascategories}

</div>
{endif:weblog}

