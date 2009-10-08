<%@ page language="java" %>
<%@ page errorPage="/common/Error.jsp" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html-el" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-logic-el" prefix="logic" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-tiles" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/hq.tld" prefix="hq" %>

<tiles:importAttribute name="resource" ignore="true"/>
<tiles:importAttribute name="resourceOwner" ignore="true"/>
<tiles:importAttribute name="showLocation" ignore="true"/>
<tiles:importAttribute name="showRecursive" ignore="true"/>
<tiles:importAttribute name="locationRequired" ignore="true"/>

<c:choose>
  <c:when test="${not empty resourceOwner}">
    <hq:owner var="ownerStr" owner="${resourceOwner}"/>
  </c:when>
  <c:otherwise>
    <hq:owner var="ownerStr" owner="${sessionScope.webUser}"/>
  </c:otherwise>
</c:choose>

<hq:constant
    classname="org.rhq.enterprise.server.legacy.appdef.shared.AppdefEntityConstants"
    symbol="APPDEF_TYPE_PLATFORM" var="PLATFORM" />
<hq:constant
    classname="org.rhq.enterprise.server.legacy.appdef.shared.AppdefEntityConstants"
    symbol="APPDEF_TYPE_SERVER" var="SERVER" />
<hq:constant
    classname="org.rhq.enterprise.server.legacy.appdef.shared.AppdefEntityConstants"
    symbol="APPDEF_TYPE_SERVICE" var="SERVICE" />
<hq:constant
    classname="org.rhq.enterprise.server.legacy.appdef.shared.AppdefEntityConstants"
    symbol="APPDEF_TYPE_APPLICATION" var="APPLICATION" />
<hq:constant
    classname="org.rhq.enterprise.server.legacy.appdef.shared.AppdefEntityConstants"
    symbol="APPDEF_TYPE_GROUP" var="GROUP" />

<!--  GENERAL PROPERTIES TITLE -->
<tiles:insert definition=".header.tab">
  <tiles:put name="tabKey" value="resource.common.inventory.props.GeneralPropertiesTab"/>
</tiles:insert>
<!--  /  -->

<tiles:insert definition=".portlet.confirm"/>
<tiles:insert definition=".portlet.error"/>

<!--  GENERAL PROPERTIES CONTENTS -->
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<logic:messagesPresent property="serviceType">
<tr>
    <td width="30%" class="ErrorField" colspan="3">
      <span class="ErrorFieldContent">- <html:errors property="serviceType"/></span>
      </td>
</tr>
</logic:messagesPresent>
  <tr valign="top">
    <td width="20%" class="BlockLabel"><html:img page="/images/icon_required.gif" width="9" height="9" border="0"/><fmt:message key="common.label.Name"/></td>
<c:choose>
<c:when test="${resource.entityId.type == SERVICE && resource.server.runtimeAutodiscovery == true}">
<logic:messagesNotPresent property="name">
    <td width="30%" class="BlockContent">
      <html:text disabled="true" size="30" property="name"/><br>
      <html:hidden property="name"/>
    </td>
</logic:messagesNotPresent>
</c:when>
<c:otherwise>
<logic:messagesPresent property="name">
    <td width="30%" class="ErrorField">
      <html:text size="30" property="name"/><br>
      <span class="ErrorFieldContent">- <html:errors property="name"/></span>
    </td>
</logic:messagesPresent>
<logic:messagesNotPresent property="name">
    <td width="30%" class="BlockContent">
      <html:text size="30" property="name"/><br>
    </td>
</logic:messagesNotPresent>
</c:otherwise>
</c:choose>
    <td width="20%" class="BlockLabel"><fmt:message key="resource.common.inventory.props.OwnerLabel"/></td>
    <td width="30%" class="BlockContent"><c:out value="${ownerStr}" escapeXml="false"/></td>
  </tr>
  <tr valign="top">
    <td width="20%" class="BlockLabel"><fmt:message key="common.label.Description"/></td>

<logic:messagesPresent property="description">
    <td width="30%" class="ErrorField">
     <html:textarea cols="35" rows="3" property="description" />
      <span class="ErrorFieldContent">- <html:errors property="description"/></span>
    </td>
</logic:messagesPresent>
<logic:messagesNotPresent property="description">
    <td width="30%" class="BlockContent">
     <html:textarea cols="35" rows="3" property="description" /> 
    </td>
</logic:messagesNotPresent>

<c:choose>
  <c:when test="${not empty showLocation}">
    <td width="20%" class="BlockLabel">
        <c:if test="${not empty locationRequired}">
            <html:img page="/images/icon_required.gif" width="9" height="9" border="0"/>
        </c:if>
    <fmt:message key="resource.common.inventory.props.LocationLabel"/></td>
    <logic:messagesPresent property="location">
    <td width="30%" class="ErrorField">
      <html:text size="30" maxlength="100" property="location"/><br>
      <span class="ErrorFieldContent">- <html:errors property="location"/></span>
    </td>
    </logic:messagesPresent>
    <logic:messagesNotPresent property="location">
        <td width="30%" class="BlockContent"><html:text size="30" maxlength="50" property="location"/></td>
    </logic:messagesNotPresent>
  </c:when>
  <c:otherwise>
    <td width="20%" class="BlockLabel">&nbsp;</td>
    <td width="30%" class="BlockContent">&nbsp;</td>
  </c:otherwise>
</c:choose>
  </tr>
  <tr>
    <td colspan="4" class="BlockBottomLine"><html:img page="/images/spacer.gif" width="1" height="1" border="0"/></td>
  </tr>
</table>
<!--  /  -->
