<cfscript>

// Logout and delete all sessions
if (structKeyExists(url, "logout")) {

    structClear(SESSION);
    onSessionStart();

    location url="#application.mainURL#/login?logout" addtoken="no";
}


// Switch the company/tenant
if (structKeyExists(url, "switch")) {

    if (isNumeric(url.switch)) {

        qTenant = queryExecute(

            options = {datasource = application.datasource},
            params = {
                intCustomerID: {type: "numeric", value = url.switch},
                intUserID: {type: "numeric", value = session.user_id}
            },
            sql = "
                SELECT customers.intCustomerID
                FROM customers INNER JOIN customer_user ON customers.intCustomerID = customer_user.intCustomerID
                WHERE customers.intCustomerID = :intCustomerID AND customer_user.intUserID = :intUserID
            "
        )

        if (qTenant.recordCount) {

            session.customer_id = qTenant.intCustomerID;

            // Set plans and modules as well as the custom settings into a session
            application.objCustomer.setProductSessions(session.customer_id, session.lng);

            // Is the needed data of the cutomer already filled out?
            dataFilledIn = new com.register().checkFilledData(session.customer_id);

            if (!dataFilledIn) {
                session.filledData = false;
            }

            logWrite("Switch tenant", 1, "File: #callStackGet("string", 0 , 1)#, User: #session.user_id#, Successfully changed tenant!", false);
            location url="#application.mainURL#/dashboard" addtoken="no";

        } else {

            location url="#application.mainURL#/global?logout" addtoken="no";

        }

    }


}


// Notifications (set as read and multiple delete)
if (structKeyExists(form, "noti_action")) {

    param name="url.page" default="1" type="numeric";

    if (!len(trim(form.noti_action)) or !structKeyExists(form, "notiID")) {
        location url="#application.mainURL#/notifications?page=#url.page#" addtoken="no";
    }

    local.objNotification = new com.notifications();

    if (form.noti_action eq "read") {

        loop list=form.notiID index="i" {

            local.objNotification.setRead(i, session.customer_id);

        }

        location url="#application.mainURL#/notifications?page=#url.page#" addtoken="no";

    } else if (form.noti_action eq "delete") {

        loop list=form.notiID index="i" {

            local.objNotification.delNoti(i, session.customer_id);
            getAlert('alertMultipleNotificationDeleted');

        }

        location url="#application.mainURL#/notifications?page=1" addtoken="no";

    }

}


// Delete notification
if (structKeyExists(url, "noti_del")) {

    if (isNumeric(url.noti_del)) {

        new com.notifications().delNoti(url.noti_del, session.customer_id);
        getAlert('alertNotificationDeleted');

    }

    location url="#application.mainURL#/notifications?page=#url.page#" addtoken="no";

}


</cfscript>