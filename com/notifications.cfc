
component displayname="notifications" output="false" {

    // Create a notification entry
    public struct function insertNotification(required struct notiStruct) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.userID = 0;
        local.title_var = "";
        local.descr_var = "";
        local.link = "";
        local.linktext_var = "";

        if (structKeyExists(arguments.notiStruct, "customerID") and isNumeric(arguments.notiStruct.customerID)) {
            local.customerID = arguments.notiStruct.customerID;
        } else {
            local.argsReturnValue['message'] = "No customerID found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(arguments.notiStruct, "userID") and isNumeric(arguments.notiStruct.userID)) {
            local.userID = arguments.notiStruct.userID;
        }
        if (structKeyExists(arguments.notiStruct, "title_var") and (len(trim(arguments.notiStruct.title_var)))) {
            local.title_var = left((trim(arguments.notiStruct.title_var)), 50);
        }
        if (structKeyExists(arguments.notiStruct, "descr_var") and (len(trim(arguments.notiStruct.descr_var)))) {
            local.descr_var = left((trim(arguments.notiStruct.descr_var)), 50);
        }
        if (structKeyExists(arguments.notiStruct, "link") and (len(trim(arguments.notiStruct.link)))) {
            local.link = left(trim(arguments.notiStruct.link), 255);
        }
        if (structKeyExists(arguments.notiStruct, "linktext_var") and (len(trim(arguments.notiStruct.linktext_var)))) {
            local.linktext_var = left((trim(arguments.notiStruct.linktext_var)), 50);
        }

        try {

            queryExecute(
                options = {datasource=application.datasource, result="local.newID"},
                params = {
                    customerID: {type: "numeric", value: local.customerID},
                    userID: {type: "numeric", value: local.userID},
                    title_var: {type: "nvarchar", value: local.title_var},
                    descr_var: {type: "nvarchar", value: local.descr_var},
                    link: {type: "nvarchar", value: local.link},
                    linktext_var: {type: "nvarchar", value: local.linktext_var},
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "
                    INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar)
                    VALUES (:customerID, :userID, :dateNow, :title_var, :descr_var, :link, :linktext_var)
                "
            )

            local.argsReturnValue['newID'] = local.newID.generatedkey;
            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch (any e) {

            local.argsReturnValue['message'] = e.message;

        }

        return local.argsReturnValue;

    }


    // Get all notifications
    public struct function getNotifications(required numeric customerID, numeric start, numeric count) {

        local.queryLimit;
        local.queryOrder;

        if (structKeyExists(arguments, "start") and structKeyExists(arguments, "count")) {
            local.queryLimit = "LIMIT #arguments.start#, #arguments.count#"
        }

        if (structKeyExists(arguments, "order")) {
            local.queryOrder = "ORDER BY " & arguments.order;
        }

        local.qTotalCount = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT COUNT(intCustomerID) as totalCount
                FROM notifications
                WHERE intCustomerID = :customerID
            "
        )

        local.notificationStruct = structNew();
        local.notificationStruct['totalCount'] = qTotalCount.totalCount;
        local.notificationStruct['arrayNoti'] = "";

        local.qNotifications = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT *
                FROM notifications
                WHERE intCustomerID = :customerID
                ORDER BY dtmCreated DESC
                #local.queryLimit#
            "
        )

        local.arrayNoti = arrayNew(1);

        cfloop(query="local.qNotifications") {

            local.notiStruct = structNew();

            local.notiStruct['notiID'] = local.qNotifications.intNotificationID;
            local.notiStruct['customerID'] = local.qNotifications.intCustomerID;
            local.notiStruct['userID'] = local.qNotifications.intUserID;
            local.notiStruct['created'] = local.qNotifications.dtmCreated;
            local.notiStruct['title_var'] = local.qNotifications.strTitleVar;
            local.notiStruct['desc_var'] = local.qNotifications.strDescrVar;
            local.notiStruct['link'] = local.qNotifications.strLink;
            local.notiStruct['link_text_var'] = local.qNotifications.strLinkTextVar;
            local.notiStruct['read'] = local.qNotifications.dtmRead;

            arrayAppend(local.arrayNoti, local.notiStruct);

        }

        local.notificationStruct['arrayNoti'] = local.arrayNoti;

        return local.notificationStruct;

    }



}