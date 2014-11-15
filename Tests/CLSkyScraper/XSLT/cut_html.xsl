<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:str="http://exslt.org/strings"
xmlns:xi="http://www.w3.org/2001/XInclude"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="str">

  <xsl:import href="xml-to-string.xsl"/>
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:variable name="content">
      <xsl:call-template name="xml-to-string">
        <xsl:with-param name="node-set" select="//section[@id='postingbody']"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of disable-output-escaping="yes" select="$content" /> 
  </xsl:template>  
</xsl:stylesheet>