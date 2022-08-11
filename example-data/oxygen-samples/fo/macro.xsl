<?xml version='1.0' encoding='ISO-8859-1'?>

<!-- Example from: http://www.renderx.net
    Copyright © 2004 RenderX, Inc.-->
    
<!DOCTYPE xsl:stylesheet [
<!ENTITY DECLARE-MACRO-PARAMETERS "<xsl:param name='arg'/><xsl:param name='arg1'/><xsl:param name='arg2'/><xsl:param name='arg3'/><xsl:param name='arg4'/><xsl:param name='arg5'/><xsl:param name='arg6'/><xsl:param name='arg7'/><xsl:param name='arg8'/><xsl:param name='arg9'/><xsl:param name='argA'/><xsl:param name='argB'/><xsl:param name='argC'/><xsl:param name='argD'/><xsl:param name='counter' select='1'/><xsl:param name='test-number' select='1'/><xsl:param name='subtest-number' select='1'/>">
<!ENTITY WITH-MACRO-PARAMETERS-NO-COUNTER-AND-TEST-NUMBER "<xsl:with-param name='arg' select='$arg'/><xsl:with-param name='arg1' select='$arg1'/><xsl:with-param name='arg2' select='$arg2'/><xsl:with-param name='arg3' select='$arg3'/><xsl:with-param name='arg4' select='$arg4'/><xsl:with-param name='arg5' select='$arg5'/><xsl:with-param name='arg6' select='$arg6'/><xsl:with-param name='arg7' select='$arg7'/><xsl:with-param name='arg8' select='$arg8'/><xsl:with-param name='arg9' select='$arg9'/><xsl:with-param name='argA' select='$argA'/><xsl:with-param name='argB' select='$argB'/><xsl:with-param name='argC' select='$argC'/><xsl:with-param name='argD' select='$argD'/>">

<!ENTITY WITH-MACRO-PARAMETERS-NO-COUNTER "&WITH-MACRO-PARAMETERS-NO-COUNTER-AND-TEST-NUMBER;<xsl:with-param name='test-number' select='$test-number'/><xsl:with-param name='subtest-number' select='$subtest-number'/>">

<!ENTITY WITH-MACRO-PARAMETERS-NO-TEST-NUMBER "&WITH-MACRO-PARAMETERS-NO-COUNTER-AND-TEST-NUMBER;<xsl:with-param name='counter' select='$counter'/>">

<!ENTITY WITH-MACRO-PARAMETERS-NO-SUBTEST-NUMBER "&WITH-MACRO-PARAMETERS-NO-TEST-NUMBER;<xsl:with-param name='test-number' select='$test-number'/>">

<!ENTITY WITH-MACRO-PARAMETERS "&WITH-MACRO-PARAMETERS-NO-COUNTER;<xsl:with-param name='counter' select='$counter'/>">
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:rx="http://www.renderx.com/XSL/Extensions"
                xmlns:xep="http://www.renderx.com/XEP/xep"

                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"

                exclude-result-prefixes="rx svg">

<xsl:output method="xml"
            version="1.0"
            indent="yes"
            encoding="ISO-8859-1"/>

<xsl:param name="image-path">Images/</xsl:param>
<xsl:param name="level">1,2</xsl:param>   <!-- 1=base, 2=main, 3=fallback, 4=all, d=(main-base) -->

<xsl:variable name="dlevel">
  <xsl:call-template name="trans-level">
    <xsl:with-param name="rowval"><xsl:value-of select="normalize-space($level)"/></xsl:with-param>
  </xsl:call-template>
</xsl:variable>

<xsl:template name="trans-level">
  <xsl:param name="rowval"/>
  <xsl:choose>
    <xsl:when test="contains($rowval,'base')">
      <xsl:call-template name="trans-level">
        <xsl:with-param name="rowval"><xsl:value-of select="concat(substring-before($rowval,'base'),'1',substring-after($rowval,'base'))"/></xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($rowval,'main')">
      <xsl:call-template name="trans-level">
        <xsl:with-param name="rowval"><xsl:value-of select="concat(substring-before($rowval,'main'),'2',substring-after($rowval,'main'))"/></xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($rowval,'fallback')">
      <xsl:call-template name="trans-level">
        <xsl:with-param name="rowval"><xsl:value-of select="concat(substring-before($rowval,'fallback'),'3',substring-after($rowval,'fallback'))"/></xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($rowval,'syntactic')">
      <xsl:call-template name="trans-level">
        <xsl:with-param name="rowval"><xsl:value-of select="concat(substring-before($rowval,'syntactic'),'4',substring-after($rowval,'syntactic'))"/></xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="normalize-space($rowval)"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!--                                                                 -->
<!-- This file contains a unified stylesheet for FO testcases.       -->
<!-- Templates defined herein are divided into the following groups: -->
<!--                                                                 -->
<!-- 0. Attribute-copying templates that perform parameter           -->
<!--    substitutions                                                -->
<!--                                                                 -->
<!-- 1. Document structure templates. They produce an output of the  -->
<!--    top-level FO elements - fo:root, fo:layout-page-master, etc. -->
<!--    They are more than one, since different tests require        -->
<!--    different levels of top-level formatting control.            -->
<!--                                                                 -->
<!-- 2. Aliases for common elements, provided for brevity's sake.    -->
<!--    Their attributes are copied to the resulting FO without      -->
<!--    checking.                                                    -->
<!--                                                                 -->
<!-- 3. Handy HTML-style shortcuts for commonly used patterns -      -->
<!--    ordered/unordered lists, bold/italic/underline, etc.         -->
<!--                                                                 -->
<!-- 4. Standard formatting elements needed in every testcase -      -->
<!--    headers, annotation, remarks, etc. etc.                      -->
<!--                                                                 -->
<!-- 5. Special template to ensure transparent passing of FOs        -->
<!--    inserted directly into the source tree.                      -->
<!--                                                                 -->
<!-- 6. Macro-related templates                                      -->
<!--                                                                 -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->

<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!-- 0. Attribute copying & macro parameter substitution             -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->


<!-- =============================================================== -->
<!-- Top-level attribute-copying template                            -->
<!-- =============================================================== -->

<xsl:template match="@*"> &DECLARE-MACRO-PARAMETERS;
  <xsl:attribute name="{name()}">
    <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
    </xsl:call-template>
  </xsl:attribute>
</xsl:template>


<!-- =============================================================== -->
<!-- Main macro expansion template                                   -->
<!-- =============================================================== -->

<xsl:template name="get-expanded-attribute"> &DECLARE-MACRO-PARAMETERS;

  <xsl:choose>
    <!-- If the attribute value is '$arg'/'$arg1'/..., -->
    <!-- replace it with a correspondent parameter     -->
    <xsl:when test=".='$arg'">  <xsl:value-of select="$arg"/>  </xsl:when>
    <xsl:when test=".='$arg1'"> <xsl:value-of select="$arg1"/> </xsl:when>
    <xsl:when test=".='$arg2'"> <xsl:value-of select="$arg2"/> </xsl:when>
    <xsl:when test=".='$arg3'"> <xsl:value-of select="$arg3"/> </xsl:when>
    <xsl:when test=".='$arg4'"> <xsl:value-of select="$arg4"/> </xsl:when>
    <xsl:when test=".='$arg5'"> <xsl:value-of select="$arg5"/> </xsl:when>
    <xsl:when test=".='$arg6'"> <xsl:value-of select="$arg6"/> </xsl:when>
    <xsl:when test=".='$arg7'"> <xsl:value-of select="$arg7"/> </xsl:when>
    <xsl:when test=".='$arg8'"> <xsl:value-of select="$arg8"/> </xsl:when>
    <xsl:when test=".='$arg9'"> <xsl:value-of select="$arg9"/> </xsl:when>
    <xsl:when test=".='$argA'"> <xsl:value-of select="$argA"/> </xsl:when>
    <xsl:when test=".='$argB'"> <xsl:value-of select="$argB"/> </xsl:when>
    <xsl:when test=".='$argC'"> <xsl:value-of select="$argC"/> </xsl:when>
    <xsl:when test=".='$argD'"> <xsl:value-of select="$argD"/> </xsl:when>
    <xsl:when test=".='$counter'"> <xsl:value-of select="$counter"/> </xsl:when>
    <xsl:when test=".='$test-number'"> <xsl:value-of select="$test-number"/> </xsl:when>

    <xsl:when test=".='$subtest-number'"> <xsl:value-of select="$subtest-number"/> </xsl:when>

    <xsl:otherwise>
      <!-- Start recursive expansion of the attribute -->
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string" select="."/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<!-- =============================================================== -->
<!-- Single step of recursive attribute expansion                    -->
<!-- =============================================================== -->

<xsl:template name="expand-attribute-recursively">
  &DECLARE-MACRO-PARAMETERS;
  <xsl:param name="source-string"/>

  <xsl:choose>
    <!-- If a source string contains a substring like {$arg}  -->
    <!-- replace it with a parameter value and call this same -->
    <!-- template once again                                  -->
    <xsl:when test="contains($source-string,'{$arg}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg}')"/>
          <xsl:value-of select="$arg"/>
          <xsl:value-of select="substring-after($source-string,'{$arg}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg1}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg1}')"/>
          <xsl:value-of select="$arg1"/>
          <xsl:value-of select="substring-after($source-string,'{$arg1}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg2}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg2}')"/>
          <xsl:value-of select="$arg2"/>
          <xsl:value-of select="substring-after($source-string,'{$arg2}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg3}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg3}')"/>
          <xsl:value-of select="$arg3"/>
          <xsl:value-of select="substring-after($source-string,'{$arg3}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg4}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg4}')"/>
          <xsl:value-of select="$arg4"/>
          <xsl:value-of select="substring-after($source-string,'{$arg4}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg5}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg5}')"/>
          <xsl:value-of select="$arg5"/>
          <xsl:value-of select="substring-after($source-string,'{$arg5}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg6}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg6}')"/>
          <xsl:value-of select="$arg6"/>
          <xsl:value-of select="substring-after($source-string,'{$arg6}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg7}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg7}')"/>
          <xsl:value-of select="$arg7"/>
          <xsl:value-of select="substring-after($source-string,'{$arg7}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg8}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg8}')"/>
          <xsl:value-of select="$arg8"/>
          <xsl:value-of select="substring-after($source-string,'{$arg8}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$arg9}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$arg9}')"/>
          <xsl:value-of select="$arg9"/>
          <xsl:value-of select="substring-after($source-string,'{$arg9}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$argA}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$argA}')"/>
          <xsl:value-of select="$argA"/>
          <xsl:value-of select="substring-after($source-string,'{$argA}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$argB}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$argB}')"/>
          <xsl:value-of select="$argB"/>
          <xsl:value-of select="substring-after($source-string,'{$argB}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$argC}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$argC}')"/>
          <xsl:value-of select="$argC"/>
          <xsl:value-of select="substring-after($source-string,'{$argC}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$argD}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$argD}')"/>
          <xsl:value-of select="$argD"/>
          <xsl:value-of select="substring-after($source-string,'{$argD}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="contains($source-string,'{$counter}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$counter}')"/>
          <xsl:value-of select="$counter"/>
          <xsl:value-of select="substring-after($source-string,'{$counter}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>


    <xsl:when test="contains($source-string,'{$test-number}')">

      <xsl:call-template name="expand-attribute-recursively">

        &WITH-MACRO-PARAMETERS;

        <xsl:with-param name="source-string">

          <xsl:value-of select="substring-before($source-string,'{$test-number}')"/>

          <xsl:value-of select="$test-number"/>

          <xsl:value-of select="substring-after($source-string,'{$test-number}')"/>

        </xsl:with-param>

      </xsl:call-template>

    </xsl:when>

    <xsl:when test="contains($source-string,'{$subtest-number}')">

      <xsl:call-template name="expand-attribute-recursively">

        &WITH-MACRO-PARAMETERS;

        <xsl:with-param name="source-string">

          <xsl:value-of select="substring-before($source-string,'{$subtest-number}')"/>

          <xsl:value-of select="$subtest-number"/>

          <xsl:value-of select="substring-after($source-string,'{$subtest-number}')"/>

        </xsl:with-param>

      </xsl:call-template>

    </xsl:when>

    <xsl:when test="contains($source-string,'{$image-path}')">
      <xsl:call-template name="expand-attribute-recursively">
        &WITH-MACRO-PARAMETERS;
        <xsl:with-param name="source-string">
          <xsl:value-of select="substring-before($source-string,'{$image-path}')"/>
          <xsl:value-of select="$image-path"/>
          <xsl:value-of select="substring-after($source-string,'{$image-path}')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>


    <!-- If a source string contains an arithmetic expression -->
    <!-- {[...]}, calculate it, paste the result into the     -->
    <!-- source string and call the template once again       -->

    <xsl:when test="contains($source-string,'{[')">
      <xsl:variable name="expr-and-tail"
                    select="substring-after($source-string,'{[')"/>
      <xsl:choose>
        <xsl:when test="contains($expr-and-tail,']}')">

          <xsl:call-template name="expand-attribute-recursively">
            &WITH-MACRO-PARAMETERS;
            <xsl:with-param name="source-string">
              <xsl:value-of select="substring-before($source-string,'{[')"/>

              <xsl:call-template name="evaluate-arithmetic">
                &WITH-MACRO-PARAMETERS;
                <xsl:with-param name="expr">
                  <xsl:value-of select="normalize-space(substring-before($expr-and-tail,']}'))"/>
                </xsl:with-param>
              </xsl:call-template>

              <xsl:value-of select="substring-after($expr-and-tail,']}')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
          <!-- Unmatched '{[': not an expression, ignore and exit -->
          <xsl:value-of select="$source-string"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <!-- No substitutable patterns found; stop recursion -->
      <xsl:value-of select="$source-string"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- =============================================================== -->
<!-- Evaluate arithmetic expression in the string                    -->
<!-- =============================================================== -->

<xsl:template name="evaluate-arithmetic">
  &DECLARE-MACRO-PARAMETERS;
  <xsl:param name="expr"/>

  <xsl:choose>
    <!-- Variable instantiation -->
    <xsl:when test="$expr='$arg'">  <xsl:value-of select="$arg"/>  </xsl:when>
    <xsl:when test="$expr='$arg1'"> <xsl:value-of select="$arg1"/> </xsl:when>
    <xsl:when test="$expr='$arg2'"> <xsl:value-of select="$arg2"/> </xsl:when>
    <xsl:when test="$expr='$arg3'"> <xsl:value-of select="$arg3"/> </xsl:when>
    <xsl:when test="$expr='$arg4'"> <xsl:value-of select="$arg4"/> </xsl:when>
    <xsl:when test="$expr='$arg5'"> <xsl:value-of select="$arg5"/> </xsl:when>
    <xsl:when test="$expr='$arg6'"> <xsl:value-of select="$arg6"/> </xsl:when>
    <xsl:when test="$expr='$arg7'"> <xsl:value-of select="$arg7"/> </xsl:when>
    <xsl:when test="$expr='$arg8'"> <xsl:value-of select="$arg8"/> </xsl:when>
    <xsl:when test="$expr='$arg9'"> <xsl:value-of select="$arg9"/> </xsl:when>
    <xsl:when test="$expr='$argA'"> <xsl:value-of select="$argA"/> </xsl:when>
    <xsl:when test="$expr='$argB'"> <xsl:value-of select="$argB"/> </xsl:when>
    <xsl:when test="$expr='$argC'"> <xsl:value-of select="$argC"/> </xsl:when>
    <xsl:when test="$expr='$argD'"> <xsl:value-of select="$argD"/> </xsl:when>
    <xsl:when test="$expr='$counter'"> <xsl:value-of select="$counter"/> </xsl:when>
    <xsl:when test="$expr='$test-number'"> <xsl:value-of select="$test-number"/> </xsl:when>

    <xsl:when test="$expr='$subtest-number'"> <xsl:value-of select="$subtest-number"/> </xsl:when>


    <!-- Addition -->
    <xsl:when test="contains($expr,'+')">
      <xsl:variable name="op1">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-before($expr,'+'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="op2">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-after($expr,'+'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="result" select="$op1 + $op2"/>
      <xsl:value-of select="$result"/>
    </xsl:when>

    <!-- Subtraction -->
    <xsl:when test="contains($expr,'-')">
      <xsl:variable name="op1">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-before($expr,'-'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="op2">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-after($expr,'-'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="result" select="$op1 - $op2"/>
      <xsl:value-of select="$result"/>
    </xsl:when>

    <!-- Multiplication -->
    <xsl:when test="contains($expr,'*')">
      <xsl:variable name="op1">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-before($expr,'*'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="op2">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-after($expr,'*'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="result" select="$op1 * $op2"/>
      <xsl:value-of select="$result"/>
    </xsl:when>

    <!-- Division -->
    <xsl:when test="contains($expr,'/')">
      <xsl:variable name="op1">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-before($expr,'/'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="op2">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-after($expr,'/'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="result" select="$op1 div $op2"/>
      <xsl:value-of select="$result"/>
    </xsl:when>

    <!-- Modulo -->
    <xsl:when test="contains($expr,'%')">
      <xsl:variable name="op1">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-before($expr,'%'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="op2">
        <xsl:call-template name="evaluate-arithmetic">
          &WITH-MACRO-PARAMETERS;
          <xsl:with-param name="expr">
            <xsl:value-of select="normalize-space(substring-after($expr,'%'))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="result" select="$op1 mod $op2"/>
      <xsl:value-of select="$result"/>
    </xsl:when>

    <!-- Neither operator expression nor variable: should be a number -->
    <xsl:otherwise>
      <xsl:value-of select="$expr"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>



<!-- =============================================================== -->
<!--                                                                 -->
<!-- Multi-pages (for documents with several simple-page-master)     -->
<!--                                                                 -->
<!-- =============================================================== -->


<xsl:template match="list-page">
    <fo:layout-master-set>
          <xsl:apply-templates/>
    </fo:layout-master-set>
</xsl:template>

<xsl:template match="declare-page">
      <fo:simple-page-master master-name="{@name}">
        <fo:region-body region-name="xsl-region-body"
                        margin="0.7in"
                        column-gap="0.25in"
                        border="0.25pt solid gray"
                        padding="6pt"
                        column-count="'{@column-count}'"
                        reference-orientation="{@ref-orientation}">
          <xsl:copy-of select="@column-count"/>
        </fo:region-body>
        <fo:region-before region-name="xsl-region-before"
                          extent="0.7in"
                          display-align="after"
                          padding="6pt 0.7in"/>
        <fo:region-after region-name="xsl-region-after"
                         extent="0.7in"
                         display-align="before"
                         padding="6pt 0.7in"/>
      </fo:simple-page-master>
</xsl:template>


<xsl:template match="page">
    <fo:page-sequence master-reference="{@name}">
      <fo:static-content flow-name="xsl-region-before">
        <fo:list-block font="10pt Helvetica"
                  provisional-distance-between-starts="5in"
                  provisional-label-separation="0in">
          <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
              <fo:block text-align="start" font-weight="bold">
                <xsl:value-of select="title/*|title/text()"/>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <fo:block text-align="end">
                Page <fo:page-number/>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </fo:list-block>
      </fo:static-content>

      <fo:static-content flow-name="xsl-region-after">
        <fo:list-block font="9pt Times"
                  provisional-distance-between-starts="3in"
                  provisional-label-separation="0in">
          <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
              <fo:block text-align="start" font-weight="bold">
                <xsl:text>&#169; </xsl:text>
                <fo:basic-link
                    external-destination="url(http://www.renderx.com/)"
                    color="#0000C0"
                    text-decoration="underline">
                  <xsl:text>Render</xsl:text>
                  <fo:wrapper font-weight="bold" color="#C00000">X</fo:wrapper>
                </fo:basic-link>
                <xsl:text> 2000</xsl:text>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <fo:block text-align="end" font-style="italic" color="#606060">
                XSL Formatting Objects Test Suite
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </fo:list-block>
      </fo:static-content>

      <fo:static-content flow-name="xsl-footnote-separator">
        <fo:block>
           <fo:leader leader-pattern="rule"
                      leader-length="100%"
                      rule-thickness="0.5pt"
                      rule-style="solid"
                      color="black"/>
         </fo:block>
      </fo:static-content>

      <fo:flow flow-name="xsl-region-body">
          <xsl:apply-templates/>
      </fo:flow>

    </fo:page-sequence>
</xsl:template>


<xsl:template match="plain-doc-pages">


  <xsl:comment>
    (c) RenderX, 2002
    This file makes part of the RenderX XSL FO Test Suite. Permission is
    granted to copy and modify this file as a whole or in part, provided
    that any work derived from it bear a reference to the original
    document.
  </xsl:comment>

  <fo:root>
     <xsl:apply-templates/>
  </fo:root>
</xsl:template>

<!-- ================= End of multi-page section =================== -->


<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!--                                                                 -->
<!-- 1. Top-level templates: various document types                  -->
<!--                                                                 -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->


<!-- =============================================================== -->
<!-- Most common template: a document composed of plain pages,       -->
<!-- one or more columns, reasonable margins, nothing special.       -->
<!-- From the second page, we add a header and a page number.        -->
<!-- The header text is specified in the 'header' attribute          -->
<!-- The number of columns is specified in the 'column-count'        -->
<!-- attribute (default is single-column).                           -->
<!-- =============================================================== -->


<xsl:template match="plain-doc">

  <xsl:comment>
    (c) RenderX, 2000
    This file makes part of the RenderX XSL FO Test Suite. Permission is
    granted to copy and modify this file as a whole or in part, provided
    that any work derived from it bear a reference to the original
    document.
  </xsl:comment>

  <fo:root>
    <fo:layout-master-set>
      <fo:simple-page-master master-name="all-pages">
        <fo:region-body region-name="xsl-region-body"
                        margin="0.7in"
                        column-gap="0.25in"
                        border="0.25pt solid gray"
                        padding="6pt">
          <xsl:copy-of select="@column-count"/>
        </fo:region-body>
        <fo:region-before region-name="xsl-region-before"
                          extent="0.7in"
                          display-align="after"
                          padding="6pt 0.7in"/>
        <fo:region-after region-name="xsl-region-after"
                         extent="0.7in"
                         display-align="before"
                         padding="6pt 0.7in"/>
      </fo:simple-page-master>
    </fo:layout-master-set>

    <fo:page-sequence master-reference="all-pages">
      <fo:static-content flow-name="xsl-region-before">
        <fo:list-block font="10pt Helvetica"
                  provisional-distance-between-starts="5in"
                  provisional-label-separation="0in">
          <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
              <fo:block text-align="start" font-weight="bold">
                <xsl:value-of select="title/*|title/text()"/>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <fo:block text-align="end">
                Page <fo:page-number/>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </fo:list-block>
      </fo:static-content>

      <fo:static-content flow-name="xsl-region-after">
        <fo:list-block font="9pt Times"
                  provisional-distance-between-starts="3in"
                  provisional-label-separation="0in">
          <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
              <fo:block text-align="start" font-weight="bold">
                <xsl:text>&#169; </xsl:text>
                <fo:basic-link
                    external-destination="url(http://www.renderx.com/)"
                    color="#0000C0"
                    text-decoration="underline">
                  <xsl:text>Render</xsl:text>
                  <fo:wrapper font-weight="bold" color="#C00000">X</fo:wrapper>
                </fo:basic-link>
                <xsl:text> 2000</xsl:text>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <fo:block text-align="end" font-style="italic" color="#606060">
                XSL Formatting Objects Test Suite
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </fo:list-block>
      </fo:static-content>

      <fo:static-content flow-name="xsl-footnote-separator">
        <fo:block>
           <fo:leader leader-pattern="rule"
                      leader-length="100%"
                      rule-thickness="0.5pt"
                      rule-style="solid"
                      color="black"/>
         </fo:block>
      </fo:static-content>

      <fo:flow flow-name="xsl-region-body">
        <fo:block>
          <xsl:apply-templates/>
         </fo:block>
      </fo:flow>

    </fo:page-sequence>
  </fo:root>
</xsl:template>


<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!--                                                                 -->
<!-- 2. Aliases for common FOs - fo:block, fo:wrapper                -->
<!--                                                                 -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->

<!-- "font" is an alias for fo:wrapper -->

<xsl:template match="font">  &DECLARE-MACRO-PARAMETERS;
  <fo:wrapper>
    <xsl:apply-templates select="*|@*|text()"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:wrapper>
</xsl:template>


<!-- "p" is an alias for fo:block -->

<xsl:template match="p"> &DECLARE-MACRO-PARAMETERS;
  <fo:block>
    <xsl:apply-templates select="*|@*|text()"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:block>
</xsl:template>


<!-- "frame" is used for border/background testing -->

<xsl:template match="frame"> &DECLARE-MACRO-PARAMETERS;
  <fo:block text-align="center"
            font="10pt Helvetica">
    <xsl:choose>
      <xsl:when test="@margin or @margin-bottom"/>
      <xsl:otherwise>
        <xsl:attribute name="margin-bottom">12pt</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="*|@*|text()"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

  </fo:block>
</xsl:template>



<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!--                                                                 -->
<!-- 3. HTML-style shortcuts for simple formatting                   -->
<!--                                                                 -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->


<xsl:template match="b"> &DECLARE-MACRO-PARAMETERS;
  <fo:wrapper font-weight="bold">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:wrapper>
</xsl:template>


<xsl:template match="i"> &DECLARE-MACRO-PARAMETERS;
  <fo:wrapper font-style="italic">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:wrapper>
</xsl:template>


<xsl:template match="u"> &DECLARE-MACRO-PARAMETERS;
  <fo:wrapper text-decoration="underline">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:wrapper>
</xsl:template>



<xsl:template match="code"> &DECLARE-MACRO-PARAMETERS;
  <fo:wrapper font-family="monospace">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:wrapper>
</xsl:template>


<xsl:template match="h1"> &DECLARE-MACRO-PARAMETERS;
  <fo:block font="bold 14pt Helvetica"
            space-before="18pt"
            space-after="6pt"
            keep-with-next.within-column="always"
            keep-together.within-column="always"
            text-align="center">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:block>
</xsl:template>


<xsl:template match="h2"> &DECLARE-MACRO-PARAMETERS;
  <fo:block font="bold 12pt Times"
            space-before="12pt"
            space-after="6pt"
            keep-with-next.within-column="always"
            keep-together.within-column="always"
            text-align="center">
    <fo:wrapper text-decoration="underline">
      <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
      </xsl:apply-templates>
    </fo:wrapper>
  </fo:block>
</xsl:template>


<xsl:template match="h3"> &DECLARE-MACRO-PARAMETERS;
  <fo:block font="bold 12pt Times"
            space-before="6pt"
            space-after="3pt"
            keep-with-next.within-column="always"
            keep-together.within-column="always"
            text-align="start">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:block>
</xsl:template>


<!-- Hyperlink. The destination is presumed external -->

<xsl:template match="a"> &DECLARE-MACRO-PARAMETERS;
  <fo:basic-link external-destination="url({@href})">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:basic-link>
</xsl:template>


<!-- Ordered and unordered lists. They may take any attribute -->
<!-- applicable to fo:list-block                              -->

<xsl:template match="ul|ol"> &DECLARE-MACRO-PARAMETERS;
  <fo:list-block space-before="6pt"
                 space-after="6pt" >

    <xsl:apply-templates select="@*[name()!='label'
                                and name()!='format']"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

    <xsl:apply-templates select="*"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

  </fo:list-block>
</xsl:template>


<!-- List item for an unordered list: default bullet is '-' -->
<!-- List item may take any attribute for fo:list-item      -->

<xsl:template match="ul/li"> &DECLARE-MACRO-PARAMETERS;
  <fo:list-item>

    <xsl:apply-templates select="@*"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

    <fo:list-item-label end-indent="label-end()">
      <fo:block>
        <xsl:choose>
          <xsl:when test="../@label">
            <xsl:value-of select="../@label"/>
          </xsl:when>
          <xsl:otherwise>-</xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </fo:list-item-label>

    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
        </xsl:apply-templates>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<!-- List item for an ordered list: default format is 1. -->
<!-- List item may take any attribute for fo:list-item   -->

<xsl:template match="ol/li"> &DECLARE-MACRO-PARAMETERS;
  <fo:list-item>

    <xsl:apply-templates select="@*"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

    <fo:list-item-label end-indent="label-end()">
      <fo:block>
        <xsl:choose>
          <xsl:when test="../@format">
            <xsl:number level='single'
                        count="li"
                        format="{../@format}"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number level='single'
                        count="li"
                        format="1. "/>

          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </fo:list-item-label>

    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
        </xsl:apply-templates>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<!-- Plain table. This combines fo:table and fo:table-body.   -->
<!-- Attributes are attached to fo:table.                     -->

<xsl:template match="table"> &DECLARE-MACRO-PARAMETERS;
  <fo:table space-before="6pt"
            space-after="6pt">

    <xsl:apply-templates select="@*"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

    <fo:table-body>
      <xsl:apply-templates select="*"> &WITH-MACRO-PARAMETERS;
      </xsl:apply-templates>
    </fo:table-body>

  </fo:table>
</xsl:template>



<!-- Table row. Just an alias for <fo:table-row> -->

<xsl:template match="tr"> &DECLARE-MACRO-PARAMETERS;
  <fo:table-row>

    <xsl:apply-templates select="@*|*"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

  </fo:table-row>
</xsl:template>


<!-- Table cell. This combines fo:table-cell and fo:block.    -->
<!-- Attributes are passed to fo:table-cell.                  -->
<xsl:template match="cell"> &DECLARE-MACRO-PARAMETERS;

  <fo:table-cell>

    <xsl:if test="not(@text-align)">
      <xsl:attribute name="text-align">start</xsl:attribute>
    </xsl:if>

    <xsl:if test="not(@border) and not (@border-width)">
      <xsl:attribute name="border">0.5pt solid black</xsl:attribute>
    </xsl:if>

    <xsl:if test="not(@padding)">
      <xsl:attribute name="padding">6pt</xsl:attribute>
    </xsl:if>

    <xsl:apply-templates select="@*"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

    <fo:block>
       <xsl:apply-templates select="*|text()"> &WITH-MACRO-PARAMETERS;
       </xsl:apply-templates>
    </fo:block>
  </fo:table-cell>
</xsl:template>


<!-- Horizontal rule. It is simpler to get it as a border  -->
<!-- of an empty paragraph; to prevent it from collapsing, -->
<!-- we put a space there by using xsl:text and preserve   -->
<!-- it by setting the suitable 'white-space-collapse'     -->

<xsl:template match="hr">

  <fo:block white-space-collapse="false"
            line-height="6pt"
            space-before="6pt"
            border-top="1.5pt ridge silver">
   <xsl:text>   </xsl:text>
  </fo:block>

</xsl:template>


<!-- Spacer: used to separate frames in border tests. -->
<!-- Same 'white-space-collapse' technique as above.  -->

<xsl:template match="spacer">
  <fo:block white-space-collapse="preserve"
            line-height="12pt">
    <xsl:text>   </xsl:text>
  </fo:block>
</xsl:template>



<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!--                                                                 -->
<!-- 4. Predefined style elements - titles, annotations, etc         -->
<!--                                                                 -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->

<xsl:template match="test/title" priority="2"> &DECLARE-MACRO-PARAMETERS;

  <xsl:variable name="test-title-color"><xsl:choose>

    <xsl:when test="ancestor-or-self::*[@title-color]"><xsl:for-each select="ancestor-or-self::*[@title-color][1]"><xsl:value-of select="@title-color"/></xsl:for-each></xsl:when>

    <xsl:otherwise>black</xsl:otherwise>

  </xsl:choose></xsl:variable>

  <fo:block font="bold 12pt Times"

            color="{$test-title-color}"

            space-before="12pt"

            space-before.conditionality="discard"

            space-after="6pt"

            keep-with-next.within-column="always"

            keep-together.within-column="always"

            text-align="center"

            padding="3pt">

    <fo:wrapper text-decoration="underline">

      <xsl:call-template name="test-number"> &WITH-MACRO-PARAMETERS;

      </xsl:call-template>

      <xsl:text> </xsl:text>

      <xsl:apply-templates> &WITH-MACRO-PARAMETERS;

      </xsl:apply-templates>

    </fo:wrapper>

  </fo:block>

</xsl:template>



<xsl:template match="subtest/title" priority="2"> &DECLARE-MACRO-PARAMETERS;

  <xsl:variable name="subtest-title-color"><xsl:choose>

    <xsl:when test="ancestor-or-self::*[@title-color]"><xsl:for-each select="ancestor-or-self::*[@title-color][1]"><xsl:value-of select="@title-color"/></xsl:for-each></xsl:when>

    <xsl:otherwise>black</xsl:otherwise>

  </xsl:choose></xsl:variable>

  <fo:block font="bold 12pt Times"

            color="{$subtest-title-color}"

            space-before="12pt"

            space-before.conditionality="discard"

            space-after="6pt"

            keep-with-next.within-column="always"

            keep-together.within-column="always"

            text-align="left"

            padding="3pt">

    <fo:wrapper font-style="italic" text-decoration="underline">
      <xsl:call-template name="subtest-number"> &WITH-MACRO-PARAMETERS;

      </xsl:call-template>

      <xsl:text> </xsl:text>

      <xsl:apply-templates> &WITH-MACRO-PARAMETERS;

      </xsl:apply-templates>

    </fo:wrapper>

  </fo:block>

</xsl:template>

<xsl:template match="title" name="title"> &DECLARE-MACRO-PARAMETERS;
  <xsl:variable name="title-color"><xsl:choose>

    <xsl:when test="ancestor-or-self::*[@title-color]"><xsl:for-each select="ancestor-or-self::*[@title-color][1]"><xsl:value-of select="@title-color"/></xsl:for-each></xsl:when>

    <xsl:otherwise>black</xsl:otherwise>

  </xsl:choose></xsl:variable>

  <fo:block font="bold 14pt Helvetica"

            color="{$title-color}"

            space-before="18pt"

            space-before.conditionality="discard"
            space-after="6pt"
            keep-with-next.within-column="always"
            keep-together.within-column="always"
            text-align="center"
            padding="3pt"
            background-color="silver">


    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>


  </fo:block>
</xsl:template>



<xsl:template match="author"> &DECLARE-MACRO-PARAMETERS;
  <fo:block font-weight="bold">
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </fo:block>
</xsl:template>


<xsl:template match="annotation"> &DECLARE-MACRO-PARAMETERS;
  <fo:block font="italic 12pt Times"
            space-before="6pt"
            space-after="6pt"
            text-align="justify">

    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

  </fo:block>
</xsl:template>


<xsl:template match="text"> &DECLARE-MACRO-PARAMETERS;
  <fo:block font="12pt Times"
            space-before="6pt"
            space-after="6pt">

    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

  </fo:block>
</xsl:template>



<xsl:template match="warning"> &DECLARE-MACRO-PARAMETERS;
  <fo:block font="12pt Times"
            space-before="6pt"
            space-after="6pt"
            border="thin solid black"
            text-align="justify"
            padding="3pt">

    <fo:wrapper font-weight="bold"
                color="red"
                keep-with-next.within-line="always">
      WARNING:
    </fo:wrapper>
    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>

  </fo:block>
</xsl:template>


<!-- Footnotes are numbered throughout the whole document -->
<xsl:template match="footnote"> &DECLARE-MACRO-PARAMETERS;
  <fo:footnote>
    <fo:inline baseline-shift="super"
               font-size="75%"
               keep-with-previous.within-line="always">
      <xsl:number level="any"
                  count="//footnote"
                  format="(1)"/>
    </fo:inline>

    <fo:footnote-body>
      <fo:list-block provisional-distance-between-starts="15pt"
                     provisional-label-separation="2pt"
                     space-before="6pt"
                     space-before.conditionality="discard"
                     line-height="1.2"
                     font="9pt Times"

                     start-indent="0"

                     text-indent="0">
        <fo:list-item>

          <fo:list-item-label end-indent="label-end()">
            <fo:block>
              <fo:wrapper keep-together.within-line="always"
                          font-size="75%">
                <xsl:number level="any"
                            count="//footnote"
                            format="(1)"/>
              </fo:wrapper>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()">
            <fo:block padding-before="3pt">
              <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
              </xsl:apply-templates>
            </fo:block>
          </fo:list-item-body>
        </fo:list-item>
      </fo:list-block>
    </fo:footnote-body>
  </fo:footnote>
</xsl:template>

<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!--                                                                 -->
<!-- 5. Pass all fo:*/rx:*/svg:* through, with all their attributes  -->
<!--                                                                 -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->

<xsl:template match="fo:root |
                     fo:declarations |
                     fo:color-profile |
                     fo:page-sequence |
                     fo:layout-master-set |
                     fo:page-sequence-master |
                     fo:single-page-master-reference |
                     fo:repeatable-page-master-reference |
                     fo:repeatable-page-master-alternatives |
                     fo:conditional-page-master-reference |
                     fo:simple-page-master |
                     fo:region-body |
                     fo:region-before |
                     fo:region-after |
                     fo:region-start |
                     fo:region-end |
                     fo:flow |
                     fo:static-content |
                     fo:title |
                     fo:block |
                     fo:block-container |
                     fo:bidi-override |
                     fo:character |
                     fo:initial-property-set |
                     fo:external-graphic |
                     fo:instream-foreign-object |
                     fo:inline |
                     fo:inline-container |
                     fo:leader |
                     fo:page-number |
                     fo:page-number-citation |
                     fo:table-and-caption |
                     fo:table|
                     fo:table-caption |
                     fo:table-column |
                     fo:table-header |
                     fo:table-footer |
                     fo:table-body |
                     fo:table-row |
                     fo:table-cell |
                     fo:list-block |
                     fo:list-item |
                     fo:list-item-body |
                     fo:list-item-label |
                     fo:basic-link |
                     fo:multi-switch |
                     fo:multi-case |
                     fo:multi-toggle |
                     fo:multi-properties |
                     fo:multi-property-set |
                     fo:float |
                     fo:footnote |
                     fo:footnote-body |
                     fo:wrapper |
                     fo:marker |
                     fo:retrieve-marker |
                     rx:flow-section |
                     rx:meta-info |
                     rx:meta-field |
                     rx:outline |
                     rx:bookmark |
                     rx:bookmark-label |
                     rx:page-index"> &DECLARE-MACRO-PARAMETERS;
  <xsl:copy>
    <xsl:apply-templates select="*|@*|text()"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>


<!-- SVG can occur inside fo:foreign-object -->
<xsl:template match="svg:svg |
                     svg:g |
                     svg:defs |
                     svg:desc |
                     svg:title |
                     svg:symbol |
                     svg:use |
                     svg:image |
                     svg:switch |
                     svg:style |
                     svg:path |
                     svg:rect |
                     svg:circle |
                     svg:ellipse |
                     svg:line |
                     svg:polyline |
                     svg:polygon |
                     svg:text |
                     svg:tspan |
                     svg:tref |
                     svg:glyphRun |
                     svg:textPath |
                     svg:altGlyph |
                     svg:altGlyphDef |
                     svg:altGlyphItem |
                     svg:glyphRef |
                     svg:marker |
                     svg:color-profile |
                     svg:color-profile-src |
                     svg:linearGradient |
                     svg:radialGradient |
                     svg:stop |
                     svg:pattern |
                     svg:clipPath |
                     svg:mask |
                     svg:filter |
                     svg:feDistantLight |
                     svg:fePointLight |
                     svg:feSpotLight |
                     svg:feBlend |
                     svg:feColorMatrix |
                     svg:feComponentTransfer |
                     svg:feFuncR |
                     svg:feFuncG |
                     svg:feFuncB |
                     svg:feFuncA |
                     svg:feComposite |
                     svg:feConvolveMatrix |
                     svg:feDiffuseLighting |
                     svg:feDisplacementMap |
                     svg:feFlood |
                     svg:feGaussianBlur |
                     svg:feImage |
                     svg:feMerge |
                     svg:feMergeNode |
                     svg:feMorphology |
                     svg:feOffset |
                     svg:feSpecularLighting |
                     svg:feTile |
                     svg:feTurbulence |
                     svg:cursor |
                     svg:a |
                     svg:view |
                     svg:script |
                     svg:animate |
                     svg:set |
                     svg:animateMotion |
                     svg:mpath |
                     svg:animateColor |
                     svg:animateTransform |
                     svg:font |
                     svg:glyph |
                     svg:missing-glyph |
                     svg:hkern |
                     svg:vkern |
                     svg:font-face |
                     svg:font-face-src |
                     svg:font-face-uri |
                     svg:font-face-format |
                     svg:font-face-name |
                     svg:definition-src |
                     svg:metadata |
                     svg:foreignObject"> &DECLARE-MACRO-PARAMETERS;
  <xsl:copy>
    <xsl:apply-templates select="*|@*|text()"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- Default rule to complain about unrecognized objects -->

<xsl:template match="*" priority="-1"> &DECLARE-MACRO-PARAMETERS;
  <xsl:message>Unknown object: <xsl:value-of select="name()"/></xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="*|@*|text()"> &WITH-MACRO-PARAMETERS;
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>


<xsl:template match="rdf:RDF | rdf:Descriptor"/>


<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->
<!--                                                                 -->
<!-- 6. Macro templates.                                             -->
<!--                                                                 -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -->


<!-- =============================================================== -->
<!-- Macro definition: resolves to nothing.                          -->
<!-- =============================================================== -->

<xsl:template match="define-macro"/>
<xsl:template match="define-macro" mode="get-page-master"/>

<!-- =============================================================== -->
<!-- Macro call: start the recursion loop over repetitions           -->
<!-- =============================================================== -->


<xsl:template match="macro"> &DECLARE-MACRO-PARAMETERS;
  <xsl:variable name="repeat-times">
    <xsl:choose>
      <xsl:when test="@repeat">
        <xsl:for-each select="@repeat">
          <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="expand-macro-loop">
    &WITH-MACRO-PARAMETERS;
    <xsl:with-param name="step-number" select="1"/>
    <xsl:with-param name="steps-to-go" select="$repeat-times"/>
  </xsl:call-template>

</xsl:template>

<!-- =============================================================== -->
<!-- This template manages macro repetition; called recursively      -->
<!-- =============================================================== -->


<xsl:template name="expand-macro-loop">
  &DECLARE-MACRO-PARAMETERS;
  <xsl:param name="step-number"/>
  <xsl:param name="steps-to-go"/>

  <xsl:call-template name="expand-macro">
    &WITH-MACRO-PARAMETERS;
    <xsl:with-param name="step-number" select="$step-number"/>
  </xsl:call-template>

  <xsl:if test="$steps-to-go &gt; 1">
    <xsl:call-template name="expand-macro-loop">
      &WITH-MACRO-PARAMETERS;
      <xsl:with-param name="step-number" select="$step-number + 1"/>
      <xsl:with-param name="steps-to-go" select="$steps-to-go - 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- =============================================================== -->
<!-- This performs real macro expansion. We need a $step-number      -->
<!-- variable, because $counter must keep its previous               -->
<!-- value in order to expand macro arguments properly.              -->
<!-- =============================================================== -->

<xsl:template name="expand-macro">
  &DECLARE-MACRO-PARAMETERS;
  <xsl:param name="step-number"/>

  <xsl:variable name="macroname">
    <xsl:for-each select="@name">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg">
    <xsl:for-each select="@arg">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg1">
    <xsl:for-each select="@arg1">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg2">
    <xsl:for-each select="@arg2">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg3">
    <xsl:for-each select="@arg3">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg4">
    <xsl:for-each select="@arg4">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>


  <xsl:variable name="macroarg5">
    <xsl:for-each select="@arg5">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg6">
    <xsl:for-each select="@arg6">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg7">
    <xsl:for-each select="@arg7">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg8">
    <xsl:for-each select="@arg8">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroarg9">
    <xsl:for-each select="@arg9">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroargA">
    <xsl:for-each select="@argA">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroargB">
    <xsl:for-each select="@argB">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroargC">
    <xsl:for-each select="@argC">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="macroargD">
    <xsl:for-each select="@argD">
      <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>


  <xsl:for-each select="//define-macro">
    <xsl:if test="@name=$macroname">
      <xsl:apply-templates select="node()">
        <xsl:with-param name="arg"  select="$macroarg"/>
        <xsl:with-param name="arg1" select="$macroarg1"/>
        <xsl:with-param name="arg2" select="$macroarg2"/>
        <xsl:with-param name="arg3" select="$macroarg3"/>
        <xsl:with-param name="arg4" select="$macroarg4"/>
        <xsl:with-param name="arg5" select="$macroarg5"/>
        <xsl:with-param name="arg6" select="$macroarg6"/>
        <xsl:with-param name="arg7" select="$macroarg7"/>
        <xsl:with-param name="arg8" select="$macroarg8"/>
        <xsl:with-param name="arg9" select="$macroarg9"/>
        <xsl:with-param name="argA" select="$macroargA"/>
        <xsl:with-param name="argB" select="$macroargB"/>
        <xsl:with-param name="argC" select="$macroargC"/>
        <xsl:with-param name="argD" select="$macroargD"/>
        <xsl:with-param name="counter" select="$step-number"/>

      </xsl:apply-templates>
    </xsl:if>
  </xsl:for-each>
</xsl:template>


<!-- =============================================================== -->
<!-- Parameter substitution templates                                -->
<!-- =============================================================== -->


<xsl:template match="arg">
  <xsl:param name="arg"/>
  <xsl:value-of select="$arg"/>
</xsl:template>

<xsl:template match="arg1">
  <xsl:param name="arg1"/>
  <xsl:value-of select="$arg1"/>
</xsl:template>

<xsl:template match="arg2">
  <xsl:param name="arg2"/>
  <xsl:value-of select="$arg2"/>
</xsl:template>

<xsl:template match="arg3">
  <xsl:param name="arg3"/>
  <xsl:value-of select="$arg3"/>
</xsl:template>

<xsl:template match="arg4">
  <xsl:param name="arg4"/>
  <xsl:value-of select="$arg4"/>
</xsl:template>

<xsl:template match="arg5">
  <xsl:param name="arg5"/>
  <xsl:value-of select="$arg5"/>
</xsl:template>

<xsl:template match="arg6">
  <xsl:param name="arg6"/>
  <xsl:value-of select="$arg6"/>
</xsl:template>

<xsl:template match="arg7">
  <xsl:param name="arg7"/>
  <xsl:value-of select="$arg7"/>
</xsl:template>

<xsl:template match="arg8">
  <xsl:param name="arg8"/>
  <xsl:value-of select="$arg8"/>
</xsl:template>

<xsl:template match="arg9">
  <xsl:param name="arg9"/>
  <xsl:value-of select="$arg9"/>
</xsl:template>

<xsl:template match="argA">
  <xsl:param name="argA"/>
  <xsl:value-of select="$argA"/>
</xsl:template>

<xsl:template match="argB">
  <xsl:param name="argB"/>
  <xsl:value-of select="$argB"/>
</xsl:template>

<xsl:template match="argC">
  <xsl:param name="argC"/>
  <xsl:value-of select="$argC"/>
</xsl:template>

<xsl:template match="argD">
  <xsl:param name="argD"/>
  <xsl:value-of select="$argD"/>
</xsl:template>

<xsl:template match="counter">
  <xsl:param name="counter"/>
  <xsl:value-of select="$counter"/>
</xsl:template>


<!-- =============================================================== -->
<!-- This template generates a text from an arithmetic expression    -->
<!-- =============================================================== -->

<xsl:template match="formula"> &DECLARE-MACRO-PARAMETERS;
  <xsl:call-template name="evaluate-arithmetic">
    &WITH-MACRO-PARAMETERS;
    <xsl:with-param name="expr" select="@expr"/>
  </xsl:call-template>
</xsl:template>


<!-- =============================================================== -->
<!-- Repetition template: loop start                                 -->
<!-- =============================================================== -->

<xsl:template match="repeat"> &DECLARE-MACRO-PARAMETERS;

  <xsl:variable name="repeat-from">
    <xsl:choose>
      <xsl:when test="@from">
        <xsl:for-each select="@from">
          <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="repeat-step">
    <xsl:choose>
      <xsl:when test="@step">
        <xsl:for-each select="@step">
          <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="repeat-to">
    <xsl:choose>
      <xsl:when test="@times">
        <xsl:variable name="repeat-times">
          <xsl:for-each select="@times">
            <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
            </xsl:call-template>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$repeat-from + ($repeat-step * $repeat-times) - $repeat-step"/>
      </xsl:when>

      <xsl:when test="@to">
        <xsl:for-each select="@to">
          <xsl:call-template name="get-expanded-attribute"> &WITH-MACRO-PARAMETERS;
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>


      <xsl:otherwise>
        <xsl:value-of select="$repeat-from"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:call-template name="expand-repetition-loop">
    &WITH-MACRO-PARAMETERS-NO-COUNTER;
    <xsl:with-param name="counter" select="$repeat-from"/>
    <xsl:with-param name="repeat-to" select="$repeat-to"/>
    <xsl:with-param name="step" select="$repeat-step"/>

  </xsl:call-template>

</xsl:template>

<!-- =============================================================== -->
<!-- Single recursion step for repetition loop                       -->
<!-- =============================================================== -->

<xsl:template name="expand-repetition-loop">
  &DECLARE-MACRO-PARAMETERS;
  <xsl:param name="repeat-to"/>
  <xsl:param name="step"/>

  <xsl:variable name="next-counter" select="$counter + $step"/>

  <!-- Generate one more instance of the repeated text -->
  <xsl:apply-templates> &WITH-MACRO-PARAMETERS;
  </xsl:apply-templates>

  <xsl:choose>
    <!-- Check if it is time to stop recursion -->
    <xsl:when test ="$next-counter &gt; $repeat-to and $step &gt; 0"/>
    <xsl:when test ="$next-counter &lt; $repeat-to and $step &lt; 0"/>

    <!-- Calculate new iteration parameters and continue recursion -->
    <xsl:otherwise>
      <xsl:call-template name="expand-repetition-loop">
        &WITH-MACRO-PARAMETERS-NO-COUNTER;
        <xsl:with-param name="counter" select="$next-counter"/>
        <xsl:with-param name="repeat-to" select="$repeat-to"/>
        <xsl:with-param name="step" select="$step"/>
      </xsl:call-template>
    </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<!-- =============================================================== -->

<!-- Test and test number                                            -->

<!-- =============================================================== -->



<xsl:template match="test"> &DECLARE-MACRO-PARAMETERS;

  <xsl:variable name="curlevel"><xsl:choose>

      <xsl:when test="@level"><xsl:call-template name="trans-level"><xsl:with-param name="rowval"><xsl:value-of select="normalize-space(@level)"/></xsl:with-param></xsl:call-template></xsl:when>

      <xsl:otherwise>1</xsl:otherwise>

    </xsl:choose>

  </xsl:variable>

  <xsl:if test="contains($dlevel,$curlevel)">

    <xsl:variable name="break">

      <xsl:choose>

        <xsl:when test="@break"><xsl:value-of select="@break"/></xsl:when>

        <xsl:otherwise>column</xsl:otherwise>

      </xsl:choose>

    </xsl:variable>

    <fo:block break-after="{$break}">

      <xsl:variable name="test-n"><xsl:number count="test[(@level and contains($dlevel,@level)) or (not(@level) and contains($dlevel,'1'))]" format="1."/></xsl:variable>

      <xsl:apply-templates> &WITH-MACRO-PARAMETERS-NO-TEST-NUMBER;

        <xsl:with-param name="test-number" select="$test-n"/>

      </xsl:apply-templates>

    </fo:block>

  </xsl:if>

</xsl:template>



<xsl:template match="subtest"> &DECLARE-MACRO-PARAMETERS;

  <xsl:variable name="cursublevel"><xsl:choose>

      <xsl:when test="@level"><xsl:call-template name="trans-level"><xsl:with-param name="rowval"><xsl:value-of select="normalize-space(@level)"/></xsl:with-param></xsl:call-template></xsl:when>

      <xsl:otherwise><xsl:value-of select="$dlevel"/></xsl:otherwise>

    </xsl:choose>

  </xsl:variable>

  <xsl:if test="contains($dlevel,$cursublevel)">

    <xsl:variable name="subbreak">

      <xsl:choose>

        <xsl:when test="@break"><xsl:value-of select="@break"/></xsl:when>

        <xsl:otherwise>auto</xsl:otherwise>

      </xsl:choose>

    </xsl:variable>

    <fo:block break-after="{$subbreak}">

      <xsl:variable name="subtest-n"><xsl:number count="subtest[(@level and contains($dlevel,@level)) or (not(@level))]" format="1."/></xsl:variable>

      <xsl:apply-templates> &WITH-MACRO-PARAMETERS-NO-SUBTEST-NUMBER;

        <xsl:with-param name="subtest-number" select="$subtest-n"/>

      </xsl:apply-templates>

    </fo:block>

  </xsl:if>

</xsl:template>



<xsl:template match="test-number" name="test-number">

  <xsl:param name="test-number"/>

  <xsl:value-of select="$test-number"/>

</xsl:template>



<xsl:template match="subtest-number" name="subtest-number">

  <xsl:param name="test-number"/>

  <xsl:param name="subtest-number"/>

  <xsl:value-of select="concat($test-number,$subtest-number)"/>

</xsl:template>



<xsl:template match="level"> &DECLARE-MACRO-PARAMETERS;

  <xsl:variable name="curllevel"><xsl:choose>

      <xsl:when test="@level"><xsl:call-template name="trans-level"><xsl:with-param name="rowval"><xsl:value-of select="normalize-space(@level)"/></xsl:with-param></xsl:call-template></xsl:when>

      <xsl:otherwise>1</xsl:otherwise>

    </xsl:choose>

  </xsl:variable>

  <xsl:if test="contains($dlevel,$curllevel)">

    <xsl:apply-templates> &WITH-MACRO-PARAMETERS;

    </xsl:apply-templates>

  </xsl:if>

</xsl:template>



<xsl:template match="@title-color" priority="2"/>




</xsl:stylesheet>

