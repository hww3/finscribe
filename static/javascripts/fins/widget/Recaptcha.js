dojo.provide("fins.widget.Recaptcha");
dojo.require("dijit._Widget");
dojo.declare("fins.widget.Recaptcha", [dijit._Widget], 
{

  /* Stuff for Dojo */
  widgetType: "Recaptcha",
  /* end */
  theme: "red",
  public_key: "",

  startup: function() {

     Recaptcha.create(this.public_key,
			this.srcNodeRef,
                        { theme: this.theme, 
                          callback: Recaptcha.focus_response_field }
                     );

  },

});
