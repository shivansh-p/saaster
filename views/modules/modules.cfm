
<cfscript>
    objModules = new com.modules();
    getModules = objModules.getAllModules(lngID=getAnyLanguage(session.lng).lngID);
    dump(getModules);
</cfscript>


<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titModules')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('titModules')#</li>
                        </ol>
                    </div>
                    <!--- <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Button
                        </a>
                    </div> --->
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titModules')#</h3>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <cfloop array="#getModules#" index="module">
                                    <div class="col-lg-3">
                                        <div class="card">
                                            <div class="card-body p-4 text-center">
                                                <span class="avatar avatar-xl mb-3 avatar-rounded" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.picture#)"></span>
                                                <h3 class="m-0 mb-1">#module.name#</h3>
                                                <div class="text-muted">#module.short_description#</div>
                                                <div class="mt-2">
                                                    <cfif module.price_monthly eq 0>
                                                        <div class="small">#getTrans('txtFree')#</div>
                                                    <cfelse>
                                                        <div class="small text-muted">#module.currency# #numberFormat(module.price_monthly, '__.__')# #lcase(getTrans('txtMonthly'))#</div>
                                                    </cfif>
                                                </div>
                                            </div>
                                            <div class="d-flex">
                                                <a href="" class="card-btn">
                                                    <i class="fa-solid fa-lock pe-2"></i> Freischalten
                                                </a>
                                                <a href="##?" class="card-btn" data-bs-toggle="modal" data-bs-target="##modul_#module.moduleID#">
                                                    <i class="fa-solid fa-circle-info pe-2"></i> Info
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="modul_#module.moduleID#" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">

                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">#module.name#</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            #module.description#
                                                        </div>
                                                        <div class="mb-3">
                                                            <cfif module.price_monthly eq 0 >
                                                                <div class="display-6 fw-bold my-3">#getTrans('txtFree')#</div>
                                                            <cfelse>
                                                                <div class="display-6 fw-bold mb-1">#module.currency# #numberFormat(module.price_monthly, '__.__')#</div>
                                                                <div class="small text-muted">#getTrans('txtMonthly')#</div>
                                                                <div class="small text-muted">(#module.currency# #numberFormat(module.price_yearly, '__.__')# #getTrans('txtYearly')#)</div>
                                                            </cfif>
                                                            <div class="row pt-2 small">
                                                                <cfif module.isNet eq 1>
                                                                    <cfswitch expression="#module.vat_type#">
                                                                        <cfcase value="1">
                                                                            <p class="text-muted">#getTrans('txtPlusVat')# #numberFormat(module.vat, '__.__')#%</p>
                                                                        </cfcase>
                                                                        <cfcase value="2">
                                                                            <p class="text-muted">#getTrans('txtTotalExcl')#</p>
                                                                        </cfcase>
                                                                        <cfdefaultcase>
                                                                        </cfdefaultcase>
                                                                    </cfswitch>
                                                                <cfelse>
                                                                    <cfswitch expression="#module.vat_type#">
                                                                        <cfcase value="1">
                                                                            <p class="text-muted">#getTrans('txtVatIncluded')# #numberFormat(module.vat, '__.__')#%</p>
                                                                        </cfcase>
                                                                        <cfcase value="2">
                                                                            <p class="text-muted">#getTrans('txtTotalExcl')#</p>
                                                                        </cfcase>
                                                                        <cfdefaultcase>
                                                                        </cfdefaultcase>
                                                                    </cfswitch>
                                                                </cfif>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">#getTrans('btnClose')#</a>
                                                    </div>
                                                </div>

                                        </div>
                                    </div>
                                </cfloop>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>