<html>
<head>
  {include:header.tpl}
   <title>{config.site.name} :: Trackbacks for {object.title}</title>
</head>
<body>

   <div class="snip-wrapper">
      <div class="snip-content">

The trackback URL for this article is: {config.site.url}/exec/trackback/{object.path}.

{foreach:trackbacks}
{trackbacks:trackbacks.url}<br/>
{trackbacks:trackbacks.excerpt}
<hr/>
{end:trackbacks}

      </div>
         
</div>
</body>
</html>
