<cfscript>
    param name="session.search" default="" type="string";
    param name="url.tr" default="custom" type="string";

    s_badge_custom = "";
    s_badge_system = "";

    if(structKeyExists(form, "search") and len(trim(form.search))) {
        session.search = form.search;
    } else if (structKeyExists(form, "delete")) {
        session.search = "";
    }

    // The language query is used in order to translate entries
    qLanguages = queryExecute (
        options = {datasource = application.datasource},
        sql = "
            SELECT intLanguageID, strLanguageISO, strLanguageEN, strLanguage, blnDefault, intPrio
            FROM languages
            ORDER BY blnDefault DESC, intPrio
        "
    )

    // When entering a search
    if(len(trim(session.search))) {

        // Custom results
        defaultQueryCustom = "
            SELECT *
            FROM custom_translations
            WHERE strVariable LIKE '%#session.search#%'
        ";
        orListCustom = "";
        orderQryCustom = "
            ORDER BY strVariable
        ";

        // Loop over query and append to query string
        loop query=qLanguages {
            orListCustom = listAppend(orListCustom, "OR strString#qLanguages.strLanguageISO# LIKE '%#session.search#%'", " ");
        }

        cfquery(datasource=application.datasource name="qCustomResults") {
            writeOutput(defaultQueryCustom & orListCustom & orderQryCustom);
        }

        s_badge_custom = "";

        if(qCustomResults.recordCount){
            s_badge_custom = "<span class='mx-2 badge bg-green'>#qCustomResults.recordCount#</span>";
        }else {
            s_badge_custom = "<span class='mx-2 badge bg-red'>0</span>";
        }


        // System results
        defaultQuerySys = "
        SELECT *
        FROM system_translations
        WHERE strVariable LIKE '%#session.search#%'
        ";
        orListSys = "";
        orderQrySys = "
            ORDER BY strVariable
        ";

        // Loop over query and append to query string
        loop query=qLanguages {
            orListCustom = listAppend(orListSys, "OR strString#qLanguages.strLanguageISO# LIKE '%#session.search#%'", " ");
        }

        cfquery(datasource=application.datasource name="qSystemResults") {
            writeOutput(defaultQuerySys & orListSys & orderQrySys);
        }

        s_badge_system = "";

        if(qSystemResults.recordCount){
            s_badge_system = "<span class='mx-2 badge bg-green'>#qSystemResults.recordCount#</span>";
        }else {
            s_badge_system = "<span class='mx-2 badge bg-red'>0</span>";
        }

        // Create getModal object
        getModal = createObject("component", "com.translate")
    }
</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">
                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Translations</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Translations</li>
                        </ol>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <ul class="nav nav-tabs" data-bs-toggle="tabs">
                            <li class="nav-item"><a href="##custom" class="nav-link <cfif url.tr eq "custom">active</cfif>" data-bs-toggle="tab">Custom translations #s_badge_custom#</a></li>
                            <li class="nav-item"><a href="##system" class="nav-link <cfif url.tr eq "system">active</cfif>" data-bs-toggle="tab">System translations #s_badge_system#</a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div id="custom" class="card tab-pane show <cfif url.tr eq "custom">active</cfif>">
                            <div class="card-body">
                                <div class="card-title">Custom translations</div>
                                <p>Here you can create your own translations (variables). These are used for system texts and are called with the function "getTrans()". These translations are not affected by any system updates.</p>
                                <div class="row">
                                    <div class="col-lg-4">
                                        <form action="#application.mainURL#/sysadmin/translations" method="post">
                                            <label class="form-label">Search for translations:</label>
                                            <div class="input-group mb-2">
                                                <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                                <button class="btn bg-green-lt" type="submit">Go!</button>
                                                <cfif len(trim(session.search))>
                                                    <button class="btn bg-red-lt" name="delete" type="submit">Delete search!</button>
                                                </cfif>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="col-lg-8 text-end px-4">
                                        <br>
                                        <a href="##" data-bs-toggle="modal" data-bs-target="##lng_trans" class="btn btn-primary">
                                            <i class="fas fa-plus pe-3"></i> Add custom translation
                                        </a>
                                    </div>
                                </div>
                                <div class="row">

                                    <div class="table-responsive">
                                        <table class="table table-vcenter card-table">
                                            <cfif len(trim(session.search))>
                                                <thead>
                                                    <tr>
                                                        <th width="30%">Variable</th>
                                                        <th width="65%">Text #qLanguages.strLanguageEN# (default)</th>
                                                        <th width="5%"></th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                <cfif qCustomResults.recordCount>
                                                    <cfloop query="qCustomResults">
                                                        <tr>
                                                            <td>#qCustomResults.strVariable#</td>
                                                            <td>#evaluate("qCustomResults.strString#ucase(application.objGlobal.getDefaultLanguage().iso)#")# <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##modal_#qCustomResults.intCustTransID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate content"></i></a></td>
                                                            <td class="text-left"><a href="#application.mainURL#/sysadm/translations?delete_trans=#qCustomResults.intCustTransID#" title="Delete"><i class="fas fa-times text-red" style="font-size: 20px;"></i></a></td>
                                                        </tr>
                                                        <!--- Modal for translations --->
                                                        <div id="modal_#qCustomResults.intCustTransID#" class="modal modal-blur fade" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
                                                            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                                <form action="#application.mainURL#/sysadm/translations" method="post">
                                                                <input type="hidden" name="edit_variable" value="#qCustomResults.intCustTransID#">
                                                                    <div class="modal-content">
                                                                        <div class="modal-header">
                                                                            <h5 class="modal-title">Translate content</h5>
                                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                        </div>
                                                                        <div class="modal-body">
                                                                            <p></p>
                                                                            <cfloop query="qLanguages">
                                                                                <div class="mb-3">
                                                                                    <div class="hr-text hr-text-left my-2">#qLanguages.strLanguageEN#</div>
                                                                                    <textarea class="form-control" name="text_#qLanguages.strLanguageISO#" placeholder="Text in #lcase(qLanguages.strLanguageEN)#" required>#evaluate("qCustomResults.strString#ucase(qLanguages.strLanguageISO)#")#</textarea>
                                                                                </div>
                                                                            </cfloop>
                                                                        </div>
                                                                        <div class="modal-footer">
                                                                            <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                            <button type="submit" class="btn btn-primary ms-auto">
                                                                                Save translation
                                                                            </button>
                                                                        </div>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </cfloop>
                                                <cfelse>
                                                    <tr><td colspan="100%">No results found.</td></tr>
                                                </cfif>
                                                </tbody>
                                            </cfif>

                                            <!--- Modal for new translations --->
                                            <div id="lng_trans" class="modal modal-blur fade" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
                                                <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                    <form action="#application.mainURL#/sysadm/translations" method="post">
                                                    <input type="hidden" name="new_variable">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title">New translation</h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                            </div>
                                                            <div class="modal-body">
                                                                <div class="mb-3">
                                                                    <label class="form-label">Variable</label>
                                                                    <input type="text" class="form-control" name="variable" placeholder="Add new variable" minlength="3" maxlength="100" required>
                                                                </div>
                                                                <cfloop query="qLanguages">
                                                                    <div class="mb-3">
                                                                        <div class="hr-text hr-text-left my-2">#qLanguages.strLanguageEN#</div>
                                                                        <textarea class="form-control" name="text_#qLanguages.strLanguageISO#" placeholder="Text in #lcase(qLanguages.strLanguageEN)#" required></textarea>
                                                                    </div>
                                                                </cfloop>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                <button type="submit" class="btn btn-primary ms-auto">
                                                                    Save translation
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </table>
                                    </div>
                                </div>
                            </div>

                        </div>
                        <div id="system" class="card tab-pane show <cfif url.tr eq "system">active</cfif>">
                            <div class="card-body">
                                <div class="card-title">System translations</div>
                                <p class="text-red">The system translations are used by the developers of the saaster.io project. Users of the tool should only perform translations and not change any variables. Co-developers can request changes via Github.</p>
                                <div class="col-lg-4">
                                    <form action="#application.mainURL#/sysadmin/translations?tr=system" method="post">
                                        <label class="form-label">Search for translations:</label>
                                        <div class="input-group mb-2">
                                            <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                            <button class="btn bg-green-lt" type="submit">Go!</button>
                                            <cfif len(trim(session.search))>
                                                <button class="btn bg-red-lt" name="delete" type="submit">Delete search!</button>
                                            </cfif>
                                        </div>
                                    </form>
                                </div>
                                <div class="row">
                                    <cfif len(trim(session.search))>
                                        <cfif qSystemResults.recordCount>
                                            <div class="table-responsive">
                                                <table class="table table-vcenter card-table">
                                                    <thead>
                                                        <tr>
                                                            <th width="30%">Variable</th>
                                                            <th width="70%">Text</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <cfloop query="qSystemResults">
                                                            <tr>
                                                                <td>#qSystemResults.strVariable#</td>
                                                                <td>#evaluate("qSystemResults.strString#application.objGlobal.getDefaultLanguage().iso#")# <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##syst_modal_#qSystemResults.intSystTransID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate content"></i></a></td>
                                                            </tr>
                                                            <!--- Modal for translations --->
                                                            <div id="syst_modal_#qSystemResults.intSystTransID#" class="modal modal-blur fade" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
                                                                <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                                    <form action="#application.mainURL#/sysadm/translations" method="post">
                                                                    <input type="hidden" name="edit_syst_variable" value="#qSystemResults.intSystTransID#">
                                                                        <div class="modal-content">
                                                                            <div class="modal-header">
                                                                                <h5 class="modal-title">Translate content</h5>
                                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                            </div>
                                                                            <div class="modal-body">
                                                                                <p></p>
                                                                                <cfloop query="qLanguages">
                                                                                    <div class="mb-3">
                                                                                        <div class="hr-text hr-text-left my-2">#qLanguages.strLanguageEN#</div>
                                                                                        <textarea class="form-control" name="text_#qLanguages.strLanguageISO#" placeholder="Text in #lcase(qLanguages.strLanguageEN)#" required>#evaluate("qSystemResults.strString#ucase(qLanguages.strLanguageISO)#")#</textarea>
                                                                                    </div>
                                                                                </cfloop>
                                                                            </div>
                                                                            <div class="modal-footer">
                                                                                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                                <button type="submit" class="btn btn-primary ms-auto">
                                                                                    Save translation
                                                                                </button>
                                                                            </div>
                                                                        </div>
                                                                    </form>
                                                                </div>
                                                            </div>
                                                        </cfloop>
                                                    </tbody>
                                                </table>
                                            </div>
                                        <cfelse>
                                            <p>No results found.</p>
                                        </cfif>
                                    </cfif>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>