<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns="http://purl.org/rss/1.0/"
    xmlns:enc="http://purl.oclc.org/net/rss_2.0/enc#"
    xmlns:ev="http://purl.org/rss/1.0/modules/event/"
    xmlns:content="http://purl.org/rss/1.0/modules/content/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:syn="http://purl.org/rss/1.0/modules/syndication/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:taxo="http://purl.org/rss/1.0/modules/taxonomy/"
    xmlns:admin="http://webns.net/mvcb/"
    extension-element-prefixes="rdf enc syn dc">
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        {
        "title": "<xsl:value-of select="//dc:title"/>"
        }
    </xsl:template>
    
</xsl:stylesheet>

