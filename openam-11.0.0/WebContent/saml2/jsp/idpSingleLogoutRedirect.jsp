<%--
   DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
  
   Copyright (c) 2006 Sun Microsystems Inc. All Rights Reserved
  
   The contents of this file are subject to the terms
   of the Common Development and Distribution License
   (the License). You may not use this file except in
   compliance with the License.

   You can obtain a copy of the License at
   https://opensso.dev.java.net/public/CDDLv1.0.html or
   opensso/legal/CDDLv1.0.txt
   See the License for the specific language governing
   permission and limitations under the License.

   When distributing Covered Code, include this CDDL
   Header Notice in each file and include the License file
   at opensso/legal/CDDLv1.0.txt.
   If applicable, add the following below the CDDL Header,
   with the fields enclosed by brackets [] replaced by
   your own identifying information:
   "Portions Copyrighted [year] [name of copyright owner]"

   $Id: idpSingleLogoutRedirect.jsp,v 1.9 2009/06/12 22:21:42 mallas Exp $

--%>

<%--
   Portions Copyrighted 2013 ForgeRock AS
--%>


<%@ page import="com.sun.identity.saml.common.SAMLUtils" %>
<%@ page import="com.sun.identity.saml2.common.SAML2Utils" %>
<%@ page import="com.sun.identity.saml2.common.SAML2Constants" %>
<%@ page import="com.sun.identity.saml2.common.SAML2Exception" %>
<%@ page import="com.sun.identity.saml2.profile.IDPCache" %>
<%@ page import="com.sun.identity.saml2.profile.IDPSingleLogout" %>

<%--
    idpSingleLogoutRedirect.jsp

    - receives the LogoutRequest and sends the LogoutResponse to
    Service Provider from the Identity Provider.
    OR
    - receives the LogoutResponse from the Service Provider.

    Required parameters to this jsp are :
    - RelayState - the target URL on successful Single Logout
    - SAMLRequest - the LogoutRequest
    OR
    - SAMLResponse - the LogoutResponse

    Check the SAML2 Documentation for supported parameters.
--%>
<html>

<head>
    <title>SAMLv2 Single Logout Redirect binding at IDP</title>
</head>
<body bgcolor="#FFFFFF" text="#000000">

<%
    // Retrieves the LogoutRequest or LogoutResponse
    //Retrieves :
    //- RelayState - the target URL on successful Single Logout
    //- SAMLRequest - the LogoutRequest
    //OR
    //- SAMLResponse - the LogoutResponse

    String relayState = request.getParameter(SAML2Constants.RELAY_STATE);
    if (relayState != null) {
        String tmpRs = (String) IDPCache.relayStateCache.remove(relayState);
        if (tmpRs != null) {
            relayState = tmpRs;
        }
    }
    String samlResponse = request.getParameter(SAML2Constants.SAML_RESPONSE);
    if (samlResponse != null) {
        boolean doRelayState = true;
        try {
        /**
         * Gets and processes the Single <code>LogoutResponse</code> from SP,
         * destroys the local session, checks response's issuer
         * and inResponseTo.
         *
         * @param request the HttpServletRequest.
         * @param response the HttpServletResponse.
         * @param samlResponse <code>LogoutResponse</code> in the
         *          XML string format.
         * @param relayState the target URL on successful
         * <code>LogoutResponse</code>.
         * @throws SAML2Exception if error processing
         *          <code>LogoutResponse</code>.
         */
            doRelayState = IDPSingleLogout.processLogoutResponse(
                request, response,samlResponse, relayState);
        } catch (SAML2Exception sse) {
            SAML2Utils.debug.error("Error processing LogoutResponse :",
                sse);
            SAMLUtils.sendError(request, response, response.SC_BAD_REQUEST,
                "LogoutResponseProcessingError",
                SAML2Utils.bundle.getString("LogoutResponseProcessingError") +
                " " + sse.getMessage());
            return;
        } catch (Exception e) {
            SAML2Utils.debug.error("Error processing LogoutResponse ",e);
            SAMLUtils.sendError(request, response, response.SC_BAD_REQUEST,
                "LogoutResponseProcessingError",
                SAML2Utils.bundle.getString("LogoutResponseProcessingError") +
                " " + e.getMessage());
            return;
        }

        if (!doRelayState) {
            // The following lines were added/changed by Carlos Devoto!
            String serverName = request.getServerName();
            StringBuilder domainNameBuf = new StringBuilder();
            int separatorCount = 0;
            for (int i = serverName.length() - 1; i >= 0; i--) {
        	    char c = serverName.charAt(i);
        	    if (c == '.') {
        		    separatorCount++;
        		    if (separatorCount > 1) {
        			    break;
        		    }
        	    }
    	        domainNameBuf.insert(0, c);
            }
            String domainName = domainNameBuf.toString().replace(".", "\\.");
            String regEx = "(http|https)://.+" + domainName + "(:\\d+)?/.+";
            if (relayState != null && (java.util.regex.Pattern.matches(regEx, relayState) || SAML2Utils.isRelayStateURLValid(request, relayState, SAML2Constants.IDP_ROLE))) {
                // End of change by Carlos Devoto!
                if (relayState.indexOf("?") != -1) {
                    response.sendRedirect(relayState 
                        + "&logoutStatus=logoutSuccess");
                } else {
                    response.sendRedirect(relayState 
                        + "?logoutStatus=logoutSuccess");
                }
            } else {
                %>
                <jsp:forward page="/saml2/jsp/default.jsp?message=idpSloSuccess" />
                <%
            }    
        }
    } else {
        String samlRequest = request.getParameter(SAML2Constants.SAML_REQUEST);
        if (samlRequest != null) {
            try {
            /**
             * Gets and processes the Single <code>LogoutRequest</code> from SP.
             *
             * @param request the HttpServletRequest.
             * @param response the HttpServletResponse.
             * @param samlRequest <code>LogoutRequest</code> in the
             *          XML string format.
             * @param relayState the target URL on successful
             * <code>LogoutRequest</code>.
             * @throws SAML2Exception if error processing
             *          <code>LogoutRequest</code>.
             */
            IDPSingleLogout.processLogoutRequest(request,response,
                samlRequest,relayState);
            } catch (SAML2Exception sse) {
                SAML2Utils.debug.error("Error processing LogoutRequest :", sse);
                SAMLUtils.sendError(request, response, response.SC_BAD_REQUEST,
                    "LogoutRequestProcessingError",
                    SAML2Utils.bundle.getString("LogoutRequestProcessingError")
                    + " " + sse.getMessage());
                return;
            } catch (Exception e) {
                SAML2Utils.debug.error("Error processing LogoutRequest ",e);
                SAMLUtils.sendError(request, response, response.SC_BAD_REQUEST,
                    "LogoutRequestProcessingError",
                    SAML2Utils.bundle.getString("LogoutRequestProcessingError")
                    + " " + e.getMessage());
                return;
            }
        }
    }
%>

</body>
</html>
