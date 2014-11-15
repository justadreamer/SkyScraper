<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:regexp="http://exslt.org/regular-expressions"
                extension-element-prefixes="regexp">

<xsl:template match="c">
  regexp: no+ (case)          string: <xsl:value-of select="." /> result: <xsl:value-of select="regexp:replace(string(.), 'no+', '', 'yes')" />
  regexp: no+ (nocase)        string: <xsl:value-of select="." /> result: <xsl:value-of select="regexp:replace(string(.), 'no+', 'i', 'yEs')" />
  regexp: no+ (case,global)   string: <xsl:value-of select="." /> result: <xsl:value-of select="regexp:replace(string(.), 'no+', 'g', 'yes')" />
  regexp: no+ (nocase,global) string: <xsl:value-of select="." /> result: <xsl:value-of select="regexp:replace(string(.), 'no+', 'gi', 'yEs')" />
</xsl:template>

</xsl:stylesheet>
