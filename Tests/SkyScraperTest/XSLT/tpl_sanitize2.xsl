<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str">

    <xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_common_sanitize">
        <xsl:param name="text" />
        <!--first escape all original backslashes-->
        <xsl:param name="text1" select="str:replace($text,'&#92;','\&#92;')"/>

        <!--escape all quote with backslashes-->
        <xsl:param name="text2" select="str:replace($text1,'&quot;','\&quot;')"/>

        <!--output-->
        <xsl:copy-of select="$text2"/>
    </xsl:template>
    
    <xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_sanitize">
        <xsl:param name="text" />
        <xsl:param name="text1">
		<xsl:call-template name="tpl_common_sanitize">
			<xsl:with-param name="text" select="$text"/>
		</xsl:call-template>
	</xsl:param>
        
        <xsl:param name="text2" select="normalize-space($text1)"/>
        
        <!--output-->
        <xsl:copy-of select="$text2"/>
    </xsl:template>
    
    <xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_sanitize_textarea">
        <xsl:param name="text" />
        <xsl:param name="text1">
                <xsl:call-template name="tpl_common_sanitize">
                        <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>
        </xsl:param>
 
        <xsl:param name="text2" select="str:replace($text1,'&#10;','\n')"/>
        
        <xsl:copy-of select="$text2"/>
    </xsl:template>
    
</xsl:stylesheet>
