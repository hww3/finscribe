{if:weblog:data->object_is_weblog}
{else:weblog}
{if:hasattachments:data->user||data->numattachments!=0}
<a id='link-attachments-{obj}'
onclick="toggleVisibility('attachments-{obj}')"><img
id="icon-attachments-{obj}" src="/static/images/Icon-Unfold.png" border="0">
{numattachments} Attachments</a><br/>
<div id="attachments-{obj}" style="display:none;margin-left:20px">
<table>
{foreach:attachments}
<tr><td><a href="/space/{attachment:attachments.path}">{attachments:attachments.title}</a></td>
<td>{attachments:attachments.datatype.mimetype}</td>
<td>{attachments:attachments.current_version.content_length}</td></tr>
{end:attachments}
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
{endif:hasattachments}

</div>
{endif:weblog}
