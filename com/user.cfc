
component displayname="user" output="false" {

    variables.getTrans = application.objLanguage.getTrans;

    // Login
    public struct function checkLogin() {

        param name="arguments.email" default="" type="string";
        param name="arguments.password" default="" type="string";

        local.returnStruct = structNew();
        local.returnStruct['loginCorrect'] = false;
        local.returnStruct['step'] = 1;

        qCheckLogin = queryExecute(

            options = {datasource = application.datasource},
            params = {
                thisEmail: {type: "nvarchar", value: arguments.email}
                },
            sql = "
                SELECT intUserID,strFirstName,strLastName,dtmLastLogin,blnAdmin,strEmail,blnActive,blnSuperAdmin,blnSysAdmin,strPasswordHash,strPasswordSalt,strLanguage,
                    (   SELECT intCustomerID
                        FROM customer_user
                        WHERE intUserID = users.intUserID AND blnStandard = 1
                        LIMIT 1
                    ) AS intCustomerID,
                    (   SELECT customers.blnActive
                        FROM customer_user INNER JOIN customers ON customer_user.intCustomerID = customers.intCustomerID
                        WHERE blnStandard = 1 AND intUserID = users.intUserID
                        LIMIT 1
                    ) AS tenant_active
                FROM users
                WHERE strEmail = :thisEmail
            "

        )


        if (qCheckLogin.recordCount) {

            if (qCheckLogin.strPasswordHash eq hash(arguments.password & qCheckLogin.strPasswordSalt, 'SHA-512')) {

                if (qCheckLogin.blnActive and qCheckLogin.tenant_active) {

                    local.returnStruct['active'] = true;
                    local.returnStruct['user_id'] = qCheckLogin.intUserID;
                    local.returnStruct['customer_id'] = qCheckLogin.intCustomerID;
                    local.returnStruct['user_name'] = qCheckLogin.strFirstName & " " & qCheckLogin.strLastName;
                    local.returnStruct['user_email'] = qCheckLogin.strEmail;
                    local.returnStruct['last_login'] = qCheckLogin.dtmLastLogin;
                    local.returnStruct['language'] = qCheckLogin.strLanguage;
                    local.returnStruct['admin'] = trueFalseFormat(qCheckLogin.blnAdmin);
                    local.returnStruct['superadmin'] = trueFalseFormat(qCheckLogin.blnSuperAdmin);
                    local.returnStruct['sysadmin'] = trueFalseFormat(qCheckLogin.blnSysAdmin);

                    queryExecute(

                        options = {datasource = application.datasource},
                        params = {
                            thisUserID: {type: "nvarchar", value: local.returnStruct.user_id},
                            dateNow: {type: "datetime", value: now()}
                        },
                        sql = "
                            UPDATE users
                            SET dtmLastLogin = :dateNow,
                                strUUID = ''
                            WHERE intUserID = :thisUserID
                        "

                    )

                    local.returnStruct['loginCorrect'] = true;

                    // Init plan object
                    local.objPlans = new com.plans();

                    // Get plan group
                    local.planGroup = local.objPlans.prepareForGroupID(qCheckLogin.intCustomerID, application.usersIP);

                    // Set the default plan, if defined
                    local.objPlans.setDefaultPlan(qCheckLogin.intCustomerID, local.planGroup.groupID);

                    if (structKeyExists(session, "redirect") and len(trim(session.redirect))) {
                        local.returnStruct['redirect'] = session.redirect;
                    } else {
                        local.returnStruct['redirect'] = "#application.mainURL#/dashboard";
                    }


                } else {

                    local.returnStruct['active'] = false;
                    local.returnStruct['loginCorrect'] = false;

                }

            }

        }else {

            local.returnStruct['redirect'] = "#application.mainURL#/login";

        }

        return local.returnStruct;

    }


    // Change users password
    public struct function changePassword(required string newPassword, required string resetUUID) {

        // Default variable
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        // Hash and salt the password
        local.hashedStruct = application.objGlobal.generateHash(arguments.newPassword);

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    passwordHash: {type: "nvarchar", value: local.hashedStruct.thisHash},
                    passwordSalt: {type: "nvarchar", value: local.hashedStruct.thisSalt},
                    strUUID: {type: "nvarchar", value: arguments.resetUUID}
                },
                sql = "
                    UPDATE users
                    SET strPasswordHash = :passwordHash,
                        strPasswordSalt = :passwordSalt
                    WHERE strUUID = :strUUID
                "
            )

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        }
        catch(any) {

            local.argsReturnValue['message'] = cfcatch.message;
        }

        return local.argsReturnValue;

    }


    // Update user
    public struct function updateUser(required struct userStruct, required numeric userID, boolean comfirmMailChange) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.salutation = '';
        local.first_name = '';
        local.last_name = '';
        local.email = '';
        local.phone = '';
        local.mobile = '';
        local.language = application.objLanguage.getDefaultLanguage().iso;
        local.superadmin = 0;
        local.admin = 0;
        local.active = 0;
        local.tenantID = '';

        if (structKeyExists(arguments.userStruct, "salutation")) {
            local.salutation = application.objGlobal.cleanUpText(arguments.userStruct.salutation, 20);
        }
        if (structKeyExists(arguments.userStruct, "first_name")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.userStruct.first_name, 100);
        }
        if (structKeyExists(arguments.userStruct, "last_name")) {
            local.last_name = application.objGlobal.cleanUpText(arguments.userStruct.last_name, 100);
        }
        if (structKeyExists(arguments.userStruct, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.userStruct.email, 100);
        }
        if (structKeyExists(arguments.userStruct, "phone")) {
            local.phone = application.objGlobal.cleanUpText(arguments.userStruct.phone, 100);
        }
        if (structKeyExists(arguments.userStruct, "mobile")) {
            local.mobile = application.objGlobal.cleanUpText(arguments.userStruct.mobile, 100);
        }
        if (structKeyExists(arguments.userStruct, "language")) {
            local.language = arguments.userStruct.language;
        }
        if (structKeyExists(arguments.userStruct, "superadmin")) {
            local.superadmin = arguments.userStruct.superadmin;
        }
        if (structKeyExists(arguments.userStruct, "admin")) {
            local.admin = arguments.userStruct.admin;
        }
        if (structKeyExists(arguments.userStruct, "active")) {
            local.active = arguments.userStruct.active;
        }
        if (structKeyExists(arguments.userStruct, "tenantID")) {
            local.tenantID = arguments.userStruct.tenantID;
        }

        try {

            // update the user
            queryExecute(

                options = {datasource = application.datasource, result="check"},
                params = {
                    intUserID: {type: "numeric", value: arguments.userID},
                    salutation: {type: "nvarchar", value: local.salutation},
                    first_name: {type: "nvarchar", value: local.first_name},
                    last_name: {type: "nvarchar", value: local.last_name},
                    phone: {type: "nvarchar", value: local.phone},
                    mobile: {type: "nvarchar", value: local.mobile},
                    language: {type: "nvarchar", value: local.language},
                    admin: {type: "numeric", value: local.admin},
                    superadmin: {type: "numeric", value: local.superadmin},
                    active: {type: "numeric", value: local.active}
                },
                sql = "
                    UPDATE users
                    SET strSalutation = :salutation,
                        strFirstName = :first_name,
                        strLastName = :last_name,
                        strPhone = :phone,
                        strMobile = :mobile,
                        strLanguage = :language,
                        blnAdmin = :admin,
                        blnSuperAdmin = :superadmin,
                        blnActive = :active
                    WHERE intUserID = :intUserID
                "

            )

            if (listLen(local.tenantID)) {

                // Delete tenants to which the user has no access
                queryExecute(

                    options = {datasource = application.datasource, result="check"},
                    params = {
                        userID: {type: "numeric", value: arguments.userID}
                    },
                    sql = "
                        DELETE FROM customer_user
                        WHERE intUserID = :userID
                        AND NOT intCustomerID IN (#local.tenantID#)
                    "

                )

                // Insert tenants to which the user has access
                cfloop( list = local.tenantID, index = "local.t" ) {

                    queryExecute(

                        options = {datasource = application.datasource},
                        params = {
                            tenantID: {type: "numeric", value: local.t},
                            userID: {type: "numeric", value: arguments.userID}
                        },
                        sql = "
                            INSERT INTO customer_user (intCustomerID, intUserID)
                            SELECT * FROM
                            (
                                SELECT :tenantID as thisTenantID, :userID as thisUserID
                            ) as tmp
                            WHERE NOT EXISTS
                            (
                                SELECT intCustomerID
                                FROM customer_user
                                WHERE intCustomerID = :tenantID AND intUserID = :userID
                            )
                        "

                    )

                }

                // At least one tenant must be defined as standard
                qCheckStandard = queryExecute(

                    options = {datasource = application.datasource},
                    params = {
                        userID: {type: "numeric", value: arguments.userID}
                    },
                    sql = "
                        SELECT SUM(blnStandard) as hasStandard
                        FROM customer_user
                        WHERE intUserID = :userID
                    "
                )

                if (qCheckStandard.hasStandard eq 0) {

                    queryExecute(

                        options = {datasource = application.datasource},
                        params = {
                            userID: {type: "numeric", value: arguments.userID}
                        },
                        sql = "
                            UPDATE customer_user
                            SET blnStandard = 1
                            WHERE intUserID = :userID
                            ORDER BY intCustomerID
                            LIMIT 1
                        "
                    )

                }

            }


            if (structKeyExists(arguments, 'comfirmMailChange') and !arguments.comfirmMailChange) {

                updateEmail(local.email, arguments.userID);

                local.argsReturnValue['message'] = "OK";
                local.argsReturnValue['success'] = true;


            } else {

                application.objGlobal.getAlert('alertOptinSent', 'info');
            }

        } catch (any) {

            local.argsReturnValue['message'] = cfcatch.message;

        }

        return local.argsReturnValue;

    }


    // Insert user
    public struct function insertUser(required struct userStruct, required numeric customerID) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        local.argsReturnValue['newUUID'] = application.objGlobal.getUUID();

        local.salutation = '';
        local.first_name = '';
        local.last_name = '';
        local.email = '';
        local.phone = '';
        local.mobile = '';
        local.language = application.objLanguage.getDefaultLanguage().iso;
        local.admin = 0;
        local.superadmin = 0;
        local.active = 0;


        if (structKeyExists(arguments.userStruct, "salutation")) {
            local.salutation = application.objGlobal.cleanUpText(arguments.userStruct.salutation, 20);
        }
        if (structKeyExists(arguments.userStruct, "first_name")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.userStruct.first_name, 100);
        }
        if (structKeyExists(arguments.userStruct, "last_name")) {
            local.last_name = application.objGlobal.cleanUpText(arguments.userStruct.last_name, 100);
        }
        if (structKeyExists(arguments.userStruct, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.userStruct.email, 100);
        }
        if (structKeyExists(arguments.userStruct, "phone")) {
            local.phone = application.objGlobal.cleanUpText(arguments.userStruct.phone, 100);
        }
        if (structKeyExists(arguments.userStruct, "mobile")) {
            local.mobile = application.objGlobal.cleanUpText(arguments.userStruct.mobile, 100);
        }
        if (structKeyExists(arguments.userStruct, "language")) {
            local.language = arguments.userStruct.language;
        }
        if (structKeyExists(arguments.userStruct, "admin")) {
            local.admin = arguments.userStruct.admin;
        }
        if (structKeyExists(arguments.userStruct, "superadmin")) {
            local.superadmin = arguments.userStruct.superadmin;
            if (local.superadmin eq 1) {
                local.admin = 1;
            }
        }
        if (structKeyExists(arguments.userStruct, "active")) {
            local.active = arguments.userStruct.active;
        }


        try {

            queryExecute(

                options = {datasource = application.datasource, result="newUserID"},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    salutation: {type: "nvarchar", value: local.salutation},
                    first_name: {type: "nvarchar", value: local.first_name},
                    last_name: {type: "nvarchar", value: local.last_name},
                    email: {type: "nvarchar", value: local.email},
                    phone: {type: "nvarchar", value: local.phone},
                    mobile: {type: "nvarchar", value: local.mobile},
                    admin: {type: "boolean", value: local.admin},
                    superadmin: {type: "boolean", value: local.superadmin},
                    active: {type: "boolean", value: local.active},
                    language: {type: "varchar", value: local.language},
                    newUUID: {type: "nvarchar", value: local.argsReturnValue.newUUID},
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "
                    INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strSalutation, strFirstName, strLastName, strEmail, strPhone, strMobile, strLanguage, blnActive, blnAdmin, blnSuperAdmin, strUUID)
                    VALUES (:customerID, :dateNow, :dateNow, :salutation, :first_name, :last_name, :email, :phone, :mobile, :language, :active, :admin, :superadmin, :newUUID)
                "

            )

            local.argsReturnValue['newUserID'] = newUserID.generatedkey;
            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch(any){

            local.argsReturnValue['message'] = cfcatch.message;

        }

        return local.argsReturnValue;

    }


    // Get all users
    public query function getAllUsers(required numeric customerID) {

        if (arguments.customerID gt 0) {

            qUsers = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT users.*
                    FROM customer_user
                    INNER JOIN users ON customer_user.intUserID = users.intUserID
                    WHERE customer_user.intCustomerID = :customerID
                "
            )

            return qUsers;

        }

    }


    // Send invitation link
    public struct function sendInvitation(required numeric toUserID, required numeric fromUserID) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (arguments.toUserID gt 0 and arguments.fromUserID gt 0) {

            // Get user
            local.qUser = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    toUserID: {type: "numeric", value: arguments.toUserID},
                    fromUserID: {type: "numeric", value: arguments.fromUserID}
                },
                sql = "
                    SELECT strUUID,
                            (SELECT CONCAT(strFirstName, ' ', strLastName) FROM users WHERE intUserID = :fromUserID) as fromName,
                            (SELECT strEmail FROM users WHERE intUserID = :fromUserID) as fromEmail,
                            (SELECT CONCAT(strFirstName, ' ', strLastName) FROM users WHERE intUserID = :toUserID) as toName,
                            (SELECT strEmail FROM users WHERE intUserID = :toUserID) as toEmail
                    FROM users
                    WHERE intUserID = :toUserID
                "
            )

            local.thisUUID = local.qUser.strUUID;

            if (local.qUser.recordCount) {

                // UUID already set?
                if (!len(trim(local.qUser.strUUID))) {

                    local.thisUUID = application.objGlobal.getUUID();

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            userID: {type: "numeric", value: arguments.toUserID},
                            newUUID: {type: "nvarchar", value: local.thisUUID}
                        },
                        sql = "
                            UPDATE users
                            SET strUUID = :newUUID
                            WHERE intUserID = :userID
                        "
                    )

                }




                // Replacing variables
                local.invitationMail = replaceNoCase(variables.getTrans('txtInvitationMail'), '@sender_name@', '#qUser.fromName#', 'all');
                local.invitationMail = replaceNoCase(local.invitationMail, '@project_name@', '#application.projectName#', 'all');

                variables.mailTitle = variables.getTrans('txtInvitationFrom') & " " & qUser.fromName;
                variables.mailType = "html";




                cfsavecontent (variable = "variables.mailContent") {
                    echo("
                        #variables.getTrans('titHello')# #local.qUser.toName#<br><br>
                        #local.invitationMail#<br><br>
                        <a href='#application.mainURL#/registration?u=#local.thisUUID#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#variables.getTrans('formSignIn')#</a><br><br>

                        #variables.getTrans('txtRegards')#<br>
                        #variables.getTrans('txtYourTeam')#<br>
                        #application.appOwner#
                    ");
                }

                // Send activation link
                mail to="#local.qUser.toEmail#" from="#application.fromEmail#" subject="#variables.getTrans('txtInvitationFrom')# #local.qUser.fromName#" type="html" {
                    include template="/config.cfm";
                    include template="/includes/mail_design.cfm";
                }

                local.argsReturnValue['message'] = variables.getTrans('msgUserGotInvitation');
                local.argsReturnValue['success'] = true;

            } else {

                local.argsReturnValue['message'] = "No user found!";

            }


        } else {

            local.argsReturnValue['message'] = "Wrong id's";

        }

        return local.argsReturnValue;

    }


    // Get users image
    public struct function getUserImage(required numeric userID) {

        local.userData = application.objCustomer.getUserDataByID(arguments.userID);

        local.myImgStruct = structNew();

        if (len(trim(local.userData.strPhoto)) and fileExists(expandpath('/userdata/images/users/#local.userData.strPhoto#'))) {

            local.myImgStruct['userImage'] = "#application.mainURL#/userdata/images/users/#local.userData.strPhoto#";
            local.myImgStruct['itsLocal'] = true;

        } else {

            // Look for a gravatar.com picture or use the default picture
            local.myImgStruct['userImage'] = "https://www.gravatar.com/avatar/#lcase(Hash(lcase(local.userData.strEmail)))#?d=mp&s=300";
            local.myImgStruct['itsLocal'] = false;

        }

        return local.myImgStruct;

    }


    // If an e-mail address was changed, we need to send a confirmation e-mail
    public boolean function mailChangeConfirm(required string useremail, required numeric mailuserID){

        local.qUsersMailCheck = queryExecute(
            options = {datasource = application.datasource},
            params = {
                userID: {type: "numeric", value: arguments.mailuserID}
            },
            sql = "
                SELECT *
                FROM users
                WHERE intUserID = :userID
            "
        )

        if (local.qUsersMailCheck.strEmail neq arguments.useremail) {

            local.newUUID = application.objGlobal.getUUID();

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    userID: {type: "numeric", value: arguments.mailuserID},
                    uuID: {type: "nvarchar", value: local.newUUID}
                },
                sql = "
                    UPDATE users
                    SET strUUID = :uuID
                    WHERE intUserID = :userID
                "
            )

            variables.mailTitle = variables.getTrans('subjectConfirmEmail');
            variables.mailType = "html";
            local.toName = local.qUsersMailCheck.strFirstName & ' ' & local.qUsersMailCheck.strLastName;

            cfsavecontent (variable = "variables.mailContent") {

                echo("
                    #variables.getTrans('titHello')# #local.toName#<br><br>
                    #variables.getTrans('txtComfirmEmailChange')#<br><br>
                    <a href='#application.mainURL#/account-settings/my-profile?c=#local.newUUID#&nMail=#arguments.useremail#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#variables.getTrans('btnActivate')#</a>
                    <br><br>
                    #variables.getTrans('txtRegards')#<br>
                    #variables.getTrans('txtYourTeam')#<br>
                    #application.appOwner#
                ");
            }

            // Send activation link
            mail to="#arguments.useremail#" from="#application.fromEmail#" subject="#variables.getTrans('subjectConfirmEmail')#" type="html" {
                include template="/config.cfm";
                include template="/includes/mail_design.cfm";
            }

            local.mailChanged = true;

        } else {

            local.mailChanged = false;

        }

        return local.mailChanged;

    }


    // After the customer has clicked the confirmation e-mail, we update the database
    public struct function updateEmail(required string newUserMail, required numeric confUserID){

        local.argsReturnValue = structNew();

        try {

             queryExecute(

                options = {datasource = application.datasource},
                params = {
                    userID: {type: "numeric", value: arguments.confUserID},
                    email: {type: "nvarchar", value: arguments.newUserMail}
                },
                sql = "

                    UPDATE users
                    SET strEmail = :email
                    WHERE intUserID = :userID

                "
            )

            local.argsReturnValue['message'] = getTrans('txtEmailUpdated');
            local.argsReturnValue['success'] = true;

        }
        catch(any) {

            local.argsReturnValue['message'] = cfcatch.message;
            local.argsReturnValue['success'] = false;
        }

        return local.argsReturnValue;

    }

}