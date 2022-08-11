<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes"/>
    <xsl:param name="showBankInformation" select="'true'"/>
    <xsl:template match="/">
        <xsl:variable name="totalCost">
            <xsl:call-template name="sum">
                <xsl:with-param name="index" select="1"/>
                <xsl:with-param name="n" select="count(/invoice/products/product)"/>
            </xsl:call-template>
        </xsl:variable>
        <fo:root>
            <fo:layout-master-set>
                <!-- A4 size -->
                <fo:simple-page-master master-name="invoice" page-height="29.7cm" page-width="21cm">
                  <fo:region-body margin="1in 1in"/>
                  <fo:region-before extent="1in" display-align="after"/>
                  <fo:region-after extent="1in" display-align="after"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="invoice">
                <!-- 
                Header
                -->
                <fo:static-content flow-name="xsl-region-before">
                    <fo:block font="10pt Arial" text-align="center" padding="0.5in">
                        <fo:inline font-size="250%">
                            <fo:inline font-style="italic">
                                <xsl:if test="/invoice/@type='proforma'">Proforma Invoice - FO Sample</xsl:if>
                                <xsl:if test="/invoice/@type='normal'">Invoice - FO Sample</xsl:if>
                                <xsl:if test="/invoice/@type='quote'">Quote - FO Sample</xsl:if>
                            </fo:inline>
                        </fo:inline>
                    </fo:block>
                </fo:static-content>
                <!--
                Footer 
                -->
                <fo:static-content flow-name="xsl-region-after" font-size="80%" text-align="center">
                    <fo:block>
                        <fo:leader leader-length="80%" leader-pattern="rule"
                            alignment-baseline="middle" rule-thickness="0.5pt" color="black"/>
                    </fo:block>
                    <fo:block>Bindery Soft srl - www.binderysoft.com - email to:
                        sales@binderysoft.com - tel +99-341-464822 - tel/fax +99-341-464824</fo:block>
                </fo:static-content>
                <!--
                Content
                -->
                <fo:flow flow-name="xsl-region-body" font="14pt Times">
                    <!-- Supplier and customer -->
                    <fo:table table-layout="fixed" width="100%" padding="0.1in">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row font-weight="bold">
                                <fo:table-cell padding="0.1in">
                                    <fo:block>Supplier:</fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding="0.1in">
                                    <fo:block>Customer:</fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block>SC BINDERY SOFT SRL</fo:block>
                                    <fo:block>42 North Street</fo:block>
                                    <fo:block>200782 Portos</fo:block>
                                    <fo:block>France</fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:apply-templates select="//customer/block"/>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block>Register of companies: J16364/1998</fo:block>
                                    <fo:block>VAT Reg. No. 50559959</fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:if test="/invoice/customer/vat">
                                        <fo:block>VAT Reg. No. <xsl:value-of select="/invoice/customer/vat"/></fo:block>
                                    </xsl:if>
                                  <fo:block/>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:block padding="0.1in"/>
                    <!--
                    Bank.
                    -->
                    <xsl:if test="$showBankInformation='true'">
                        <fo:block font-weight="bold" padding="0.1in"> Bank Information:</fo:block>
                        <fo:block>Comercial Bank ITC</fo:block>
                        <fo:block>Wave Str. nr. 3, Bloc 1-3-5</fo:block>
                        <fo:block>220409 Portos</fo:block>
                        <fo:block>SWIFT: CXITXOBU</fo:block>
                        <xsl:choose>
                            <xsl:when test="invoice/@currency = 'USD'">
                                <fo:block>Account number: XX6 YZT 1710 1186 7100 2000</fo:block>
                            </xsl:when>
                            <xsl:when test="invoice/@currency = 'GBP'">
                                <fo:block>Account number: XX6 YZT 1710 1186 7100 4000</fo:block>
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:block>Account number: XX6 YZT 1710 1186 7100 3000</fo:block>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <!--
                    Info about the invoice, appears fully only for proforma and normal invoice.
                    -->
                    <fo:block padding="0.2in"/>
                    <fo:block margin-left="1in" font-weight="bold">
                        <xsl:if test="/invoice/@type='proforma' or /invoice/@type='normal'">
                            <fo:block>
                                <xsl:if test="/invoice/@type='proforma'"> Proforma </xsl:if> Invoice
                                Number: <xsl:value-of select="/invoice/@number"/>
                            </fo:block>
                            <fo:block>Payment method: <xsl:value-of select="invoice/payment-method"/>
                            </fo:block>
                            <fo:block>Date: <xsl:value-of select="invoice/date"/>
                            </fo:block>
                            <fo:block>Delivery: <xsl:value-of select="invoice/delivery"/>
                            </fo:block>
                        </xsl:if>
                        <xsl:if test="/invoice/@type='quote'">
                            <fo:block>Date: <xsl:value-of select="invoice/date"/>
                            </fo:block>
                            <fo:block>Delivery: <xsl:value-of select="invoice/delivery"/>
                            </fo:block>
                        </xsl:if>
                    </fo:block>
                    <fo:block padding="0.2in"/>
                    <!--
            Quantities.
            -->
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="0.5in"/>
                        <fo:table-column column-width="4in"/>
                        <fo:table-column column-width="0.9in"/>
                        <fo:table-column column-width="0.9in"/>
                        <fo:table-body>
                            <fo:table-row font-weight="bold">
                                <fo:table-cell border="thin silver ridge" background-color="silver">
                                    <fo:block>Qty</fo:block>
                                </fo:table-cell>
                                <fo:table-cell border="thin silver ridge" background-color="silver">
                                    <fo:block>Product</fo:block>
                                </fo:table-cell>
                                <fo:table-cell border="thin silver ridge" background-color="silver">
                                    <fo:block>Unit Cost</fo:block>
                                </fo:table-cell>
                                <fo:table-cell border="thin silver ridge" background-color="silver">
                                    <fo:block>Total Cost</fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:apply-templates select="//product"/>
                        </fo:table-body>
                    </fo:table>
                    <fo:block>
                        <fo:leader/>
                    </fo:block>
                    <fo:block padding="0.1in"/>
                    <!-- The total -->
                    <fo:table table-layout="fixed" width="100%" padding="0.1in">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="1in"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block>Total:</fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block>
                                        <xsl:value-of select="$totalCost"/>
                                        <xsl:text xml:space="preserve"> </xsl:text>
                                        <xsl:value-of select="/invoice/@currency"/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <!-- Signature -->
                    <fo:block padding="0.2in"/>
                    <fo:block text-align="right" padding="0.1in">
                        <fo:block>Checked by: </fo:block>
                        <fo:inline font-style="italic" font-weight="bold">
                            <xsl:value-of select="/invoice/checked-by"/>
                        </fo:inline>
                    </fo:block>
                    <fo:block padding="0.1in"/>
                    <xsl:if test="/invoice/@type='proforma'">
                        <fo:block font-weight="bold">Please ensure that the full proforma invoice
                            amount is transferred to our account (i.e. Bank charges should not be deducted).</fo:block>
                        <fo:block font-weight="bold"> We will send you the final invoice as soon as
                            we receive the amount in our account, or you confirm the payment. </fo:block>
                    </xsl:if>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    <xsl:template match="block">
        <fo:block>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    <xsl:template match="product">
        <fo:table-row>
            <fo:table-cell border="thin silver ridge">
                <fo:block>
                    <xsl:value-of select="quantity"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border="thin silver ridge">
                <fo:block>
                    <xsl:value-of select="description"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border="thin silver ridge">
                <fo:block text-align="right">
                    <xsl:value-of select="unit-cost"/>
                    <xsl:text xml:space="preserve"> </xsl:text>
                    <xsl:value-of select="/invoice/@currency"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border="thin silver ridge">
                <fo:block text-align="right">
                    <xsl:value-of select="quantity*unit-cost"/>
                    <xsl:text xml:space="preserve"> </xsl:text>
                    <xsl:value-of select="/invoice/@currency"/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <xsl:template name="sum">
        <xsl:param name="index" select="1"/>
        <xsl:param name="n" select="0"/>
        <xsl:choose>
            <xsl:when test="$index &gt; $n">
                <xsl:value-of select="0"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sum2">
                    <xsl:call-template name="sum">
                        <xsl:with-param name="index" select="$index+1"/>
                        <xsl:with-param name="n" select="$n"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$sum2 + /invoice/products/product[position()=$index]/quantity * /invoice/products/product[position()=$index]/unit-cost"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*"/>
</xsl:stylesheet>
