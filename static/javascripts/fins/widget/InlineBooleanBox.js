dojo.provide("fins.widget.InlineBooleanBox");

dojo.require("dijit.InlineEditBox");
dojo.require("dijit.form.CheckBox");

dojo.declare("fins.widget.InlineBooleanBox", dijit.InlineEditBox, 
{
	editor: dijit.form.RadioButton,
	
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
	},
	
	widgetType: "InlineBooleanBox"
});
