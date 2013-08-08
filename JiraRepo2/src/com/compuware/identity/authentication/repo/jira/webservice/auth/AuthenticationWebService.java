
package com.compuware.identity.authentication.repo.jira.webservice.auth;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.RequestWrapper;
import javax.xml.ws.ResponseWrapper;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.1.6 in JDK 6
 * Generated source version: 2.1
 * 
 */
@WebService(name = "AuthenticationWebService", targetNamespace = "http://auth.webservice.dtmanager.dynatrace.com/")
@XmlSeeAlso({
    ObjectFactory.class
})
public interface AuthenticationWebService {


    /**
     * 
     * @param arg1
     * @param arg0
     * @return
     *     returns com.compuware.identity.authentication.repo.jira.webservice.auth.UserDetails
     */
    @WebMethod
    @WebResult(targetNamespace = "")
    @RequestWrapper(localName = "getUserDetails", targetNamespace = "http://auth.webservice.dtmanager.dynatrace.com/", className = "com.compuware.identity.authentication.repo.jira.webservice.auth.GetUserDetails")
    @ResponseWrapper(localName = "getUserDetailsResponse", targetNamespace = "http://auth.webservice.dtmanager.dynatrace.com/", className = "com.compuware.identity.authentication.repo.jira.webservice.auth.GetUserDetailsResponse")
    public UserDetails getUserDetails(
        @WebParam(name = "arg0", targetNamespace = "")
        String arg0,
        @WebParam(name = "arg1", targetNamespace = "")
        String arg1);

}