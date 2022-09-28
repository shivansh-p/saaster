
<cfscript>

qAllLanguages = application.objGlobal.getAllLanguages();


if (structKeyExists(form, "new_variable")) {

    param name="form.variable" default="";

    qCheckDouble = queryExecute(
        options = {datasource = application.datasource},
        params = {
            variable: {type: "varchar", value: form.variable}
        },
        sql = "
            SELECT strVariable
            FROM custom_translations
            WHERE strVariable = :variable
        "
    )

    if (qCheckDouble.recordCount) {

        getAlert('This variable is already in use!', 'danger');
        location url="#application.mainURL#/sysadmin/translations" addtoken="false";

    } else {

        savecontent variable="mySQL" {

            writeOutput("INSERT INTO custom_translations (strVariable");

            loop query = qAllLanguages {
                writeOutput(",strString#qAllLanguages.strLanguageISO#");
            }

            writeOutput(") VALUES ('#form.variable#'");

            loop query = qAllLanguages {
                writeOutput(",'#evaluate('form.text_#qAllLanguages.strLanguageISO#')#'");
            }

            writeOutput(")");

        }

        cfquery( datasource=application.datasource ) {
            writeOutput(mySQL);
        }

    }

    getAlert('Variable added successfully.', 'success');
    session.search = form.variable;
    location url="#application.mainURL#/sysadmin/translations" addtoken="false";

}


if (structKeyExists(url, "delete_trans")) {

    if (isNumeric(url.delete_trans)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                transID: {type: "numeric", value: url.delete_trans}
            },
            sql = "
                DELETE FROM custom_translations WHERE intCustTransID = :transID
            "
        )

        getAlert('Translation deleted', 'success');
        structDelete(session, "search");
        location url="#application.mainURL#/sysadmin/translations" addtoken="false";

    }

}



if (structKeyExists(form, "edit_variable")) {

    if (isNumeric(form.edit_variable)) {

        savecontent variable="mySQL" {

            writeOutput("UPDATE custom_translations SET intCustTransID = intCustTransID ");

            loop query = qAllLanguages {
                writeOutput(", strString#qAllLanguages.strLanguageISO# = '#evaluate('form.text_#qAllLanguages.strLanguageISO#')#' ");
            }
            writeOutput("WHERE intCustTransID = #form.edit_variable#");
        }

        cfquery( datasource=application.datasource ) {
            writeOutput(mySQL);
        }

        getAlert('Translation saved!', 'success');
        location url="#application.mainURL#/sysadmin/translations" addtoken="false";
    }

}


if (structKeyExists(form, "edit_syst_variable")) {

    if (isNumeric(form.edit_syst_variable)) {

        savecontent variable="mySQL" {

            writeOutput("UPDATE system_translations SET intSystTransID = intSystTransID ");

            loop query = qAllLanguages {
                writeOutput(", strString#qAllLanguages.strLanguageISO# = '#evaluate('form.text_#qAllLanguages.strLanguageISO#')#' ");
            }
            writeOutput("WHERE intSystTransID = #form.edit_syst_variable#");
        }

        cfquery( datasource=application.datasource ) {
            writeOutput(mySQL);
        }

        getAlert('Translation saved!', 'success');
        location url="#application.mainURL#/sysadmin/translations?tr=system" addtoken="false";
    }

}


if (structKeyExists(form, "bulk_translate")) {

    param name="form.apiKey" default=0;
    param name="form.apiType" default=0;
    param name="form.fromLang" default=0;
    param name="form.toLang" default=0;

    // Translate
    if (form.apiKey neq 0 and form.fromLang neq 0 and form.toLang neq 0) {

            // Set "Pro" or "Free" API-URL
            deepLPro = "https://api.deepl.com/v2/translate?auth_key=";
            deepLFree = "https://api-free.deepl.com/v2/translate?auth_key=";

            deeplURL = (form.apiType eq 0 ? deepLFree : deepLPro);

            // Test if key is valid
            deeplTest = deeplURL & form.apiKey;
            deeplTest = deeplTest & "&text=test";
            deeplTest = deeplTest & "&source_lang=" & form.fromLang & "&target_lang=" & form.toLang;
            cfhttp( url=deeplTest, resolveurl=true, method="get", timeout="30");

            // Test if language is supported
            lngSupported = cfhttp.filecontent;
            lngSupported = findNoCase("target_lang", lngSupported, 0);

            // If the provided API key is not valid, redirect back to translate page
            if(cfhttp.status_code eq 403){
                getAlert('The provided API key is not valid!', 'warning');
                location url="#application.mainURL#/sysadmin/translations?tr=bulk" addtoken="false";
            }

            if(lngSupported gt 0){
                getAlert('The requested language is not supported by DeepL!', 'warning');
                location url="#application.mainURL#/sysadmin/translations?tr=bulk" addtoken="false";
            }

            gettext = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT strStringEN, strVariable
                    FROM system_translations
                "
            )

            loop query = gettext {
                deepl = deeplURL & form.apiKey;
                deepl = deepl & "&text=" & urlencodedformat(gettext.strStringEN);
                deepl = deepl & "&source_lang=" & form.fromLang & "&target_lang=" & form.toLang;

                cfhttp( url=deepl, resolveurl=true, method="get", timeout="30" );
                deepl_answer = deserializeJSON(cfhttp.FileContent);

                if(structKeyExists(deepl_answer, "translations")) {
                    translatedText = deepl_answer.translations[1].text;
                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            transText: {type: "varchar", value: translatedText},
                            changedText: {type: "varchar", value: strVariable}
                        },
                        sql = "
                            UPDATE system_translations
                            SET strString#form.toLang# = :transText
                            WHERE strVariable = :changedText
                        "
                    )
                }
            }

            getAlert('The translation finished successfully!');
            location url="#application.mainURL#/sysadmin/translations?tr=bulk" addtoken="false";
    }
}

</cfscript>