
component displayname="customer" output="false" {

    <!--- Get the users data using an ID --->
    public query function getUserDataByID(required numeric userID) {

        local.userQuery = queryNew('');

        if (len(trim(arguments.userID)) and arguments.userID gt 0) {

            local.qUser = queryExecute(

                options = {datasource = application.datasource},
                params = {
                    thisUserID: {type: "numeric", value = arguments.userID}
                },
                sql = "
                    SELECT DISTINCT
                    users.intUserID,
                    users.strSalutation,
                    users.strFirstName,
                    users.strLastName,
                    users.strEmail,
                    users.strPhone,
                    users.strMobile,
                    users.strLanguage,
                    users.strPhoto,
                    users.blnActive,
                    users.dtmLastLogin,
                    users.blnAdmin,
                    users.blnSuperAdmin,
                    users.strUUID,
                    customers.intCustomerID,
                    customers.intCustParentID,
                    customers.blnActive,
                    customers.strCompanyName,
                    customers.strContactPerson,
                    customers.strAddress,
                    customers.strAddress2,
                    customers.strZIP,
                    customers.strCity,
                    customers.strPhone,
                    customers.strEmail,
                    customers.strWebsite,
                    customers.strLogo,
                    customers.strBillingAccountName,
                    customers.strBillingEmail,
                    customers.strBillingAddress,
                    customers.strBillingInfo,
                    customers.intCountryID
                    FROM customer_user
                    INNER JOIN users ON customer_user.intUserID = users.intUserID
                    INNER JOIN customers ON users.intCustomerID = customers.intCustomerID
                    WHERE customer_user.intUserID = :thisUserID
                "
            )

            local.userQuery = local.qUser;

        }

        return local.userQuery;

    }



    <!--- Update customer --->
    public struct function updateCustomer(required struct customerStruct, required numeric customerID) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (structKeyExists(arguments.customerStruct, "company")) {
            local.company = application.objGlobal.cleanUpText(arguments.customerStruct.company, 100);
        } else {
            local.company = '';
        }
        if (structKeyExists(arguments.customerStruct, "contact")) {
            local.contact = application.objGlobal.cleanUpText(arguments.customerStruct.contact, 100);
        } else {
            local.contact = '';
        }
        if (structKeyExists(arguments.customerStruct, "address")) {
            local.address = application.objGlobal.cleanUpText(arguments.customerStruct.address, 100);
        } else {
            local.address = '';
        }
        if (structKeyExists(arguments.customerStruct, "address2")) {
            local.address2 = application.objGlobal.cleanUpText(arguments.customerStruct.address2, 100);
        } else {
            local.address2 = '';
        }
        if (structKeyExists(arguments.customerStruct, "zip")) {
            local.zip = application.objGlobal.cleanUpText(arguments.customerStruct.zip, 10);
        } else {
            local.zip = '';
        }
        if (structKeyExists(arguments.customerStruct, "city")) {
            local.city = application.objGlobal.cleanUpText(arguments.customerStruct.city, 100);
        } else {
            local.city = '';
        }
        if (structKeyExists(arguments.customerStruct, "countryID") and isNumeric(arguments.customerStruct.countryID)) {
            local.countryID = arguments.customerStruct.countryID;
        } else {
            local.countryID = 0;
        }
        if (structKeyExists(arguments.customerStruct, "timezoneID") and isNumeric(arguments.customerStruct.timezoneID) and arguments.customerStruct.timezoneID gt 0) {
            local.timezoneID = arguments.customerStruct.timezoneID;
        } else {
            local.timezoneID = application.objGlobal.getCountry(local.countryID).intTimezoneID;
        }
        if (structKeyExists(arguments.customerStruct, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.customerStruct.email, 100);
        } else {
            local.email = '';
        }
        if (structKeyExists(arguments.customerStruct, "phone")) {
            local.phone = application.objGlobal.cleanUpText(arguments.customerStruct.phone, 100);
        } else {
            local.phone = '';
        }
        if (structKeyExists(arguments.customerStruct, "website")) {
            local.website = application.objGlobal.cleanUpText(arguments.customerStruct.website, 100);
        } else {
            local.website = '';
        }
        if (structKeyExists(arguments.customerStruct, "billing_name")) {
            local.billing_name = application.objGlobal.cleanUpText(arguments.customerStruct.billing_name, 100);
        } else {
            local.billing_name = '';
        }
        if (structKeyExists(arguments.customerStruct, "billing_email")) {
            local.billing_email = application.objGlobal.cleanUpText(arguments.customerStruct.billing_email, 100);
        } else {
            local.billing_email = '';
        }
        if (structKeyExists(arguments.customerStruct, "billing_address")) {
            local.billing_address = application.objGlobal.cleanUpText(arguments.customerStruct.billing_address);
        } else {
            local.billing_address = '';
        }
        if (structKeyExists(arguments.customerStruct, "billing_info")) {
            local.billing_info = application.objGlobal.cleanUpText(arguments.customerStruct.billing_info);
        } else {
            local.billing_info = '';
        }

        try {

            queryExecute(

                options = {datasource = application.datasource},
                params = {
                    mutDate: {type: "datetime", value: now()},
                    customerID: {type: "numeric", value: arguments.customerID},
                    company: {type: "nvarchar", value: local.company},
                    contact: {type: "nvarchar", value: local.contact},
                    address: {type: "nvarchar", value: local.address},
                    address2: {type: "nvarchar", value: local.address2},
                    zip: {type: "nvarchar", value: local.zip},
                    city: {type: "nvarchar", value: local.city},
                    countryID: {type: "numeric", value: local.countryID},
                    timezoneID: {type: "numeric", value: local.timezoneID},
                    email: {type: "nvarchar", value: local.email},
                    phone: {type: "nvarchar", value: local.phone},
                    website: {type: "nvarchar", value: local.website},
                    billing_name: {type: "nvarchar", value: local.billing_name},
                    billing_email: {type: "nvarchar", value: local.billing_email},
                    billing_address: {type: "nvarchar", value: local.billing_address},
                    billing_info: {type: "nvarchar", value: local.billing_info}
                },
                sql = "

                    UPDATE customers
                    SET dtmMutDate = :mutDate,
                        strCompanyName = :company,
                        strContactPerson = :contact,
                        strAddress = :address,
                        strAddress2 = :address2,
                        strZIP = :zip,
                        strCity = :city,
                        intCountryID = :countryID,
                        intTimezoneID = :timezoneID,
                        strPhone = :phone,
                        strEmail = :email,
                        strWebsite = :website,
                        strBillingAccountName = :billing_name,
                        strBillingEmail = :billing_email,
                        strBillingAddress = :billing_address,
                        strBillingInfo = :billing_info
                    WHERE intCustomerID = :customerID

                "

            );

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch(any){

            local.argsReturnValue['message'] = cfcatch.message;


        }


        return local.argsReturnValue;

    }


    <!--- Insert tenant (only the most important data) --->
    public struct function insertTenant(required struct tenantStruct) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        param name="local.company_name" default="";
        param name="local.contact_person" default="";

        <!--- Needed values --->
        if (!structKeyExists(tenantStruct, "customerID") or !isNumeric(tenantStruct.customerID)) {
            local.argsReturnValue['message'] = "customerID not valid!";
            return local.argsReturnValue;
        }
        if (!structKeyExists(tenantStruct, "userID") or !isNumeric(tenantStruct.userID)) {
            local.argsReturnValue['message'] = "userID not valid!";
            return local.argsReturnValue;
        }

        local.customerID = tenantStruct.customerID;
        local.userID = tenantStruct.userID;

        if (structKeyExists(arguments.tenantStruct, "company_name")) {
            local.company_name = application.objGlobal.cleanUpText(tenantStruct.company_name, 100);
        } else {
            local.company_name = '';
        }

        if (structKeyExists(arguments.tenantStruct, "contact_person")) {
            local.contact_person = application.objGlobal.cleanUpText(tenantStruct.contact_person, 100);
        } else {
            local.contact_person = 'untitled company';
        }

        try {

            queryExecute(

                options = {datasource = application.datasource},
                params = {
                    company_name: {type: "nvarchar", value: local.company_name},
                    contact_person: {type: "nvarchar", value: local.contact_person},
                    intCustParentID: {type: "numeric", value: local.customerID},
                    intUserID: {type: "numeric", value: local.userID},
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "

                    INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, intCountryID, strContactPerson)
                    VALUES (:intCustParentID, :dateNow, :dateNow, 1, :company_name,
                        (SELECT intCountryID FROM countries WHERE blnDefault = 1), :contact_person);

                    SET @last_inserted_customer_id = LAST_INSERT_ID();

                    INSERT INTO customer_user (intCustomerID, intUserID, blnStandard)
                    VALUES (@last_inserted_customer_id, :intUserID, 0);

                "

            )

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;
            return local.argsReturnValue;

        } catch (any e) {

            local.argsReturnValue['message'] = e.message;
            return local.argsReturnValue;

        }

    }


    <!--- Get all tenants --->
    public query function getAllTenants(required numeric userID) {

        if (arguments.userID gt 0) {

            local.qTenants = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    userID: {type: "numeric", value: arguments.userID}
                },
                sql = "
                    SELECT customer_user.blnStandard, customers.*, users.blnSuperAdmin, users.blnAdmin
                    FROM customer_user
                    INNER JOIN customers ON customer_user.intCustomerID = customers.intCustomerID
                    INNER JOIN users ON customer_user.intUserID = users.intUserID
                    WHERE customer_user.intUserID = :userID
                    GROUP BY customers.intCustomerID
                    ORDER BY customer_user.blnStandard DESC
                "
            )

            return local.qTenants;

        }

    }


    <!--- Get customer data --->
    public query function getCustomerData(required numeric customerID) {

        if (arguments.customerID gt 0) {

            local.defLang = application.objGlobal.getDefaultLanguage().iso;

            local.qCustomer = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    defLang: {type: "varchar", value: local.defLang}
                },
                sql = "
                    SELECT *
                    FROM customers
                    WHERE intCustomerID = :customerID
                "
            )

            return local.qCustomer;

        }

    }

}
