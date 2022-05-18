
component displayname="customer" output="false" {

    variables.argsReturnValue = structNew();
    variables.argsReturnValue['message'] = "";
    variables.argsReturnValue['success'] = false;

    <!--- Insert optin --->
    public numeric function insertOptin(required struct optinValues) {

        if (structKeyExists(arguments.optinValues, "first_name")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.optinValues.first_name, 100);
        } else {
            local.first_name = '';
        }
        if (structKeyExists(arguments.optinValues, "name")) {
            local.name = application.objGlobal.cleanUpText(arguments.optinValues.name, 100);
        } else {
            local.name = '';
        }
        if (structKeyExists(arguments.optinValues, "company")) {
            local.company = application.objGlobal.cleanUpText(arguments.optinValues.company, 100);
        } else {
            local.company = '';
        }
        if (structKeyExists(arguments.optinValues, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.optinValues.email, 100);
        } else {
            local.email = '';
        }
        if (structKeyExists(arguments.optinValues, "language")) {
            local.language = application.objGlobal.cleanUpText(arguments.optinValues.language, 2);
        } else {
            local.language = '';
        }
        if (structKeyExists(arguments.optinValues, "newUUID")) {
            local.newUUID = arguments.optinValues.newUUID;
        } else {
            local.newUUID = application.objGlobal.getUUID();
        }

        queryExecute(

            options = {datasource = '#application.datasource#', result = 'getNewID'},
            params = {
                first_name: {type: "nvarchar", value: local.first_name},
                name: {type: "nvarchar", value: local.name},
                company: {type: "nvarchar", value: local.company},
                email: {type: "nvarchar", value: local.email},
                language: {type: "nvarchar", value: local.language},
                newUUID: {type: "nvarchar", value: local.newUUID}
            },
            sql = "
                INSERT INTO optin (strFirstName, strLastName, strCompanyName, strEmail, strLanguage, strUUID)
                VALUES (:first_name, :name, :company, :email, :language, :newUUID)
            "

        );

        if (isNumeric(getNewID.generated_key) and getNewID.generated_key gt 0) {

            return getNewID.generated_key;

        } else {

            return 0;

        }

    }


    <!--- Insert customer: used for register --->
    public struct function insertCustomer(required struct customerStruct) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        param name="local.company_name" default="";
        param name="local.first_name" default="";
        param name="local.last_name" default="";
        param name="local.email" default="";
        param name="local.language" default="";
        param name="local.password" default=""; //(the password must be hashed already!)
        param name="local.uuid" default="";

        if (structKeyExists(arguments.customerStruct, "strCompanyName")) {
            local.company_name = application.objGlobal.cleanUpText(arguments.customerStruct.strCompanyName, 100);
        } else {
            local.company_name = '';
        }
        if (structKeyExists(arguments.customerStruct, "strFirstName")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.customerStruct.strFirstName, 100);
        } else {
            local.first_name = '';
        }
        if (structKeyExists(arguments.customerStruct, "strLastName")) {
            local.last_name = application.objGlobal.cleanUpText(arguments.customerStruct.strLastName, 100);
        } else {
            local.last_name = '';
        }
        if (structKeyExists(arguments.customerStruct, "strEmail")) {
            local.email = application.objGlobal.cleanUpText(arguments.customerStruct.strEmail, 100);
        } else {
            local.email = '';
        }
        if (structKeyExists(arguments.customerStruct, "strLanguage")) {
            local.language = application.objGlobal.cleanUpText(arguments.customerStruct.strLanguage, 2);
        } else {
            local.language = '';
        }
        if (structKeyExists(arguments.customerStruct, "hash")) {
            local.hash = trim(arguments.customerStruct.hash);
        } else {
            local.hash = '';
        }
        if (structKeyExists(arguments.customerStruct, "salt")) {
            local.salt = trim(arguments.customerStruct.salt);
        } else {
            local.salt = '';
        }
        if (structKeyExists(arguments.customerStruct, "strUUID")) {
            local.uuid = trim(arguments.customerStruct.strUUID);
        } else {
            local.uuid = '';
        }



        try {

            queryExecute(

                options = {datasource = application.datasource},
                params = {
                    company_name: {type: "nvarchar", value: local.company_name},
                    first_name: {type: "nvarchar", value: local.first_name},
                    last_name: {type: "nvarchar", value: local.last_name},
                    email: {type: "nvarchar", value: local.email},
                    language: {type: "nvarchar", value: local.language},
                    hash: {type: "nvarchar", value: local.hash},
                    salt: {type: "nvarchar", value: local.salt},
                    uuid: {type: "nvarchar", value: local.uuid}
                },
                sql = "

                    INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, intCountryID, strContactPerson, strEmail)
                    VALUES (0, now(), now(), 1, :company_name,
                        (SELECT intCountryID FROM countries WHERE blnDefault = 1), CONCAT(:first_name, ' ', :last_name), :email);

                    SET @last_inserted_customer_id = LAST_INSERT_ID();

                    INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strFirstName, strLastName, strEmail, strPasswordHash, strPasswordSalt, strLanguage, blnActive, blnAdmin, blnSuperAdmin, blnSysAdmin)
                    VALUES (@last_inserted_customer_id, now(), now(), :first_name, :last_name, :email, :hash, :salt, :language, 1, 1, 1,
                        IF(
                            (
                                SELECT COUNT(intCustomerID)
                                FROM customers
                                WHERE intCustomerID <> @last_inserted_customer_id
                            ) > 0,
                            0,
                            1
                        )
                    );

                    DELETE FROM optin WHERE strUUID = :uuid;

                "

            );

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch(any e){

            local.argsReturnValue['message'] = e;


        }

        return local.argsReturnValue;

    }


}