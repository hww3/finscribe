
dojo.provide("fins.widget.ACLBuilder");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dijit.form.Button");
dojo.require("dojox.collections.ArrayList");
dojo.require("dojo.json");

dojo.declare("fins.widget.ACLBuilder", [dijit._Widget, dijit._Templated], 
{

    added: new Array(),
    removed: new Array(),

    originalRules: new dojox.collections.ArrayList(),
    deletedRules: new dojox.collections.ArrayList(),

    formNode: null,
    builderNode: null,
	rulesElement: null,

    builderFromContainerNode: null,
    builderControlContainerNode: null,
    builderToContainerNode: null,

    ruleChangedFlag: false,
    newRuleFlag: false,
    currentRuleId: null,
    currentRule: null,
    currentRuleIndex: null,

    ruleAppliesList: null,
    fullRule: null,

    newButton: null,
    editButton: null,
    deleteButton: null,
    saveButton: null,
    cancelButton: null,

    fromRulesList: null,
    toGroupList: null,
    toUserList: null,

    rule_groups_div: null,
    rule_users_div: null,

    rule_radio_user: null,
    rule_radio_group: null,
    rule_radio_allusers: null,
    rule_radio_owner: null,
    rule_radio_anonymous: null,

    rule_xmit_browse: null,
    rule_xmit_read: null,
    rule_xmit_version: null,
    rule_xmit_write: null,
    rule_xmit_delete: null,
    rule_xmit_comment: null,
    rule_xmit_post: null,
    rule_xmit_lock: null,

    // this is a div containing the current rule as built.
    current_rule_storage: null,

    // functions that return an array of valid users and groupss
    loadAvailableUsersFunction: "",
    loadAvailableGroupsFunction: "",
    loadAvailableRulesFunction: "",

    addsId: "",
    removesId: "",

    addsElement: null,
    removesElement: null,

	capitalize: function (str) {
	        if (!dojo.isString(str)) {
	                return "";
	        }
	        if (arguments.length == 0) {
	                str = this;
	        }
	        var words = str.split(" ");
	        for (var i = 0; i < words.length; i++) {
	                words[i] = words[i].charAt(0).toUpperCase() + words[i].substring(1);
	        }
	        return words.join(" ");
	},

    xmitChanged: function(evt)
    {
      this.ruleChanged();
    },

    newRule: function()
    {
      this.fromRulesList.disabled = 1;
      this.newRuleFlag = true;
      this.enableRule();
    },

    editRule: function()
    {

      var sel = this.fromRulesList.selectedIndex;

      if(sel == -1)
      {
        alert("error: no item selected!");
        return;
      }
      
      var rule = this.originalRules.item(sel);
      this.currentRuleIndex = sel;

      if(!rule)
      {
        alert("invalid rule!");
        return;
      }

      this.fromRulesList.disabled = 1;
      this.enableRule();
      this.populateRule(rule);

    },

    populateRule: function(rule)
    {
      this.updateRuleApplies(rule);
      this.updateRulePermissions(rule);

      this.currentRuleId = rule.id;     
      this.currentRule = rule;

      this.saveButton.disabled = 1;
      this.editButton.disabled = 1;
      this.deleteButton.disabled = 1;
      this.newButton.disabled = 1;
    },

    updateRulePermissions: function(rule)
    {
      if(rule["browse"])
        this.rule_xmit_browse.checked = 1;
      if(rule["read"])
        this.rule_xmit_read.checked = 1;
      if(rule["version"])
        this.rule_xmit_version.checked = 1;
      if(rule["write"])
        this.rule_xmit_write.checked = 1;
      if(rule["delete"])
        this.rule_xmit_delete.checked = 1;
      if(rule["comment"])
        this.rule_xmit_comment.checked = 1;
      if(rule["post"])
        this.rule_xmit_post.checked = 1;
      if(rule["lock"])
        this.rule_xmit_lock.checked = 1;
    },

    updateRuleApplies: function(rule)
    {
      var i;
      var c = rule.class;
      for(i=0; i<this.ruleAppliesList.length; i++)
      {
        if(this.ruleAppliesList.options[i].value == c)
        {
          this.ruleAppliesList.selectedIndex = i;
          this.ruleAppliesChangedInternal();
          break;
        }
      }

      if(c == "group")
      {
        var g;
        for(g = 0; g < this.toGroupList.options.length; g++)
        {
          if(this.toGroupList.options[g].value == rule.group)
          {
             this.toGroupList.selectedIndex = g;
             break;
          }
        }
      }
      else if(c == "user")
      {
        var u;
        for(u = 0; u < this.toUserList.options.length; u++)
        {
          if(this.toUserList.options[u].value == rule.user)
          {
             this.toUserList.selectedIndex = u;
             break;
          }
        }
      }
    },

    deleteRule: function()
    {
      var s = this.fromRulesList.selectedIndex;

      var r = this.originalRules.item(s);

      // if we're a new rule, we won't be on the server yet, so we can just forget the rule.
      if(!r.isNew)
        this.deletedRules.add(this.originalRules.item(s));      

      this.originalRules.removeAt(s);
      this.fromRulesList.options[s] = null;
      this.fromRulesList.selectedIndex = -1;
      this.editButton.disabled = 1;   
      this.deleteButton.disabled = 1;   
      this.fullRule.innerHTML = "ACL Rule Deleted.";
    },

    saveRule: function()
    {
      this.saveButton.disabled = 1;
      this.editButton.disabled = 0;
      this.deleteButton.disabled = 0;
      this.newButton.disabled = 0;
      this.fromRulesList.disabled = 0;
     
      this.saveRuleChanges();
      this.resetRule();
    },

    saveRuleChanges: function()
    {
      var r = this.currentRule;

      if(this.newRuleFlag)
        r = {};

      r.class = this.ruleAppliesList.options[this.ruleAppliesList.selectedIndex].value;

      r["browse"] = this.rule_xmit_browse.checked;
      r["read"] = this.rule_xmit_read.checked;
      r["version"] = this.rule_xmit_version.checked;
      r["write"] = this.rule_xmit_write.checked;
      r["delete"] = this.rule_xmit_delete.checked;
      r["post"] = this.rule_xmit_post.checked;
      r["comment"] = this.rule_xmit_comment.checked;
      r["lock"] = this.rule_xmit_lock.checked;

      if(r.class == "user")
      {
        r.user = this.toUserList.options[this.toUserList.selectedIndex].value;
        if(r.group) r.group = null;
      }

      else if(r.class == "group")
      {
        r.group = this.toGroupList.options[this.toGroupList.selectedIndex].value;
        if(r.user) r.user = null;
      }

      if(this.newRuleFlag)
      {
        r.isNew = 1;
        this.fromRulesList.options[this.fromRulesList.length] = new Option(this.describeRule(r), "0");
        this.originalRules.add(r);
        this.fullRule.innerHTML = "New ACL Rule Saved.";
      }
      else
      {
        // we can be editing a new, uncommitted rule. if so, it's still just a new rule.
        if(!r.isNew)
          r.isChanged = 1;
        r.id = this.currentRuleId;
        this.fromRulesList.options[this.currentRuleIndex].text = this.describeRule(r);
        this.fullRule.innerHTML = "ACL Rule Saved.";
      }

    },

    cancelRule: function()
    {
      this.saveButton.disabled = 1;
      this.editButton.disabled = 0;
      this.deleteButton.disabled = 0;
      this.newButton.disabled = 0;
      this.fromRulesList.disabled = 0;
      this.resetRule();
    },

    describeRule: function(rule)
    {
      var res = "";
      var s = new String(rule.class);
      s = s.replace("_", " ");
      res += this.capitalize(s);

      if(rule.class == "user")
      {
        var u;
        for(u = 0; u < this.toUserList.options.length; u++)
        {
          if(this.toUserList.options[u].value == rule.user)
          {
             res = res + " " +  this.toUserList.options[u].text;
             break;
          }
        }
      }
      else if(rule.class == "group")
      {
        var g;
        for(g = 0; g < this.toGroupList.options.length; g++)
        {
          if((this.toGroupList.options[g].value) == rule.group)
          {
             res = res + " " + this.toGroupList.options[g].text;
             break;
          }
        }
      }

      res += ": ";

      var a = new dojox.collections.ArrayList();;

      if(rule["browse"])
         a.add("BROWSE");
      if(rule["read"])
         a.add("READ");
      if(rule["version"])
         a.add("VERSION");
      if(rule["write"])
         a.add("WRITE");
      if(rule["delete"])
         a.add("DELETE");
      if(rule["comment"])
         a.add("COMMENT");
      if(rule["post"])
         a.add("POST");
      if(rule["lock"])
         a.add("LOCK");

      return res + a.toArray().join(", ");
    },

    resetRule: function()
    {
      this.ruleEnableOwner();

      this.ruleAppliesList.selectedIndex = -1;

      this.currentRuleId = null;
      this.currentRuleIndex = null;
      this.currentRule = null;

      this.ruleAppliesList.disabled = 1;
      this.newRuleFlag = false;
      this.rule_xmit_browse.checked = 0;
      this.rule_xmit_read.checked = 0;
      this.rule_xmit_version.checked = 0;
      this.rule_xmit_write.checked = 0;
      this.rule_xmit_delete.checked = 0;
      this.rule_xmit_comment.checked = 0;
      this.rule_xmit_post.checked = 0;
      this.rule_xmit_lock.checked = 0;

      this.rule_xmit_browse.disabled = 1;
      this.rule_xmit_read.disabled = 1;
      this.rule_xmit_version.disabled = 1;
      this.rule_xmit_write.disabled = 1;
      this.rule_xmit_delete.disabled = 1;
      this.rule_xmit_comment.disabled = 1;
      this.rule_xmit_post.disabled = 1;
      this.rule_xmit_lock.disabled = 1;

      this.ruleChangedFlag = false;
    },

    enableRule: function()
    {
      this.ruleEnableOwner();

      this.ruleAppliesList.disabled = 0;

      this.rule_xmit_browse.checked = 0;
      this.rule_xmit_read.checked = 0;
      this.rule_xmit_version.checked = 0;
      this.rule_xmit_write.checked = 0;
      this.rule_xmit_delete.checked = 0;
      this.rule_xmit_comment.checked = 0;
      this.rule_xmit_post.checked = 0;
      this.rule_xmit_lock.checked = 0;

      this.rule_xmit_browse.disabled = 0;
      this.rule_xmit_read.disabled = 0;
      this.rule_xmit_version.disabled = 0;
      this.rule_xmit_write.disabled = 0;
      this.rule_xmit_delete.disabled = 0;
      this.rule_xmit_comment.disabled = 0;
      this.rule_xmit_post.disabled = 0;
      this.rule_xmit_lock.disabled = 0;
    },

    ruleEnableUser: function()
    {
      this.rule_groups_div.style.display = 'none';
      this.rule_users_div.style.display = '';
      this.toGroupList.selectedIndex = -1;
      this.toUserList.disabled = 0;
      this.toGroupList.disabled = 1;
    },

    ruleEnableOwner: function()
    {
      this.ruleEnableOther();
    },

    ruleEnableAllUsers: function()
    {
      this.ruleEnableOther();
    },

    ruleEnableAnonymous: function()
    {
      this.ruleEnableOther();
    },

    ruleEnableGroup: function()
    {
      this.rule_users_div.style.display = 'none';
      this.rule_groups_div.style.display = '';
      this.toUserList.selectedIndex = -1;
      this.toGroupList.disabled = 0;
      this.toUserList.disabled = 1;
    },

    ruleEnableOther: function()
    {
      this.rule_users_div.style.display = 'none';
      this.rule_groups_div.style.display = 'none';
      this.toUserList.selectedIndex = -1;
      this.toGroupList.selectedIndex = -1;
      this.toGroupList.disabled = 1;
      this.toUserList.disabled = 1;
    },

    postCreate: function() {
      if (this.loadAvailableGroupsFunction) {
        this.loadAvailableGroupsFunction = dojo.global[this.loadAvailableGroupsFunction];
      }
      if (this.loadAvailableUsersFunction) {
        this.loadAvailableUsersFunction = dojo.global[this.loadAvailableUsersFunction];
      }
      if (this.loadAvailableRulesFunction) {
        this.loadAvailableRulesFunction = dojo.global[this.loadAvailableRulesFunction];
      }

       this.editButton.disabled = 1;
       this.deleteButton.disabled = 1;
       this.saveButton.disabled = 1;

    },

    startup: function(args, fragment)
    {
       this.resetRule();
      if(this.loadAvailableUsersFunction &&  dojo.isFunction(this.loadAvailableUsersFunction))
      {
        var res = this.loadAvailableUsersFunction();
//alert(res);
        for(var i = 0; i < res.length; i++)
        {
          this.toUserList.options[this.toUserList.length] = new Option(res[i].name, res[i].value);
//          this.original[this.original.length] = res[i].value;
        }
      }

      if(this.loadAvailableGroupsFunction &&  dojo.isFunction(this.loadAvailableGroupsFunction))
      {
        var res = this.loadAvailableGroupsFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.toGroupList.options[this.toGroupList.length] = new Option(res[i].name, res[i].value);
//          this.original[this.original.length] = res[i].value;
        }
      }

      if(this.loadAvailableRulesFunction &&  dojo.isFunction(this.loadAvailableRulesFunction))
      {
        var res = this.loadAvailableRulesFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.fromRulesList.options[this.fromRulesList.length] = new Option(this.describeRule(res[i].value), res[i].value.id);
          this.originalRules.add(res[i].value);
        }

      }

      var f = this.domNode;
      var form;
	  do
	  {
		if(f.parentNode == f)
		  break;
		f = f.parentNode;
		//alert("f: " + f);
		if(f.nodeName.toLowerCase() == "form") 
		  form = f;
		else
		{
          form = dojo.query('form', f);
 		  if(form.length)
			form = form[0];
		}
	  } while(!form || !form.length);
	
      if(form)
      {
              //alert("hooking into the form.");
       	this.formNode = f;
                                dojo.connect(f.form, "onsubmit",
                                        dojo.hitch(this, function(){
											this.rulesElement.value = dojo.json.serialize({rules: this.originalRules.toArray(), deleted: this.deletedRules.toArray() });                              			
//											this.formNode.appendChild(rules); 
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

    ruleChanged: function()
        {
          this.ruleChangedFlag = true;
          this.saveButton.disabled = 0;
        },
	
        ruleAppliesChanged: function()
        {
          this.ruleAppliesChangedInternal();
          this.ruleChanged();
        },

        ruleAppliesChangedInternal: function()
        {
          var t = this.ruleAppliesList.options[this.ruleAppliesList.selectedIndex];

          var v = t.value;

          if(v=="group") this.ruleEnableGroup();
          else if(v=="user") this.ruleEnableUser();
          else if(v=="anonymous") this.ruleEnableAnonymous();
          else if(v=="all_users") this.ruleEnableAllUsers();
          else if(v=="owner") this.ruleEnableOwner();

        },

		fromGroupChanged: function() {	
		          var selectedItems = new Array();

		          for (var i = 0; i < this.fromGroupList.length; i++) {
		            if (this.fromRulesList.options[i].selected)
		              selectedItems[selectedItems.length] = this.fromRulesList.options[i].value;
		          }
		          if(selectedItems.length == 0)
		          {
		            this.fullRule.innerHTML = "";
			    this.deleteButton.disabled = 1;
			    this.editButton.disabled = 1;
		          }
		          else
		  	  {
		         this.fullRule.innerHTML = this.fromRulesList.options[this.fromRulesList.selectedIndex].text;

				//dojo.debug(this.fromRulesList.options[this.fromRulesList.selectedIndex].text);
			    this.deleteButton.disabled = 0;
			    this.editButton.disabled = 0;
		          }
		       },

	fromChanged: function() {	
          var selectedItems = new Array();

//alert("fromchanged");

          for (var i = 0; i < this.fromRulesList.length; i++) {
            if (this.fromRulesList.options[i].selected)
              selectedItems[selectedItems.length] = this.fromRulesList.options[i].value;
          }
          if(selectedItems.length == 0)
          {
            this.fullRule.innerHTML = "";
	    this.deleteButton.disabled = 1;
	    this.editButton.disabled = 1;
          }
          else
  	  {
            this.fullRule.innerHTML = this.fromRulesList.options[this.fromRulesList.selectedIndex].text;
            
//dojo.debug(this.fromRulesList.options[this.fromRulesList.selectedIndex].text);
	    this.deleteButton.disabled = 0;
	    this.editButton.disabled = 0;
          }
       },
	
	toChanged: function() {
		
       var selectedItems = new Array();

       for (var i = 0; i < this.toUserList.length; i++) {
         if (this.toUserList.options[i].selected)
            selectedItems[selectedItems.length] = this.toUserList.options[i].value;
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

	widgetType: "ACLBuilder",

	labelPosition: "top",

	templateString:  dojo.cache("fins.widget", "templates/ACLBuilder.html")
});
