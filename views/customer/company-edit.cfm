
<cfscript>
    // getCustomerData you'll find in index.cfm
    qCountries = application.objGlobal.getCountry(language=session.lng);

    // Set default values
    custCompany = getCustomerData.strCompanyName;
    custContactPerson = getCustomerData.strContactPerson;
    custAddress = getCustomerData.strAddress;
    custAddress2 = getCustomerData.strAddress2;
    custZIP = getCustomerData.strZIP;
    custCity = getCustomerData.strCity;
    countryID = getCustomerData.intCountryID;
    custEmail = getCustomerData.strEmail;
    custPhone = getCustomerData.strPhone;
    custWebsite = getCustomerData.strWebsite;
    custBillingAccountName = getCustomerData.strBillingAccountName;
    custBillingEmail = getCustomerData.strBillingEmail;
    custBillingAddress = getCustomerData.strBillingAddress;
    custBillingInfo = getCustomerData.strBillingInfo;

    if(structKeyExists(session, "company") and len(trim(session.company))) {
        custCompany = session.company;
    }

    if(structKeyExists(session, "contact") and len(trim(session.contact))){
        custContactPerson = session.contact;
    }

    if(structKeyExists(session, "address") and len(trim(session.address))){
        custAddress = session.address;
    }

    if(structKeyExists(session, "address2") and len(trim(session.address2))){
        custAddress2 = session.address2;
    }

    if(structKeyExists(session, "zip") and len(trim(session.zip))){
        custZIP = session.zip;
    }
    
    if(structKeyExists(session, "city") and len(trim(session.city))){
        custCity = session.city;
    }

    if(structKeyExists(session, "countryID") and len(trim(session.countryID))){
        countryID = session.countryID;
    }

    if(structKeyExists(session, "email") and len(trim(session.email))){
        custEmail = session.email;
    }

    if(structKeyExists(session, "phone") and len(trim(session.phone))){
        custPhone = session.phone;
    }

    if(structKeyExists(session, "website") and len(trim(session.website))){
        custWebsite = session.website;
    }
    
    if(structKeyExists(session, "billing_name") and len(trim(session.billing_name))){
        custBillingAccountName = session.billing_name;
    }

    if(structKeyExists(session, "billing_email") and len(trim(session.billing_email))){
        custBillingEmail = session.billing_email;
    }

    if(structKeyExists(session, "billing_address") and len(trim(session.billing_address))){
        custBillingAddress = session.billing_address;
    }

    if(structKeyExists(session, "billing_info") and len(trim(session.billing_info))){
        custBillingInfo = session.billing_info
    }

</cfscript>

<cfinclude template="/includes/header.cfm">

<cfinclude template="/includes/navigation.cfm">
<div class="page-wrapper">
    <div class="container-xl">
        <cfoutput>   
        <div class="page-header mb-3">
            <h4 class="page-title"><cfoutput>#getTrans('titEditCompany')#</cfoutput></h4>

            <ol class="breadcrumb breadcrumb-dots">
                <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                <li class="breadcrumb-item active">#getTrans('titEditCompany')#</li>
            </ol>

        </div>

        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>

        <div class="row">
            <div class="col-lg-4 mb-3">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('titLogo')#</h3>
                    </div>                                
                    <div class="card-body">
                        <form action="#application.mainURL#/customer" method="post" enctype="multipart/form-data">                                        
                            <div class="row mb-1"> 
                                <cfif len(trim(getCustomerData.strLogo))>
                                    <div class="col-auto text-center">
                                        <img src="#application.mainURL#/userdata/images/logos/#getCustomerData.strLogo#" alt="logo" style="max-height: 150px;">                                           
                                        <div class="d-flex flex-row flex-start">
                                            <div class="mt-3">
                                                <a href="#application.mainURL#/customer?del_logo" class="btn btn-warning btn-block">#getTrans('txtDeleteLogo')#</a>
                                            </div>
                                        </div>
                                    </div>
                                    <cfelse>
                                    <div class="mt-1">
                                        <input name="logo" required type="file" accept=".jpg, .jpeg, .png, .svg, .bmp" class="dropify" data-height="100" data-allowed-file-extensions='["jpg", "jpeg", "png", "svg", "bmp"]' data-max-file-size="3M" />
                                    </div>
                                    <div class="d-flex flex-row flex-start">    
                                        <div class="mt-3">
                                            <button name="logo_upload_btn" class="btn btn-primary btn-block">#getTrans('btnUpload')#</button>                                           
                                        </div>
                                    </div>        
                                </cfif>
                            </div>                                   
                        </form>
                    </div>
                </div> 
                <!--- <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Account löschen</h3>
                    </div>
                    <div class="card-body">
                        <form>        
                            <p>Möchten Sie Ihren Account löschen?</p>
                            <div class="form-footer">
                                <button class="btn btn-danger btn-block" id="click2" onclick="return confirm('?')">Account löschen</button>
                            </div>
                        </form>
                    </div>
                </div> --->                            
            </div>                       
            <div class="col-lg-8">
                <form class="card" id="submit_form" method="post" action="#application.mainURL#/customer">
                    <input type="hidden" name="edit_company_btn">
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('titEditCompany')#</h3>
                    </div>
                    <div class="card-body">                                    
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formCompanyName')# *</label>
                                    <input type="text" name="company" class="form-control" value="#HTMLEditFormat(custCompany)#" minlength="3" maxlength="100" required>
                                </div>
                            </div>    
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formContactName')# *</label>
                                    <input type="text" name="contact" class="form-control" value="#HTMLEditFormat(custContactPerson)#" minlength="3" maxlength="100" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formAddress')# *</label>
                                    <input type="text" name="address" class="form-control" value="#HTMLEditFormat(custAddress)#" minlength="3" maxlength="100" required>
                                </div>
                            </div> 
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formAddress2')#</label>
                                    <input type="text" name="address2" class="form-control" value="#HTMLEditFormat(custAddress2)#" maxlength="100">
                                </div>
                            </div>                                        
                            <div class="col-sm-6 col-md-3">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formZIP')# *</label>
                                    <input type="text" name="zip" class="form-control" value="#HTMLEditFormat(custZIP)#" minlength="4" maxlength="10" required>
                                </div>
                            </div>
                            <div class="col-md-5">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formCity')# *</label>
                                    <input type="text" name="city" class="form-control" value="#HTMLEditFormat(custCity)#" minlength="3" maxlength="100" required>
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-4">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formCountry')#</label>                                    
                                    <select name="countryID" type="text" class="form-select" placeholder="#getTrans('formCountry')#" id="select-users">
                                        <cfloop query="qCountries">
                                            <option value="#qCountries.intCountryID#" <cfif qCountries.intCountryID eq countryID>selected</cfif>>#qCountries.strCountryName#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </div>  
                            <div class="col-md-5">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formEmailAddress')#</label>
                                    <input type="email" class="form-control" name="email" value="#custEmail#" maxlength="100">
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-3">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formPhone')#</label>
                                    <input type="text" class="form-control" name="phone" value="#HTMLEditFormat(custPhone)#" maxlength="100">
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-4">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formWebsite')#</label>
                                    <input type="text" class="form-control" name="website" value="#HTMLEditFormat(custWebsite)#" maxlength="100">
                                </div>
                            </div>                                                              
                        </div>
                    </div>
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('titInvoiceSettings')#</h3>
                    </div>
                    <div class="card-body">                                    
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formCompanyName')#</label>
                                    <input type="text" name="billing_name" class="form-control" value="#HTMLEditFormat(custBillingAccountName)#" maxlength="100">
                                </div>
                            </div>    
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formInvoiceEmail')#</label>
                                    <input type="email" name="billing_email" class="form-control" value="#custBillingEmail#" maxlength="100">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formInvoiceAddress')#</label>
                                    <textarea class="form-control" name="billing_address" rows="6">#custBillingAddress#</textarea>
                                </div>
                            </div> 
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">#getTrans('formInvoiceInfo')#</label>
                                    <textarea class="form-control" name="billing_info" rows="6">#custBillingInfo#</textarea>
                                </div>
                            </div>                                                       
                        </div>
                    </div>
                    <div class="card-footer text-right">
                        <button type="submit" id="submit_button" class="btn btn-primary">#getTrans('btnSave')#</button>
                    </div>
                </form>
                
            </div>
        </div>  
        </cfoutput>                
    </div>
    <cfinclude template="/includes/footer.cfm"> 

</div>    