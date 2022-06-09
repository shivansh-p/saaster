<cfscript>
    param name="session.c_search" default="" type="string";
    param name="session.c_sort" default="intPrio" type="string";
    param name="session.c_page" default=1 type="numeric";


    local.getEntries = 10;
    local.c_start = 0;

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

    if (len(trim(session.c_search))) {
        local.qTotalCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries, countries.*, languages.strLanguageEN
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
                LIMIT #local.c_start#, #getEntries#
            "
        );
    }
    else {
        local.qTotalCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries, countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                ORDER BY #session.c_sort#
                LIMIT #local.c_start#, #getEntries#
            "
        )
    }

    local.pages = ceiling(local.qTotalCountries.totalCountries / local.getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt local.pages) {  
        session.c_page = url.page;
    }

    if (session.c_page gt 1){
        local.tPage = session.c_page - 1;
        local.valueToAdd = local.getEntries * tPage;
        local.c_start = local.c_start + local.valueToAdd;
    }

    if (len(trim(session.c_search))) {
        local.qCountries = queryExecute(
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
                    strSubRegion LIKE '%#session.c_search#%'
                )
                ORDER BY #session.c_sort#
                LIMIT #local.c_start#, #getEntries#
            "
        );
    }
    else {
        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                ORDER BY #session.c_sort#
                LIMIT #local.c_start#, #getEntries#
            "
        )
    }

    qLanguages = application.objGlobal.getAllLanguages();
    timeZones = application.getTime.getTimezones();
    getModal = new com.translate();
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
                            <p>You have <b>#qTotalCountries.totalCountries#</b> countries activated. If you want to activate more countries, click to the "Import" or "New country" button.</p>
                            <form action="#application.mainURL#/sysadmin/countries?page=1" method="post">
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
                                    <cfif local.qCountries.recordCount>
                                        <tbody id="dragndrop_body">
                                            <cfloop query="local.qCountries">
                                                <tr>
                                                    <td class="text-center">#local.qCountries.intPrio#</td>
                                                    <td class="text-center">#yesNoFormat(local.qCountries.blnDefault)#</td>
                                                    <td>#local.qCountries.strCountryName# <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##country_#local.qCountries.intCountryID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate country name"></i></a></td>
                                                    <td class="text-center">#local.qCountries.strISO1#</td>
                                                    <td>#local.qCountries.strRegion#</td>
                                                    <td>#local.qCountries.strLanguageEN#</td>
                                                    <td><a href="##" class="btn openPopup" data-bs-toggle="modal" data-href="#application.mainURL#/views/sysadmin/ajax_country.cfm?countryID=#local.qCountries.intCountryID#">Edit</a></td>
                                                    <td><cfif !local.qCountries.blnDefault><a href="#application.mainURL#/sysadm/countries?remove_country=#local.qCountries.intCountryID#" class="btn">Remove</a></cfif></td>
                                                </tr>
                                                #getModal.args('countries', 'strCountryName', local.qCountries.intCountryID, 100).openModal('country', cgi.path_info, 'Translate country name')#
                                            </cfloop>
                                        </tbody>
                                    <cfelse>
                                        <tbody>
                                            <tr><td colspan="100%" class="text-center text-red">If you want to offer your software only in certain countries, you have to add the desired countries here.</td></tr>
                                        </tbody>
                                    </cfif>
                                    <div id="dynModal" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                            <div class="modal-content" id="dyn_modal-content">
                                                <!--- dynamic content from ajax request (ajax_country.cfm) --->
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
                                                                        <option value="#i.utc#">#i.timezone# - #i.city# (#i.utc#)</option>
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
                            <cfif local.pages neq 1 and local.qCountries.recordCount>
                                <div class="card-body">
                                    <ul class="pagination justify-content-center" id="pagination">
                                        
                                        <!--- First Page --->
                                        <li class="page-item <cfif session.c_page eq 1>disabled</cfif>">
                                            <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=1" tabindex="-1" aria-disabled="true">
                                                <i class="fas fa-angle-double-left"></i>
                                            </a>
                                        </li>

                                        <!--- Prev arrow --->
                                        <li class="page-item <cfif session.c_page eq 1>disabled</cfif>">
                                            <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#session.c_page-1#" tabindex="-1" aria-disabled="true">
                                                <i class="fas fa-angle-left"></i>
                                            </a>
                                        </li>
                                        
                                        <!--- Pages --->
                                        <cfif session.c_page + 4 gt local.pages>
                                            <cfset blockPage = local.pages>
                                        <cfelse>
                                            <cfset blockPage = session.c_page + 4>
                                        </cfif>
                                        
                                        <cfif blockPage neq local.pages>
                                            <cfloop index="j" from="#session.c_page#" to="#blockPage#">
                                                <cfif not blockPage gt local.pages>
                                                    <li class="page-item <cfif session.c_page eq j>active</cfif>">
                                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#j#">#j#</a>
                                                    </li>
                                                </cfif>
                                            </cfloop>
                                        <cfelse>
                                            <cfloop index="j" from="#local.pages - 4#" to="#local.pages#">
                                                    <li class="page-item <cfif session.c_page eq j>active</cfif>">
                                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#j#">#j#</a>
                                                    </li>
                                            </cfloop>
                                        </cfif>

                                        
                                        <!--- Next arrow --->
                                        <li class="page-item <cfif session.c_page gte local.pages>disabled</cfif>">
                                            <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#session.c_page+1#">
                                                <i class="fas fa-angle-right"></i>
                                            </a>
                                        </li>

                                        <!--- Last Page --->
                                        <li class="page-item <cfif session.c_page gte local.pages>disabled</cfif>">
                                            <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#local.pages#">
                                                <i class="fas fa-angle-double-right"></i>
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>