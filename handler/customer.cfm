
<cfscript>

// Company edit 
if (structKeyExists(form, "edit_company_btn")) {

    param name="form.company" default="";
    param name="form.contact" default="";
    param name="form.address" default="";
    param name="form.address2" default="";
    param name="form.zip" default="";
    param name="form.city" default="";
    param name="form.countryID" default="0";
    param name="form.timezoneID" default="0";
    param name="form.email" default="";
    param name="form.phone" default="";
    param name="form.website" default="";
    param name="form.billing_name" default="";
    param name="form.billing_email" default="";
    param name="form.billing_address" default="";
    param name="form.billing_info" default="";

    session.company = form.company;
    session.contact = form.contact;
    session.address = form.address;
    session.address2 = form.address2;
    session.zip = form.zip;
    session.city = form.city;
    session.countryID = form.countryID;
    session.timezoneID = form.timezoneID;
    session.email = form.email;
    session.phone = form.phone;
    session.website = form.website;
    session.billing_name = form.billing_name;
    session.billing_email = form.billing_email;
    session.billing_address = form.billing_address;
    session.billing_info = form.billing_info;

    // Check whether the email is valid
    checkEmail = application.objGlobal.checkEmail(form.email);
    if (!checkEmail) {
        getAlert('alertEnterEmail', 'warning');
        logWrite("Edit company", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Provided email is not valid!", false);
        location url="#application.mainURL#/account-settings/company" addtoken="false";
    }

    if (len(trim(form.billing_email))) {
        checkEmail = application.objGlobal.checkEmail(form.billing_email);
        if (!checkEmail) {
            getAlert('alertEnterEmail', 'warning');
            logWrite("Edit company", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Provided email is not valid!", false);
            location url="#application.mainURL#/account-settings/company" addtoken="false";
        }
    }

    // Save the customer using a function
    objCustomerEdit = application.objCustomer.updateCustomer(form, session.customer_id);

    if (objCustomerEdit.success) {
        getAlert('msgChangesSaved', 'success');
        logWrite("Edit company", 1, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Company info successfully saved!", false);
    } else {
        getAlert(objCustomerEdit.message, 'danger');
        logWrite("Edit company", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Company info could not be saved!", false);
    }

    // Clear sessions
    structDelete(session, "company");
    structDelete(session, "contact");
    structDelete(session, "address");
    structDelete(session, "address2");
    structDelete(session, "zip");
    structDelete(session, "countryID");
    structDelete(session, "timezoneID");
    structDelete(session, "email");
    structDelete(session, "phone");
    structDelete(session, "website");
    structDelete(session, "billing_name");
    structDelete(session, "billing_email");
    structDelete(session, "billing_address");
    structDelete(session, "billing_info");
    structDelete(session, "filledData");

    location url="#application.mainURL#/account-settings/company" addtoken="false";


}


// Logo upload
if (structKeyExists(form, "logo_upload_btn")) {

    fileStruct = structNew();
    fileStruct.filePath = expandPath('/userdata/images/logos'); //absolute path
    fileStruct.maxSize = "500"; // empty or kb
    fileStruct.maxWidth = "1000"; // empty or pixels
    fileStruct.maxHeight = ""; // empty or pixels
    fileStruct.makeUnique = true; // true or false (default true)
    fileStruct.fileName = lcase(replace(createUUID(),"-", "", "all")); // empty or any name; ex. uuid (without extension)

    if (structKeyExists(form, "logo") and len(trim(form.logo))) {

        fileStruct.fileNameOrig = form.logo;

        // Check if file is a valid image
        try {
            ImageRead(ExpandPath("#fileStruct.fileNameOrig#"));
        }
        catch("java.io.IOException" e){
            getAlert( "msgFileUploadError", 'danger');
            logWrite("Logo upload", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Logo upload didn't succeed!", false);
            location url="#application.mainURL#/account-settings/company" addtoken="false";
        }
        catch(any e){
            getAlert( e.message, 'danger');
            logWrite("Logo upload", 3, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Logo upload didn't succeed!", false);
            location url="#application.mainURL#/account-settings/my-profile" addtoken="false";
        }

        // Sending the data into a function
        fileUpload = application.objGlobal.uploadFile(fileStruct, variables.imageFileTypes);

        if (fileUpload.success) {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: session.customer_id},
                    thisLogo: {type: "nvarchar", value: fileUpload.fileName}
                },
                sql = "
                    UPDATE customers
                    SET strLogo = :thisLogo
                    WHERE intCustomerID = :customerID
                "
            )

            getAlert('msgFileUploadedSuccessfully', 'success');
            logWrite("Logo upload", 1, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Logo upload was successful!", false);
            
        } else {

            getAlert(fileUpload.message, 'danger');
            logWrite("Logo upload", 3, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Logo upload didn't succeed!", false);

        }

    } else {

        getAlert('msgPleaseChooseFile', 'warning');

    }

    location url="#application.mainURL#/account-settings/company" addtoken="false";

}


// Delete logo
if (structKeyExists(url, "del_logo")) {

    qLogo = queryExecute(
        options = {datasource = application.datasource},
        params = {
            customerID: {type: "numeric", value: session.customer_id}
        },
        sql="
            SELECT strLogo
            FROM customers
            WHERE intCustomerID = :customerID
        "
    )

    if (qLogo.recordCount and len(trim(qLogo.strLogo))) {

        deleteLogo = application.objGlobal.deleteFile(expandPath("/userdata/images/logos/#qLogo.strLogo#"));

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: session.customer_id}
            },
            sql="
                UPDATE customers
                SET strLogo = ''
                WHERE intCustomerID = :customerID
            "
        )
        
        location url="#application.mainURL#/account-settings/company" addtoken="false";

    }

}


// New tenant
if (structKeyExists(form, "new_tenant_btn")) {

    param name="form.company_name" default="";
    param name="form.contact_person" default="";

    if (!len(trim(contact_person))) {
        logWrite("Create new tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Contact person is not provided!", false);
        location url="#application.mainURL#/account-settings/tenants" addtoken="false";
    }

    tenantStruct = structNew();
    tenantStruct.company_name = form.company_name;
    tenantStruct.contact_person = form.contact_person;
    tenantStruct.customerID = session.customer_id;
    tenantStruct.userID = session.user_id;

    // Insert the tenant using a function
    insertTenant = application.objCustomer.insertTenant(tenantStruct);

    if (insertTenant.success) {

        getAlert('alertTenantAdded', 'success');
        logWrite("Create new tenant", 1, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Successfully created new tenant!", false);

    } else {

        getAlert(insertTenant.message, 'danger');
        logWrite("Create new tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, New tenant could not be created!", false);

    }

    location url="#application.mainURL#/account-settings/tenants" addtoken="false";

}


// Delete tenant
if (structKeyExists(url, "delete")) {

    param name="url.delete" default="0";

    if (!isNumeric(url.delete) or url.delete lte 0) {
        getAlert('No tenant found!', 'danger');
        logWrite("Delete tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Tenant not found!", false);
        location url="#application.mainURL#/account-settings/tenants" addtoken="false";
    }

    // User data of the user to be deleted
    getTenant = application.objCustomer.getCustomerData(url.delete);

    if (structIsEmpty(getTenant)) {
        getAlert('No tenant found!', 'danger');
        logWrite("Delete tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Tenant not found!", false);
        location url="#application.mainURL#/account-settings/tenants" addtoken="false";
    }

    // Check whether the user is allowed to delete
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getTenant.customerID);

    if (!checkTenantRange) {
        getAlert('You are not allowed to delete this tenant!', 'danger');
        logWrite("Delete tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, User is not allowed to delete this tenant!", false);
        location url="#application.mainURL#/account-settings/tenants" addtoken="false";
    }

    // Delete users photo
    if (len(trim(getTenant.logo))) {

        photoPath = expandPath('../userdata/images/logos/#getTenant.logo#');
        objUserFileDelete = application.objGlobal.deleteFile(photoPath);

    }

    // Delete tenant
    queryExecute(
        options = {datasource = application.datasource, result="getAnswer"},
        params = {
            customerID: {type: "numeric", value: getTenant.customerID},
            myCustomerID: {type: "numeric", value: session.customer_id}
        },
        sql = "
            DELETE FROM customers WHERE intCustomerID = :customerID AND intCustomerID != :myCustomerID
        "
    )

    if (getAnswer.recordCount) {
        getAlert('alertTenantDeleted', 'success');
        logWrite("Delete tenant", 1, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Tenant got successfully deleted!", false);
    } else {
        getAlert('No user found!', 'danger');
        logWrite("Delete tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Tenant could not be deleted!", false);
    }

    location url="#application.mainURL#/account-settings/tenants" addtoken="false";

}


// Activate or deactivate tenant
if (structKeyExists(url, "change_tenant")) {

    if (!isNumeric(url.change_tenant)) {
        getAlert('The customerID is not of type numeric!', 'danger');
        logWrite("Change status of tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Tenant url value is not numeric!", false);
        location url="#application.mainURL#/account-settings/tenants" addtoken="false";
    }

    // User data of the user to be changed
    getTenant = application.objCustomer.getCustomerData(url.change_tenant);

    if (structIsEmpty(getTenant)) {
        getAlert('No tenant found!', 'danger');
        logWrite("Change status of tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, No tenant found!", false);
        location url="#application.mainURL#/account-settings/tenants" addtoken="false";
    }

    thisCustomerID = getTenant.customerID;

    // Check whether the user is allowed to change
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, thisCustomerID);

    if (!checkTenantRange) {
        getAlert('You are not allowed to edit this tenant!', 'danger');
        logWrite("Change status of tenant", 2, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, User not allowed to edit this tenant!", false);
        location url="#application.mainURL#/account-settings/tenants" addtoken="false";
    }

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            customerID: {type: "numeric", value: thisCustomerID},
            myCustomerID: {type: "numeric", value: session.customer_id}
        },
        sql="
            UPDATE customers
            SET blnActive = IF(blnActive = 1, 0, 1)
            WHERE intCustomerID = :customerID AND intCustomerID != :myCustomerID
        "
    )


    location url="#application.mainURL#/account-settings/tenants" addtoken="false";

}


</cfscript>
