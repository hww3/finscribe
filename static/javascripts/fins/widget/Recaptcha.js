dojo.provide("fins.widget.Recaptcha");

//dojo.require("dojo.fx");
/* Call <div dojoType="fins.widget.Comments" refreshUrl="/exec/json/comments?id=34" connectorId="button-34" /> */

dojo.declare("fins.widget.Recaptcha", [dijit._Widget], 
{

  /* Stuff for Dojo */
//  templatePath: dojo.cache("fins.widget", "templates/Recaptcha.html"),
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

