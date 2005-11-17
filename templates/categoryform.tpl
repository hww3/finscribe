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
href="/exec/category/{categories:categories.category}">{categories:categories.category}</a></td></tr>
{end:categories}
</table>

 {if:loggedin:data->user}

<form action="/exec/editcategory" method="post" 
enctype="multipart/form-data">
<input type="hidden" name="root" value="{obj}"/>
Existing Category: <select name="existing-category">
{foreach:existing-categories}<option>{existing-categories:existing-categories.category}
{end:existing-categories}
</select>
<br/>
<input type="submit" name="action" value="Include"/>
</form>

{endif:loggedin}
{endif:hascategories}

</div>
{endif:weblog}

