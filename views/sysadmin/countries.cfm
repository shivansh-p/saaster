<cfscript>
    param name="session.c_search" default="" type="string";
    param name="session.c_sort" default="intPrio" type="string";
    param name="session.start" default=1 type="numeric";

    // Check if url "start" exists
    if (structKeyExists(url, "start") and not isNumeric(url.start)) {
        abort;
    }

    // Pagination
    getEntries = 10;
    if( structKeyExists(url, 'start')){
        session.start = url.start;
    }
    next = session.start+getEntries;
    prev = session.start-getEntries;
    session.sql_start = session.start-1;

    // Search
    if(structKeyExists(form, 'search') and len(trim(form.search))){
        session.c_search = form.search;
    }else if (structKeyExists(form, 'delete') or structKeyExists(url, 'delete')) {
        session.c_search = '';
    }
    
    // Sorting
    if(structKeyExists(form, 'sort')){  
        session.c_sort = form.sort;
    }

    qTotalCountries = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COUNT(intCountryID) as totalCountries
            FROM countries
            WHERE blnActive = 1
        "
    );

    if (len(trim(session.c_search))) {
        qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                AND (
                    strCountryName LIKE '%#session.c_search#%' OR
                    strLocale LIKE '%#session.c_search#%' OR
                    strISO1 LIKE '%#session.c_search#%' OR
                    strISO2 LIKE '%#session.c_search#%' OR
                    strCurrency LIKE '%#session.c_search#%' OR
                    strRegion LIKE '%#session.c_search#%' OR
                    strSubRegion LIKE '%#session.c_search#%' OR
                    strTimezone   LIKE '%#session.c_search#%'
                )
                ORDER BY #session.c_sort#
                LIMIT #session.sql_start#, #getEntries#
            "
        );
    } 
    else {
        qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                ORDER BY #session.c_sort#
                LIMIT #session.sql_start#, #getEntries#
            "
        )
    }

    qLanguages = application.objGlobal.getAllLanguages();
    timeZones = createObject("component", "com.sysadmin").getTimezones();
    getModal = createObject("component", "com.translate");
</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-6 mb-3">
                    <div class="page-header">
                        <h4 class="page-title">Countries</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Countries</li>
                        </ol>
                    </div>
                </div>
                <div class="col-lg-6 mb-3">
                    <div class="row">
                        <div class="col-lg-9">
                            <div class="page-header text-end">
                                <div>
                                    <a href="#application.mainURL#/sysadmin/countries/import?delete" class="btn btn-primary">
                                        <i class="fas fa-file-import pe-3"></i> Import countries
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="page-header">
                                <div>
                                    <a href="##" data-bs-toggle="modal" data-bs-target="##country_new" class="btn btn-primary">
                                        <i class="fas fa-plus pe-3"></i> New country
                                    </a>
                                <div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
        <div class="container-xl">
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <div class="card-body">
                            <p>You have <b>#qTotalCountries.totalCountries#</b> countries activated. In this list you will only find activated countries. If you want to activate more countries, click to the "Import" or "Add" button.</p>
                            <form action="#application.mainURL#/sysadmin/countries?start=1" method="post">
                                <div class="row">
                                    <div class="col-lg-4">
                                        <label class="form-label">Search for country:</label>
                                        <div class="input-group mb-2">
                                            <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                            <button class="btn bg-green-lt" type="submit">Go!</button>
                                            <cfif len(trim(session.c_search))>
                                                <button class="btn bg-red-lt" name="delete" type="submit" data-bs-toggle="tooltip" data-bs-placement="top" title="Delete search">
                                                    #session.c_search# <i class="ms-2 fas fa-times"></i>
                                                </button>
                                            </cfif>
                                        </div>
                                    </div>
                                    <div class="col-lg-5"></div>
                                    <div class="col-lg-3">
                                        <div class="mb-3">
                                            <div class="form-label">Sort countries</div>
                                            <select class="form-select" name="sort" onchange="this.form.submit()">
                                                <option value="intPrio ASC" <cfif session.c_sort eq "intPrio ASC">selected</cfif>>By prio asc</option>
                                                <option value="intPrio DESC" <cfif session.c_sort eq "intPrio DESC">selected</cfif>>By prio desc</option>
                                                <option value="strCountryName ASC" <cfif session.c_sort eq "strCountryName ASC">selected</cfif>>Country name A -> Z</option>
                                                <option value="strCountryName DESC" <cfif session.c_sort eq "strCountryName DESC">selected</cfif>>Country name Z -> A</option>
                                                <option value="strRegion ASC" <cfif session.c_sort eq "strRegion ASC">selected</cfif>>Region A -> Z</option>
                                                <option value="strRegion DESC" <cfif session.c_sort eq "strRegion DESC">selected</cfif>>Region Z -> A</option>
                                                <option value="blnDefault DESC" <cfif session.c_sort eq "blnDefault DESC">selected</cfif>>Show default Country first</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </form>
                            <div class="table-responsive">
                                <table class="table card-table table-vcenter text-nowrap">
                                    <thead>
                                        <tr>
                                            <th width="5%" class="text-center">Prio</th>
                                            <th width="5%" class="text-center">Default</th>
                                            <th width="30%">Country</th>
                                            <th width="10%" class="text-center">ISO 1</th>
                                            <th width="20%">Region</th>
                                            <th width="20%">Language</th>
                                            <th width="5%"></th>
                                            <th width="5%"></th>
                                        </tr>
                                    </thead>
                                    <tbody id="dragndrop_body">
                                    <cfloop query="qCountries">
                                        <tr>
                                            <td class="text-center">#qCountries.intPrio#</td>
                                            <td class="text-center">#yesNoFormat(qCountries.blnDefault)#</td>
                                            <td>#qCountries.strCountryName# <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##country_#qCountries.intCountryID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate country name"></i></a></td>
                                            <td class="text-center">#qCountries.strISO1#</td>
                                            <td>#qCountries.strRegion#</td>
                                            <td>#qCountries.strLanguageEN#</td>
                                            <td><a href="##" class="btn openPopup" data-bs-toggle="modal" data-href="#application.mainURL#/views/sysadmin/ajax_country.cfm?countryID=#qCountries.intCountryID#">Edit</a></td>
                                            <td><cfif !qCountries.blnDefault><a href="#application.mainURL#/sysadm/countries?remove_country=#qCountries.intCountryID#" class="btn">Remove</a></cfif></td>
                                        </tr>
                                        #getModal.init('countries', 'strCountryName', qCountries.intCountryID, 100).openModal('country', cgi.path_info, 'Translate country name')#
                                    </cfloop>
                                    </tbody>

                                    <div id="dynModal" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                            <div class="modal-content" id="dyn_modal-content">
                                                <!--- dynamic content from ajax request (ajax_sort.cfm) --->
                                            </div>
                                        </div>
                                    </div>
                                    <div id="country_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                            <form action="#application.mainURL#/sysadm/countries" method="post">
                                            <input type="hidden" name="new_country">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">New Country</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="row">
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Country name (english)</label>
                                                                <input type="text" name="country" class="form-control" autocomplete="off" maxlength="100" required>
                                                            </div>
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Language</label>
                                                                <select name="languageID" class="form-select">
                                                                    <option value=""></option>
                                                                    <cfloop query="qLanguages">
                                                                        <option value="#qLanguages.intLanguageID#">#qLanguages.strLanguageEN#</option>
                                                                    </cfloop>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-3">
                                                                <div class="mb-3">
                                                                    <label class="form-label">Locale</label>
                                                                    <div class="input-group input-group-flat">
                                                                        <input type="text" class="form-control" name="locale" autocomplete="off" maxlength="20">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-3">
                                                                <div class="mb-3">
                                                                    <label class="form-label">ISO 1</label>
                                                                    <div class="input-group input-group-flat">
                                                                        <input type="text" class="form-control" name="iso1" autocomplete="off" maxlength="3">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-3">
                                                                <div class="mb-3">
                                                                    <label class="form-label">ISO 2</label>
                                                                    <div class="input-group input-group-flat">
                                                                        <input type="text" class="form-control" name="iso2" autocomplete="off" maxlength="3">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-3">
                                                                <div class="mb-3">
                                                                    <label class="form-label">Currency</label>
                                                                    <div class="input-group input-group-flat">
                                                                        <input type="text" class="form-control" name="currency" autocomplete="off" maxlength="20">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Region</label>
                                                                <input type="text" name="region" class="form-control" autocomplete="off" maxlength="100">
                                                            </div>
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Subregion</label>
                                                                <input type="text" name="subregion" class="form-control" autocomplete="off" maxlength="100">
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-5 mb-3">
                                                                <label class="form-label">Flag</label>
                                                                <input type="text" name="flag" class="form-control" autocomplete="off" maxlength="255" value="https://flagcdn.com/xx.svg">
                                                            </div>
                                                            <div class="col-lg-1 mb-3 pt-4">
                                                            </div>
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Timezone</label>
                                                                <select name="timezone" class="form-select">
                                                                    <option value=""></option>
                                                                    <cfloop array="#timeZones#" index="i">
                                                                        <option value="#i#">#i#</option>
                                                                    </cfloop>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label"></label>

                                                            </div>
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Default</label>
                                                                <label class="form-check form-switch">
                                                                    <input class="form-check-input" type="checkbox" name="default">
                                                                    <span class="form-check-label">Default country</span>
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                        <button type="submit" class="btn btn-primary ms-auto">
                                                            Save language
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </table>
                            </div>
                            <div class="pt-4 card-footer d-flex align-items-center">
                                <ul class="pagination m-0 ms-auto">
                                    <li class="page-item <cfif session.start lt getEntries>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?start=#prev#" tabindex="-1" aria-disabled="true">
                                            <i class="fas fa-angle-left"></i> prev
                                        </a>
                                    </li>
                                    <li class="ms-3 page-item <cfif qTotalCountries.totalCountries lt next>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?start=#next#">
                                            next <i class="fas fa-angle-right"></i>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>