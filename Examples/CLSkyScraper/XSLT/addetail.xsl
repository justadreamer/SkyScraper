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

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_full_img_url">
    <xsl:param name="src" />
    <xsl:if test="string-length($src)>0">
        <xsl:choose>
            <xsl:when test="contains($src,'http:')"> <!-- full image url -->
                <xsl:value-of select="$src" />
            </xsl:when>
            <xsl:when test="contains($src,'https:')"> <!-- full image url -->
                <xsl:value-of select="$src" />
            </xsl:when>
            <xsl:when test="contains($src,'/') = 0"> <!--this is for best-of images, which are relative to listing URL-->
                <xsl:value-of select="regexp:replace($URL, '/([^/]*?)\.html/?', 'i', concat('/',$src))" />
            </xsl:when>
            <xsl:otherwise> <!-- otherwise some kind of relative URL - concat it with a base URL -->
                <xsl:call-template name="tpl_prepend_href_with_base_url"><xsl:with-param name="href" select="$src"/></xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

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
    <xsl:for-each select="//div[contains(@class,'gallery')]//img/@src | //div[contains(@id,'thumbs')]//a[position()>1]/@href">
        "<xsl:call-template name="tpl_full_img_url">
            <xsl:with-param name="src" select="." />
        </xsl:call-template>"
        <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
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

