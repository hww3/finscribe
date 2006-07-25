dojo.provide("fins.widget.InlineBooleanBox");
dojo.provide("fins.widget.html.InlineBooleanBox");

dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.graphics.color");
dojo.require("dojo.string");
dojo.require("dojo.style");
dojo.require("dojo.html");

dojo.widget.tags.addParseTreeHandler("dojo:inlinebooleanbox");

dojo.widget.html.InlineBooleanBox = function(){
	dojo.widget.HtmlWidget.call(this);
	// mutable objects need to be in constructor to give each instance its own copy
	this.history = [];
}

dojo.inherits(dojo.widget.html.InlineBooleanBox, dojo.widget.HtmlWidget);

dojo.lang.extend(dojo.widget.html.InlineBooleanBox, {
	templatePath: dojo.uri.dojoUri("fins/widget/templates/HtmlInlineBooleanBox.html"),
	templateCssPath: dojo.uri.dojoUri("fins/widget/templates/HtmlInlineBooleanBox.css"),
	widgetType: "InlineBooleanBox",

	form: null,
        input_true: null,
        input_false: null,
	submitButton: null,
	cancelButton: null,

	minWidth: 100, //px. minimum width of edit box
	minHeight: 200, //px. minimum width of edit box, if it's a TA

	editing: false,
	textValue: "",
	defaultText: "",
	doFade: false,
	
	onSave: function(newValue, oldValue){},
	onUndo: function(value){},

	postCreate: function(args, frag){
		// put original node back in the document, and attach handlers
		// which hide it and display the editor
                this.input_true.name=this.widgetId;
                this.input_false.name=this.widgetId;

		this.editable = this.getFragNodeRef(frag);
		dojo.dom.insertAfter(this.editable, this.form);
		dojo.event.connect(this.editable, "onmouseover", this, "mouseover");
		dojo.event.connect(this.editable, "onmouseout", this, "mouseout");
		dojo.event.connect(this.editable, "onclick", this, "beginEdit");

		this.textValue = dojo.string.trim(this.editable.innerHTML);
		if(dojo.string.trim(this.textValue).length == 0){
			this.editable.innerHTML = this.defaultText;
		}		
	},

	mouseover: function(e){
		if(!this.editing){
			dojo.html.addClass(this.editable, "editableRegion");
		}
	},

	mouseout: function(e){
		if(!this.editing){
			dojo.html.removeClass(this.editable, "editableRegion");
		}
	},

	// When user clicks the text, then start editing.
	// Hide the text and display the form instead.
	beginEdit: function(e){
		if(this.editing){ return; }
		this.mouseout();
		this.editing = true;

		this.input_true.value = "1";
		this.input_false.value = "0";
		this.input_true.style.display = "";
		this.input_false.style.display = "";
                if(this.textValue.toLowerCase()== "true")
                {
                  this.input_true.checked = "1";
                }
                else
                  this.input_false.checked = "1";

		// show the edit form and hide the read only version of the text
		this.form.style.display = "";
		this.editable.style.display = "none";

		this.submitButton.disabled = true;
	},

	saveEdit: function(e){
		e.preventDefault();
		e.stopPropagation();
                var cv = "true";
                if(this.input_false.checked) cv = "false";

		if((this.textValue.toLowerCase() != cv))
                {
			this.doFade = true;
			this.history.push(cv);
			this.onSave(cv, this.textValue);
			this.textValue = cv;
			this.editable.innerHTML = this.textValue;
		}else{
			this.doFade = false;
		}
		this.finishEdit(e);
	},

	cancelEdit: function(e){
		if(!this.editing){ return false; }
		this.editing = false;
		this.form.style.display="none";
		this.editable.style.display = "";
		return true;
	},

	finishEdit: function(e){
		if(!this.cancelEdit(e)){ return; }
		if(this.doFade) {
			dojo.lfx.highlight(this.editable, dojo.graphics.color.hex2rgb("#ffc"), 700).play(300);
		}
		this.doFade = false;
	},

	setText: function(txt){
		// sets the text without informing the server
		var tt = dojo.string.trim(txt);
		this.textValue = tt
		this.editable.innerHTML = tt;
	},

	undo: function(){
		if(this.history.length > 0){
			var value = this.history.pop();
			this.editable.innerHTML = value;
			this.textValue = value;
			this.onUndo(value);
		}
	},

	checkForValueChange: function(){

                var cv = "true";
                if(this.input_false.checked) cv = "false";
		if((this.textValue.toLowerCase() != cv))
                {
			this.submitButton.disabled = false;
		}
	}
});
