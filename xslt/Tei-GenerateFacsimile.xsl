<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates a <tei:facsimile/> node with a pre-defined number of <tei:surface/> children. All parameters can be set through the group of variables at the beginning of the stylesheet.</xd:p>
            <xd:p>The variable $vEapIssueId must be changed for every issue of Muqtabas</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    
    <!-- ID / date of issue in EAP: these are formatted as yyyymm and need to be set for each issue. the volumes commence with yyyy02 -->
    <xsl:param name="pEapIssueId" select="'191002'"/>
    <!-- set-off between the EAP, which takes the printed page number as image number and Hathi, which doesn't -->
    <xsl:param name="pImgStartHathiDifference" select="12" as="xs:integer"/>
    <!-- volume in HathTrust collection -->
    <xsl:variable name="vHathiTrustId" select="'umn.319510029968640'"/>
    <!-- volume in EAP collection: needs to be set  -->
    <xsl:variable name="vEapVolumeId" select="'4'"/>
    <xsl:variable name="vFileName" select="concat(translate($vHathiTrustId,'.','-'),'_img-')"/>
    <!-- local path to folder containing the images of this issue -->
    <xsl:variable name="vFilePath" select="'../images/oclc-4770057679_v5/'"/>
    <!-- URL to Hathi, this is always the same -->
    <xsl:variable name="vFileUrlHathi" select="concat('http://babel.hathitrust.org/cgi/imgsrv/image?id=',$vHathiTrustId,';seq=')"/>
    
    
    <!-- URL to EAP, always the same -->
    <xsl:variable name="vFileUrlEap" select="concat('http://eap.bl.uk/EAPDigitalItems/EAP119/EAP119_1_4_',$vEapVolumeId,'-EAP119_muq',$pEapIssueId)"/>
    <xsl:variable name="vPageStart" as="xs:integer">
        <xsl:choose>
            <xsl:when test="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:biblScope[@unit='page']/@from">
                <xsl:value-of select="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:biblScope[@unit='page']/@from"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="7"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vNumberPages" as="xs:integer">
        <xsl:choose>
            <xsl:when test="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:biblScope[@unit='page']/@from and //tei:sourceDesc/tei:biblStruct/tei:monogr/tei:biblScope[@unit='page']/@to">
                <xsl:value-of select="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:biblScope[@unit='page']/@to - //tei:sourceDesc/tei:biblStruct/tei:monogr/tei:biblScope[@unit='page']/@from + 1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="85"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vImgStartHathi" select="1" as="xs:integer"/>
    <!-- $vImgStartHathi - $vPageStart -->
    
    <xsl:variable name="vFacsId" select="'facs_'"/>
    
    <xsl:template match="tei:TEI">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="child::tei:teiHeader"/>
            <xsl:element name="tei:facsimile">
                <xsl:attribute name="xml:id" select="'facs'"/>
                <xsl:call-template name="templCreateFacs">
                    <xsl:with-param name="pStart" select="number($vPageStart)"/>
                    <xsl:with-param name="pStop" select="number($vPageStart + $vNumberPages -1)"/>
                </xsl:call-template>
            </xsl:element>
            <xsl:apply-templates select="child::tei:text"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- copy everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document the changes -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="'#pers_TG'"/>
                <xsl:text>Added </xsl:text><tei:gi>graphic</tei:gi><xsl:text> for </xsl:text>
                <xsl:value-of select="$vNumberPages"/>
                <xsl:text> pages with references to digital images at HathiTrust and EAP.</xsl:text>
                <!--<xsl:text>Created </xsl:text><tei:gi>facsimile</tei:gi><xsl:text> for </xsl:text>
                <xsl:value-of select="$vNumberPages"/>
                <xsl:text> pages with references to a local copy of .tif and .jpeg as well as to the online resource for each page.</xsl:text>-->
            </xsl:element>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate the facsimile -->
    <xsl:template name="templCreateFacs">
        <xsl:param name="pStart" select="1"/>
        <xsl:param name="pStop" select="20"/>
        <xsl:variable name="vStartHathi" select="$pStart + $pImgStartHathiDifference"/>
        <xsl:element name="tei:surface">
            <xsl:attribute name="xml:id" select="concat($vFacsId,$vStartHathi)"/>
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($vFacsId,$vStartHathi,'-g_1')"/>
                <xsl:attribute name="url" select="concat($vFilePath,$vFileName,format-number($vStartHathi,'000'),'.tif')"/>
                <xsl:attribute name="mimeType" select="'image/tiff'"/>
            </xsl:element>
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($vFacsId,$vStartHathi,'-g_2')"/>
                <xsl:attribute name="url" select="concat($vFilePath,$vFileName,format-number($vStartHathi,'000'),'.jpg')"/>
                <xsl:attribute name="mimeType" select="'image/jpeg'"/>
            </xsl:element>
            <!-- link to Hathi -->
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($vFacsId,$vStartHathi,'-g_3')"/>
                <xsl:attribute name="url" select="concat($vFileUrlHathi,$vStartHathi)"/>
                <xsl:attribute name="mimeType" select="'image/jpeg'"/>
            </xsl:element>
            <!-- link to EAP119 -->
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($vFacsId,$vStartHathi,'-g_4')"/>
                <xsl:attribute name="url" select="concat($vFileUrlEap,'_',format-number($pStart,'000'),'_L.jpg')"/>
                <xsl:attribute name="mimeType" select="'image/jpeg'"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="$pStart lt $pStop">
            <xsl:call-template name="templCreateFacs">
                <xsl:with-param name="pStart" select="$pStart +1"/>
                <xsl:with-param name="pStop" select="$pStop"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>