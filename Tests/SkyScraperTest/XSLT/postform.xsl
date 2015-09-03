<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str">

<xsl:output method="text"/>
<xsl:template match="/">
  {
    <xsl:apply-templates select=".//form"/>
  }
</xsl:template>

<xsl:template match="form[@id='postingForm']">
  "form_action":"<xsl:value-of select="@action"/>",
  "fields": [
    <xsl:for-each select=".//*">
      
      <xsl:choose>
        <xsl:when test="local-name(.)='fieldset'">
          <xsl:call-template name="tpl_fieldset" />
        </xsl:when>
        <xsl:when test="(local-name(.)='label' or local-name(.)='input') and local-name(ancestor::fieldset)!='fieldset'">
          <xsl:call-template name="tpl_label_or_input" />
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    null
  ]
</xsl:template>

<xsl:template name="tpl_fieldset">
  {
    "type":"fieldset",
    "display_name":"<xsl:value-of select="normalize-space(str:replace(legend,'[?]',''))"/>",
    "fields":[
      <xsl:for-each select=".//label | .//input">
        <xsl:call-template name="tpl_label_or_input" />
      </xsl:for-each>
      null
    ]
  },
</xsl:template>

<xsl:template name="tpl_label_or_input">
  <xsl:choose>
    <xsl:when test="local-name(.)='label'">
      {
        "display_name":"<xsl:value-of select="str:replace(normalize-space(.),'&quot;','\&quot;')"/>",
        <xsl:choose>
          <xsl:when test="input">
            <xsl:apply-templates select="input" />
          </xsl:when>
          <xsl:when test="textarea">
            <xsl:apply-templates select="textarea" />
          </xsl:when>
          <xsl:otherwise>
        "type":"label",
        "is_required":<xsl:value-of select="contains(@class,'req')"/>,
        "is_error":<xsl:value-of select="contains(@class,'err')"/>
          </xsl:otherwise>
        </xsl:choose>
      },
    </xsl:when>
    <xsl:when test="local-name(.)='input' and local-name(ancestor::label)!='label'">
      {
        <xsl:call-template name="tpl_input" />
      },
    </xsl:when>
  </xsl:choose>
</xsl:template>


<xsl:template name="tpl_input" match="input">
        "type":"<xsl:value-of select="@type"/>",
        "name":"<xsl:value-of select="@name"/>",
        "value":"<xsl:value-of select="@value"/>",
        "is_required":<xsl:value-of select="contains(@class,'req')"/>,
        "is_error":<xsl:value-of select="contains(@class,'err')"/>
</xsl:template>

<xsl:template match="textarea">
        "type":"textarea",
        "name":"<xsl:value-of select="@name"/>",
        "value":"<xsl:value-of select="@value"/>",
        "is_required":<xsl:value-of select="contains(@class,'req')"/>,
        "is_error":<xsl:value-of select="contains(@class,'err')"/>,
        "text":"<xsl:value-of select="text()"/>"
</xsl:template>

</xsl:stylesheet>