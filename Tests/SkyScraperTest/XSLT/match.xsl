<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:regexp="http://exslt.org/regular-expressions"
                extension-element-prefixes="regexp">

<xsl:template match="c">
  <xsl:variable name="val"><xsl:value-of select="."/></xsl:variable>
  regexp: no+ (case)          string: <xsl:value-of select="." /> result: <xsl:for-each select="regexp:match($val, 'no+', '')"><xsl:value-of select="position()" /> = <xsl:value-of select="." />, </xsl:for-each>
  regexp: no+ (nocase)        string: <xsl:value-of select="." /> result: <xsl:for-each select="regexp:match($val, 'no+', 'i')"><xsl:value-of select="position()" /> = <xsl:value-of select="." />, </xsl:for-each>
  regexp: no+ (case,global)   string: <xsl:value-of select="." /> result: <xsl:for-each select="regexp:match($val, 'no+', 'g')"><xsl:value-of select="position()" /> = <xsl:value-of select="." />, </xsl:for-each>
  regexp: no+ (nocase,global) string: <xsl:value-of select="." /> result: <xsl:for-each select="regexp:match($val, 'no+', 'gi')"><xsl:value-of select="position()" /> = <xsl:value-of select="." />, </xsl:for-each>
</xsl:template>
<xsl:template match="emoji">
<xsl:variable name="val"><xsl:value-of select="."/></xsl:variable>
regexp: 🌵🌷 (case)          string: <xsl:value-of select="." /> result: <xsl:for-each select="regexp:match($val, '🌵🌷', '')"><xsl:value-of select="position()" /> = <xsl:value-of select="." />, </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
