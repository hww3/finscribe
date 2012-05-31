static void create()
{
}

void load_preferences()
{
  foreach(prefs;; mapping prefdef)
  {
    this->new_pref(prefdef->name, prefdef);
  }
}

array prefs =
({
([
"name": "site.url",
"friendly_name": "Site URL",
"description": "This is the URL that users will enter to access your site (it should be the root, such as http://www.mysite.com/).",
"type": FinScribe.STRING
]),

([
"name": "site.name",
"friendly_name": "Site Name",
"description": "This is the name for your website. It is used in the default templates. An example might be: Joe's Weblog",
"type": FinScribe.STRING
]),

([
"name": "site.logo",
"friendly_name": "Site Logo File",
"description": "You may specify the URL of an image that will be displayed in the default page layout template.",
"type": FinScribe.STRING
]),

([
"name": "site.tagline",
"friendly_name": "Site Tagline",
"description": "A short phrase describing your website. Displayed in the default page layout template. Example: all the news that interests me.",
"type": FinScribe.STRING
]),

([
"name": "site.track_views",
"friendly_name": "Track Views",
"description": "Should FinScribe track page view counts (aggregated)? You may turn this feature off for a (possibly negligible) speed increase.",
"type": FinScribe.BOOLEAN
]),

([
"name": "mail.host",
"friendly_name": "Mail Host",
"description": "FinScribe uses an SMTP mail host to send emails. Please specify the preferred host here.",
"type": FinScribe.STRING
]),

([
"name": "mail.return_address",
"friendly_name": "Mail Return Address",
"description": "Specify the return address for any email sent by the FinScribe engine (such as for lost passwords.)",
"type": FinScribe.STRING
]),

([
"name": "administration.autocreate",
"friendly_name": "Account Autocreate",
"description": "Should users be able to create their own FinScribe accounts?",
"type": FinScribe.BOOLEAN
]),

([
"name": "comments.anonymous",
"friendly_name": "Anonymous Commenting",
"description": "Enabling this feature will allow anonymous users to comment (with spam-detection in place).",
"type": FinScribe.BOOLEAN
]),

([
"name": "blog.weblog_ping",
"friendly_name": "Enable Weblog.com PING",
"description": "",
"type": FinScribe.BOOLEAN
]),

([
"name": "blog.permalink_title",
"friendly_name": "Permalink Format",
"description": "Choosing 'date and title' includes the post's title in a weblog entry's permalink.",
"type": FinScribe.STRING,
"options": ({"date and title", "date only"})
]),

([
"name": "blog.pingback_send",
"friendly_name": "Enable Pingback sending",
"description": "Should FinScribe send 'pingbacks' for links we make to other sites?",
"type": FinScribe.BOOLEAN
]),

([
"name": "blog.pingback_receive",
"friendly_name": "Enable PingBack recieving (recording)",
"description": "Should FinScribe record 'pingbacks' for links made to objects we create?",
"type": FinScribe.BOOLEAN
]),

([
"name": "",
"friendly_name": "",
"description": "",
"type": FinScribe.STRING
]),

([
"name": "",
"friendly_name": "",
"description": "",
"type": FinScribe.STRING
])

});
