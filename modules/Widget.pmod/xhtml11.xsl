<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:widget="http://thedogstar.org/projects/Fins/Widget">

  <xsl:output
    indent="yes"
    version="1.0"
    media-type="text/html"
    method="xml"
    doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
    doctype-public="-//W3C//DTD XHTML 1.1//EN"
    encoding="iso-8859-1" />

    <!--
    This XSL stylesheet translates widgets into XHTML/1.1 for sending to a client.
    Yippie :)
  -->

  <xsl:template match="/widget:page">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
      <head>
	<xsl:if test="widget:profile">
	  <xsl:attribute name="profile">
	    <xsl:value-of select="widget:profile/@uri" />
	  </xsl:attribute>
	</xsl:if>
	<xsl:if test="@title">
	  <title><xsl:value-of select="@title" /></title>
	</xsl:if>
      </head>
      <body>
	<xsl:apply-templates />
      </body>
    </html>
  </xsl:template>

  <xsl:template match="widget:a">
    <a xmlns="http://www.w3.org/1999/xhtml">
      <!-- can't think of a way to copy recursively because <xsl:attribute name= must be a string constant? -->
      <xsl:if test="@charset">
	<xsl:attribute name="charset">
	  <xsl:value-of select="@charset" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@coords">
	<xsl:attribute name="coords">
	  <xsl:value-of select="@coords" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@href">
	<xsl:attribute name="href">
	  <xsl:value-of select="@href" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@hreflang">
	<xsl:attribute name="hreflang">
	  <xsl:value-of select="@hreflang" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@name">
	<xsl:attribute name="name">
	  <xsl:value-of select="@name" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@rel">
	<xsl:attribute name="rel">
	  <xsl:value-of select="@rel" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@rev">
	<xsl:attribute name="rev">
	  <xsl:value-of select="@rev" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@shape">
	<xsl:attribute name="shape">
	  <xsl:value-of select="@shape" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@target">
	<xsl:attribute name="target">
	  <xsl:value-of select="@target" />
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@type">
	<xsl:attribute name="type">
	  <xsl:value-of select="@type" />
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </a>
  </xsl:template>

  <xsl:template match="widget:br">
    <br xmlns="http://www.w3.org/1999/xhtml" />
  </xsl:template>

  <xsl:template match="widget:hr">
    <hr xmlns="http://www.w3.org/1999/xhtml" />
  </xsl:template>

  <xsl:template match="widget:p">
    <p xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="widget:text">
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="widget:text[@editable='true']">
    <xsl:choose>
      <xsl:when test="@rows = '1'">
	<input xmlns="http://www.w3.org/1999/xhtml">
	  <xsl:attribute name="type">
	    <xsl:choose>
	      <xsl:when test="@obscure = 'true'">
		<xsl:text>password</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>text</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  <xsl:if test="@cols">
	    <xsl:attribute name="size">
	      <xsl:value-of select="@cols" />
	    </xsl:attribute>
	  </xsl:if>
	</input>
      </xsl:when>
      <xsl:otherwise>
	<textarea xmlns="http://www.w3.org/1999/xhtml">
	  <xsl:if test="@rows">
	    <xsl:attribute name="rows">
	      <xsl:value-of select="@rows" />
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:if test="@cols">
	    <xsl:attribute name="cols">
	      <xsl:value-of select="@cols" />
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:value-of select="." />
	</textarea>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
