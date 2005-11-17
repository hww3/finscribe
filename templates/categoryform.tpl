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

<form action="/exec/editcategory/{obj}" method="post" 
enctype="multipart/form-data">
Existing Category: <select name="existing-category">
<option value="">Select a category
{foreach:existing-categories}<option>{existing-categories:existing-categories.category}
{end:existing-categories}
</select> or new category: <input type="text" name="new-category" 
size="15" value=""/>
<br/>
<input type="submit" name="action" value="Include"/>
<input type="submit" name="action" value="Remove"/>
</form>

{endif:loggedin}
{endif:hascategories}

</div>
{endif:weblog}

