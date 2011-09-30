
dojo.provide("fins.widget.ComboPicker");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");

dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.html.style");

dojo.declare("fins.widget.ComboPicker", [dijit._Widget, dijit._Templated], 
{
    added: new Array(),
    removed: new Array(),

    original: [],

    fromList: null,
    toList: null,
    pickerNode: null,
    pickerFromContainerNode: null,
    pickerControlContainerNode: null,
    addButton: null,
    removeButton: null,
    pickerToContainerNode: null,

    loadAvailableFunction: "",
    loadMembersFunction: "",
    addsId: "",
    removesId: "",

    addsElement: null,
    removesElement: null,

    postCreate: function() {
                if (this.loadAvailableFunction) {
                        this.loadAvailableFunction = dj_global[this.loadAvailableFunction];
                }
                if (this.loadMembersFunction) {
                        this.loadMembersFunction = dj_global[this.loadMembersFunction];
                }
        },

    startup: function()
    {
      if(this.loadMembersFunction &&  dojo.lang.isFunction(this.loadMembersFunction))
      {
        var res = this.loadMembersFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.toList.options[this.toList.length] = new Option(res[i].name, res[i].value);
          this.original[this.original.length] = res[i].value;
        }
      }

      if(this.loadAvailableFunction &&  dojo.lang.isFunction(this.loadAvailableFunction))
      {
        var res = this.loadAvailableFunction();
        for(var i = 0; i < res.length; i++)
        {
          var l = 0;

          for(var z = 0; z < this.toList.options.length; z++)
          {
            if(this.toList.options[z].value == res[i].value)
               l = 1;
          }

          if(!l)
            this.fromList.options[this.fromList.length] = new Option(res[i].name, res[i].value);
        }
      }

      if(this.addsId)
        this.addsElement = dojo.byId(this.addsId);
      if(this.removesId)
        this.removesElement = dojo.byId(this.removesId);

      dojo.debug("removes element: " + this.removesId);
      dojo.debug("removes element: " + this.removesElement);
                        if((this.addsElement && this.addsElement.form) || 
                                  (this.removesElement && this.removesElement.form)){
				dojo.debug("hooking into the form.");
                                dojo.event.connect(this.addsElement.form, "onsubmit",
                                        dojo.hitch(this, function(){
                                                this.addsElement.value = this.getAdded();
                                                this.removesElement.value = this.getRemoved();
                                        })
                                );
                        }
    },

	hasOptions: function(obj) {
		if (obj!=null && obj.options!=null) { return true; }
		return false;
		},

	sortSelect: function(obj) {
		var o = new Array();
		if (!hasOptions(obj)) { return; }
		for (var i=0; i<obj.options.length; i++) {
			o[o.length] = new Option( obj.options[i].text, obj.options[i].value, obj.options[i].defaultSelected, obj.options[i].selected) ;
			}
		if (o.length==0) { return; }
		o = o.sort( 
			function(a,b) { 
				if ((a.text+"") < (b.text+"")) { return -1; }
				if ((a.text+"") > (b.text+"")) { return 1; }
				return 0;
				} 
			);

		for (var i=0; i<o.length; i++) {
			obj.options[i] = new Option(o[i].text, o[i].value, o[i].defaultSelected, o[i].selected);
			}

		},


    addItem: function() {

       var toRemove = new Array();

       for (var i = 0; i < this.fromList.length; i++) {
	      if(this.fromList.options[i].selected)
	      {
		    var n = 0;
                    var v = this.fromList.options[i].value;

                for(var y = 0; y < this.toList.options.length; y++)
                {
                   if(this.toList.options[y].value == v)
                      n = 1; // already on the list
                }
     
                if(n==0)
  	          this.toList.options[this.toList.length] = new Option(this.fromList.options[i].text, v);

                n = 1;

                    for(var q = 0; q < this.original.length; q++)
                    {
               	       if(this.original[q] == v) // already had it in our list
                       n = 0;
                    }

                    if(n)
                      this.added[this.added.length] =  v;
  
                    // we also need to remove any entry for this element from the "removed" column.
                    for(var z = this.removed.length; z >= 0; z--)
                    {
			if(this.removed[z] == v) this.removed[z] = null;
                    }
		    toRemove[toRemove.length] = i;
          }
       }

       sortSelect(this.toList);

		for(var j = toRemove.length-1; j >= 0; j--)
		  this.fromList.options[toRemove[j]] = null;
    },

    getAdded: function(){
      var a = new Array();

      for(var i = 0; i < this.added.length; i++)
        if(this.added[i] != null)
          a[a.length] = this.added[i];          

      return a;
    },

    getRemoved: function(){
      var a = new Array();

      for(var i = 0; i < this.removed.length; i++)
        if(this.removed[i] != null)
          a[a.length] = this.removed[i];          

      return a;
    },

    Q: function() {
	  	var str = "";
	    str = str + "added: " + this.getAdded();
	    str = str + "removed: " + this.getRemoved();

         alert(str);
    },

    removeItem: function() { 
	   
	   var toRemove = new Array();
	
	   for (var i = 0; i < this.toList.length; i++) {

	      if(this.toList.options[i].selected)
	      {
                var n = 0;
                var v = this.toList.options[i].value;

                for(var y = 0; y < this.fromList.options.length; y++)
                {
                   if(this.fromList.options[y].value == v)
                      n = 1; // already on the list
                }
     
                if(n==0)
  	          this.fromList.options[this.fromList.length] = new Option(this.toList.options[i].text, v);

                n = 0;

                for(var q = 0; q < this.original.length; q++)
                {
                   if(this.original[q] == v) // already had it in our list
                   n = 1;
                }

            if(n)
              this.removed[this.removed.length] = v;
  
          for(var z = this.added.length; z >= 0; z--)
            {
				if(this.added[z] == v) this.added[z] = null;
            }

          	toRemove[toRemove.length] = i;
		  }
       }
	
       sortSelect(this.fromList);

		for(var j = toRemove.length-1; j >= 0; j--)
		  this.toList.options[toRemove[j]] = null;
	},
	
	fromChanged: function() {
		
       var selectedItems = new Array();

       for (var i = 0; i < this.fromList.length; i++) {
         if (this.fromList.options[i].selected)
            selectedItems[selectedItems.length] = this.fromList.options[i].value;
       }
       if(selectedItems.length == 0)
       {
	       this.addButton.disabled = true;
       }
       else
       {
	       this.addButton.disabled = false;
       }
     },
	
	toChanged: function() {
		
       var selectedItems = new Array();

       for (var i = 0; i < this.toList.length; i++) {
         if (this.toList.options[i].selected)
            selectedItems[selectedItems.length] = this.toList.options[i].value;
       }
       if(selectedItems.length == 0)
       {
	       this.removeButton.disabled = true;
       }
       else
       {
	       this.removeButton.disabled = false;
       }
     },

	widgetType: "ComboPicker",

	labelPosition: "top",

	templateString:  dojo.cache("fins.widget", "templates/ComboPicker.html"),
//	templateCssPath: dojo.uri.dojoUri("fins/widget/templates/ComboPicker.css")

});