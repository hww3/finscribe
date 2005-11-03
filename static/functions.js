        function toggleVisibility( what )
        {
                node = document.getElementById(  what );
                icon = document.getElementById(  "icon-" + what );
                if(node.style.display == 'block')
                {
                        node.style.display = 'none';
                        icon.src = '/static/images/Icon-Unfold.png';
                }
                else
                {
                        node.style.display = 'block';
                        icon.src = '/static/images/Icon-Fold.png';
                }
        }

