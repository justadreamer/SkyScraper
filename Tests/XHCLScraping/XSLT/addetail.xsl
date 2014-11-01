<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:str="http://exslt.org/strings"
xmlns:xi="http://www.w3.org/2001/XInclude"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="str">
<xsl:import href="xml-to-string.xsl" />

<xsl:output method="text"/>

<xi:include href="tpl_sanitize.xsl" />
<xi:include href="tpl_prepend_url.xsl" />
<xsl:variable name="content">
  <xsl:copy-of select="//section[@id='postingbody']" />
</xsl:variable>

<xsl:template match="/">
  <xsl:variable name="content">

    <xsl:text>&lt;html&gt;&lt;body&gt;</xsl:text>
    <xsl:call-template name="tpl_sanitize">
      <xsl:with-param name="text">
        <xsl:call-template name="xml-to-string">
          <xsl:with-param name="node-set" select="//section[@id='postingbody']"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>&lt;/html&gt;&lt;/body&gt;</xsl:text>
  </xsl:variable>

  {
    "title":"<xsl:call-template name="tpl_sanitize">
      <xsl:with-param name="text" select="//h2[@class='postingtitle']" />
    </xsl:call-template>",
    "image_urls":<xsl:call-template name="tpl_images" />,
    "html_body":"<xsl:value-of disable-output-escaping="yes" select="$content"/>",
    "text_body":"<xsl:call-template name="tpl_sanitize">
      <xsl:with-param name="text"><xsl:value-of select="//section[@id='postingbody']"/></xsl:with-param></xsl:call-template>",
    <xsl:apply-templates select="//div[@class='postinginfos']" />
  }
</xsl:template>

<xsl:template name="tpl_images">
  [

  <xsl:choose>
    <xsl:when test="//div[@id='thumbs']">
      <xsl:for-each select="//div[@id='thumbs']//a">
        "<xsl:value-of select="./@href"/>"<xsl:if test="position()!=last()">,</xsl:if>
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="//div[@class='tray']">
      "<xsl:value-of select="//div[@class='tray']//img/@src"/>"
    </xsl:when>
  </xsl:choose>

  ]
</xsl:template>

<xsl:template match="//div[@class='postinginfos']">
  "postingID":"<xsl:value-of select="str:replace(//p[@class='postinginfo' and contains(.,'post id')],'post id: ','')" />"
  <xsl:variable name="time1"><xsl:copy-of select=".//time[position()=1]" /></xsl:variable>
  <if test="$time1/time">
    ,"posted":"<xsl:value-of select="exsl:node-set($time1)/time/@datetime"/>"
  </if>
  <if test=".//time[position()=2]">
    ,"updated":"<xsl:value-of select=".//time[position()=2]/@datetime"/>"
  </if>
</xsl:template>

</xsl:stylesheet>

