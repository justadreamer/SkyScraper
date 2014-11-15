<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:regexp="http://exslt.org/regular-expressions"
                extension-element-prefixes="regexp">

	<xsl:template match="c">
         regexp: no* (case)   string: <xsl:value-of select="." /> result: <xsl:value-of select="regexp:test(string(.), 'no*', 'g')" />
         regexp: no* (nocase) string: <xsl:value-of select="." /> result: <xsl:value-of select="regexp:test(string(.), 'no*', 'gi')" />
	</xsl:template>

</xsl:stylesheet>
