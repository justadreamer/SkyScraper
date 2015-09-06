<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:regexp="http://exslt.org/regular-expressions"
extension-element-prefixes="regexp">
<xsl:output method="text" />
<xsl:template match="c">
    <xsl:variable name="results" select="regexp:match(string(.), '[^\d]*(\d*)[^\d]*', 'g')" />
    <xsl:value-of select="$results[1]" /><xsl:value-of select="$results[2]" /><xsl:value-of select="$results[2]" />
</xsl:template>
<xsl:template match="emoji">
    <xsl:value-of select="regexp:replace(string(.),'s+([^e]*)e+','g','$1$1')" />
</xsl:template>
</xsl:stylesheet>