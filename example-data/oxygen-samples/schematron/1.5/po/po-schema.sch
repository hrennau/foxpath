<!-- Schematron structural schema to validate purchase orders -->
<!-- Note: content models are treated as "open". -->
<!-- 2001-06-13 -->
<!--
 Copyright (c) 2001 Rick Jelliffe, Topologi Pty/ Ltd 

 This software is provided 'as-is', without any express or implied warranty. 
 In no event will the authors be held liable for any damages arising from 
 the use of this software.

 Permission is granted to anyone to use this software for any purpose, 
 including commercial applications, and to alter it and redistribute it freely,
 subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not claim
 that you wrote the original software. If you use this software in a product, 
 an acknowledgment in the product documentation would be appreciated but is 
 not required.

 2. Altered source versions must be plainly marked as such, and must not be 
 misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
-->

<schema  xmlns="http://www.ascc.net/xml/schematron">	<title>Schema for Purchase Order Example</title>
	<pattern name="Purchase Orders">
		<rule context="*[shipTo or billTo or items]">
		<!-- This rule couples the elements of the address type together, so that
			if one appears anywhere, the others must also. -->
			<assert test="shipTo"   icon="bug_10.gif"
			>A purchase order should have a  shipTo element.</assert>
			<assert test="billTo"   icon="bug_10.gif"
			>A purchase order should have a billTo element.</assert>
			<assert test="items"   icon="bug_10.gif"
			>A purchase order should have an items element.</assert>
	                                       <assert test="@orderDate"   icon="bug_10.gif"
			>A purchase order should have an orderDate attribute.</assert>
			<assert test="*//shipDate"   icon="bug_10.gif"
			>A purchase order should have an shipDate element.</assert>
		</rule>
		<rule context="/shipTo | /billTo | /items">
			<report test="self::*"   icon="bug_11.gif"
			>The element <name/> is not expected
			at the top of a document. It should be in
			the body of a purchase order.</report>
		</rule>
	</pattern>
	<pattern name="US Address" >

	<!-- This pattern simulates complex types: we don't care about the
                     element name, but we desire certain children -->
		<rule context="*[name or street or  city or state or zip]">
		<!-- This rule couples the elements of the address type together, so that
		if one appears anywhere, the others must also. -->
			<assert test="name"  icon="bug_10.gif"
			>An address should have a name.</assert>
			<assert test="street"  icon="bug_10.gif"
			>An address should have a street.</assert>
			<assert test="city"  icon="bug_10.gif"
			>An address should have a city.</assert>
			<assert test="state"  icon="bug_10.gif"
			>An address should have a state.</assert>
			<assert test="zip"  icon="bug_10.gif"
			>An address should have a zip.</assert>
		</rule>
		<rule context="/street | /name | /city | /state | /zip">
		<report test="self::*"   icon="bug_11.gif"
		>The elements <name/> is not expected at
		the top of a document. They form part of an address.</report>
		</rule>
		</pattern>
		
		<!-- Next, the specific elements -->
		<pattern name="Specific Elements">
				<rule context="items">
				<assert test="count(child::*) = count(child::item)"   icon="bug_11.gif"
				>The items element can only contain item elements</assert>
				</rule>
				<rule context="item">
				<assert test="productName"   icon="bug_10.gif"
				>The item element should contain a product name. </assert>
				<assert test="quantity"   icon="bug_10.gif"
				>The item element should contain a quantity element </assert>
				<assert test="USPrice"   icon="bug_10.gif"
				>The item element should contain a USPrice element.  </assert>
				</rule> 
				<rule context="comment"  >
				<report test="child::*"   icon="bug_7.gif"
				>A comment should have no subelements</report >
				<assert test="parent::item | parent::purchaseOrder "   
			icon="bug_7.gif"
			>A comment can only appear in an item or a purchase Order</assert>
			</rule>
		</pattern>
</schema>