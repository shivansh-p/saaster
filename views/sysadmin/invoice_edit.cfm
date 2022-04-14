<cfscript>

    // Exception handling for url string and invoice id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisInvoiceID = thiscontent.thisID;
    if(not isNumeric(thisInvoiceID) or thisInvoiceID lte 0) {
        location url="#application.mainURL#/sysadmin/invoices" addtoken="false";
    }

    qInvoice = new com.invoices().getInvoiceData(thisInvoiceID);
    qCustomer = application.objCustomer.getCustomerData(qInvoice.customerID);
    qUsers = application.objCustomer.getUsersActive(qInvoice.customerID);

    if (isNumeric(qInvoice.userID)) {
        qUser = application.objCustomer.getUserDataByID(qInvoice.userID);
        invoicePerson = qUser.strFirstName & " " & qUser.strLastName;
        invoicePersonID = qUser.intUserID;
    } else {
        invoicePerson = "";
        invoicePersonID = 0;
    }

    activeCurrencies = application.objGlobal.getActiveCurrencies();

    //dump(qInvoice);

</cfscript>


<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Invoice #qInvoice.number#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/invoices">Invoices</a></li>
                        </ol>
                    </div>
                    <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##position_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add position
                        </a>
                    </div>
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
                        <div class="card-header" style="display: block;">
                            <div class="row mt-2">
                                <div class="col-lg-6">
                                    <h3 class="card-title">Title: #qInvoice.title#</h3>
                                    <p>
                                    <cfif len(trim(qCustomer.strCompanyName))>
                                        Customer: <a href="##?">#qCustomer.strCompanyName#</a><cfif invoicePersonID gt 0> - </cfif>
                                    <cfelseif len(trim(qCustomer.strContactPerson)) and invoicePersonID eq 0>
                                        <p>Customer: <a href="##?">#qCustomer.strContactPerson#</a></p>
                                    </cfif>
                                    <cfif invoicePersonID gt 0>
                                        <a href="##?">#invoicePerson#</a>
                                    </cfif>
                                    </p>
                                </div>
                                <div class="col-lg-6 text-end pe-3">
                                    <cfif qInvoice.paymentstatusID gt 1>
                                        <a href="##" data-bs-toggle="modal" class="openPopup" data-href="#application.mainURL#/views/sysadmin/ajax_payments.cfm?invoiceID=#thisInvoiceID#"><i class="fas fa-coins h1 me-2" data-bs-toggle="tooltip" data-bs-placement="top" title="Payments"></i></a>
                                    <cfelse>
                                        <a href="##" data-bs-toggle="modal" data-bs-target="##settings"><i class="fas fa-cog h1" data-bs-toggle="tooltip" data-bs-placement="top" title="Invoice settings"></i></a>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="col-lg-12">
                                <div class="bg-muted-lt p-3 border">
                                    <div class="row">
                                        <div class="col-lg-3 text-center">
                                            <b>Invoice amount</b><br />
                                            #lsNumberFormat(qInvoice.total, "_,___.__")# #qInvoice.currency#
                                        </div>
                                        <div class="col-lg-3 text-center text-green">
                                            <b>Payments received</b><br />
                                            #lsNumberFormat(qInvoice.amountPaid, "_,___.__")# #qInvoice.currency#
                                        </div>
                                        <div class="col-lg-3 text-center text-red">
                                            <b>Open amount</b><br />
                                            #lsNumberFormat(qInvoice.amountOpen, "_,___.__")# #qInvoice.currency#
                                        </div>
                                        <div class="col-lg-3 d-flex justify-content-center">
                                            <div class="d-flex align-items-center">
                                                <span class="badge bg-#qInvoice.paymentstatusColor#">#getTrans(qInvoice.paymentstatusVar, 'en')#</span>
                                                <cfif qInvoice.paymentstatusID eq 1>
                                                    <a href="#application.mainURL#/sysadm/invoices?invoiceID=#thisInvoiceID#&open" data-bs-toggle="tooltip" data-bs-placement="top" title="Change the status to OPEN in order to make the invoice visible to the customer."><i class="fas fa-arrow-alt-circle-up h1 mt-2 ms-2"></i></a>
                                                <cfelseif qInvoice.paymentstatusID eq 2>
                                                    <a href="#application.mainURL#/sysadm/invoices?invoiceID=#thisInvoiceID#&draft" data-bs-toggle="tooltip" data-bs-placement="top" title="Change the status to DRAFT in order to change the invoice."><i class="fas fa-arrow-alt-circle-down h1 mt-2 ms-2 text-muted"></i></a>
                                                </cfif>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-12 mt-4">
                                <table class="table table-transparent table-responsive">
                                    <thead>
                                        <tr>
                                            <th width="5%" class="pl-0">Pos.</th>
                                            <th width="32%">Description</th>
                                            <th width="20%" class="text-end">Quantity</th>
                                            <th width="15%" class="text-end">Single Price</th>
                                            <th width="10%" class="text-end">Discount</th>
                                            <th width="10%" class="text-end pr-0">Total #qInvoice.currency#</th>
                                            <th width="8%"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop array="#qInvoice.positions#" index="pos">
                                            <tr>
                                                <td valign="top" class="pl-0">#pos.posNumber#</td>
                                                <td valign="top">
                                                    <p class="mb-1"><b>#pos.title#</b></p>
                                                    <div class="text-muted">#pos.description#</div>
                                                </td>
                                                <td valign="top" class="text-end">#lsnumberFormat(pos.quantity, "__.__")# #pos.unit#</td>
                                                <td valign="top" class="text-end">
                                                    <p class="m-0">#lsnumberFormat(pos.singlePrice, "_,___.__")#</p>
                                                    <p class="text-muted small">(#lsnumberFormat(pos.vat, "__.__")#%)</p>
                                                </td>
                                                <td valign="top" class="text-end"><cfif pos.discountPercent gt 0>#pos.discountPercent#%</cfif></td>
                                                <td valign="top" class="text-end">#lsnumberFormat(pos.totalPrice, "_,___.__")#</td>
                                                <td valign="top" class="text-end">
                                                    <a href="##?" data-bs-toggle="modal" data-bs-target="##pos_#pos.invoicePosID#"><i class="far fa-edit pe-2" style="font-size: 18px;" data-bs-toggle="tooltip" data-bs-placement="top" title="Edit position"></i></a>
                                                    <a href="#application.mainURL#/sysadm/invoices?delete_pos=#pos.invoicePosID#&invoiceID=#thisInvoiceID#" data-bs-toggle="tooltip" data-bs-placement="top" title="Delete position"><i class="far fa-times-circle" style="font-size: 18px;"></i></a>
                                                </td>
                                            </tr>
                                        </cfloop>
                                        <tr>
                                            <td></td>
                                            <td colspan="4"><b>Total</b></td>
                                            <td class="text-end pr-0"><b>#lsnumberFormat(qInvoice.subtotal, "_,___.__")#</b></td>
                                        </tr>
                                        <cfif arrayLen(qInvoice.vatArray)>
                                            <tr><td colspan="100%" style="border: 0;" class="py-1"></td></tr>
                                            <cfloop array="#qInvoice.vatArray#" index="vat">
                                                <tr>
                                                    <td class="pb-1 pt-0" style="border: 0;"></td>
                                                    <td colspan="4" class="pb-1 pt-0 small" style="border: 0;">#vat.vatText#</td>
                                                    <td class="pb-1 pt-0 text-end small" style="border: 0;">#lsnumberFormat(vat.amount, "_,___.__")#</td>
                                                </tr>
                                            </cfloop>
                                            <tr><td colspan="100%" style="border: 0;" class="py-1"></td></tr>
                                        </cfif>
                                        <tr>
                                            <td style="border-top: 1px solid;"></td>
                                            <td style="border-top: 1px solid;" colspan="4"><b>#qInvoice.totaltext#</b></td>
                                            <td style="border-top: 1px solid;" class="text-end pr-0"><b>#lsnumberFormat(qInvoice.total, "_,___.__")#</b></td>
                                        </tr>
                                        <tr><td colspan="100%" style="border-top: 3px double; border-bottom: 0;"></td></tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <!--- <div class="card-footer">
                            footer
                        </div> --->
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>

<cfoutput>

<form action="#application.mainURL#/sysadm/invoices" method="post">
<input type="hidden" name="new_position" value="#thisInvoiceID#">
<div id="position_new" class="modal modal-blur fade" tabindex="-1" style="display: none;" aria-hidden="true" data-bs-backdrop='static' data-bs-keyboard='false'>
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">New position</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="mb-3">
                        <label class="form-label">Position title *</label>
                        <input type="text" name="position_title" class="form-control" maxlength="255" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Position description</label>
                        <textarea class="form-control editor" name="position_desc" style="height: 150px;"></textarea>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-4">
                            <label class="form-label">Quantity *</label>
                            <input type="text" name="quantity" class="form-control" maxlength="10" required>
                        </div>
                        <div class="col-lg-4">
                            <label class="form-label">Singleprice *</label>
                            <input type="text" name="price" class="form-control" maxlength="10" required>
                        </div>
                        <div class="col-lg-4">
                            <label class="form-label">VAT (%)</label>
                            <input type="text" name="vat" class="form-control" maxlength="10">
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-4">
                            <label class="form-label">Unit</label>
                            <input type="text" name="unit" class="form-control" maxlength="20">
                        </div>
                        <div class="col-lg-4">
                            <label class="form-label">Discount (%)</label>
                            <input type="text" name="discount" class="form-control" maxlength="10">
                        </div>
                        <div class="col-lg-4"></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                <button type="submit" class="btn btn-primary ms-auto">
                    Save position
                </button>
            </div>
        </div>
    </div>
</div>
</form>

<cfloop array="#qInvoice.positions#" index="pos">
<div id="pos_#pos.invoicePosID#" class="modal modal-blur fade" tabindex="-1" style="display: none;" aria-hidden="true" data-bs-backdrop='static' data-bs-keyboard='false'>
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
        <form action="#application.mainURL#/sysadm/invoices?invoiceID=#thisInvoiceID#" method="post">
        <input type="hidden" name="edit_position" value="#pos.invoicePosID#">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit position</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="mb-3">
                            <label class="form-label">Position title *</label>
                            <input type="text" name="position_title" class="form-control" maxlength="255" value="#htmleditformat(pos.title)#" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Position description</label>
                            <textarea class="form-control editor" name="position_desc" style="height: 150px;">#pos.description#</textarea>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4">
                                <label class="form-label">Quantity *</label>
                                <input type="text" name="quantity" class="form-control" maxlength="6" value="#pos.quantity#" required>
                            </div>
                            <div class="col-lg-4">
                                <label class="form-label">Singleprice *</label>
                                <input type="text" name="price" class="form-control" maxlength="6" value="#pos.singlePrice#" required>
                            </div>
                            <div class="col-lg-4">
                                <label class="form-label">VAT (%)</label>
                                <input type="text" name="vat" class="form-control" maxlength="6" value="#pos.vat#">
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4">
                                <label class="form-label">Unit</label>
                                <input type="text" name="unit" class="form-control" maxlength="20" value="#htmleditformat(pos.unit)#">
                            </div>
                            <div class="col-lg-4">
                                <label class="form-label">Discount (%)</label>
                                <input type="text" name="discount" class="form-control" maxlength="6" value="#pos.discountPercent#">
                            </div>
                            <div class="col-lg-4">
                                <label class="form-label">Position</label>
                                <input type="number" name="pos" class="form-control" value="#pos.posNumber#">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                    <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
                </div>
            </div>
        </form>
    </div>
</div>
</cfloop>


<form action="#application.mainURL#/sysadm/invoices" method="post">
<input type="hidden" name="settings" value="#thisInvoiceID#">
<div id="settings" class="modal modal-blur fade" tabindex="-1" style="display: none;" aria-hidden="true" data-bs-backdrop='static' data-bs-keyboard='false'>
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Invoice settings</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Title *</label>
                    <input type="text" name="title" class="form-control" maxlength="50" value="#htmleditformat(qInvoice.title)#" required>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-6">
                        <label class="form-label">Person</label>
                        <select name="userID" class="form-select">
                            <option value=""></option>
                            <cfloop query="qUsers">
                                <option value="#qUsers.intUserID#" <cfif qUsers.intUserID eq qInvoice.userID>selected</cfif>>#qUsers.strFirstName# #qUsers.strLastName#</option>
                            </cfloop>
                        </select>
                    </div>
                    <div class="col-lg-6">
                        <label class="form-label">Currency</label>
                        <select name="currency" class="form-select">
                            <cfloop array="#activeCurrencies#" index="i">
                                <option value="#i.iso#" <cfif i.iso eq qInvoice.currency>selected</cfif>>#i.currency_en# (#i.iso#)</option>
                            </cfloop>
                        </select>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-6">
                        <label class="form-label">Invoice date *</label>
                        <div class="input-icon">
                            <span class="input-icon-addon"><i class="far fa-calendar-alt"></i></span>
                            <input class="form-control" placeholder="Select a date" name="invoice_date" id="invoice_date" value="#dateFormat(qInvoice.date, 'yyyy-mm-dd')#" required>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <label class="form-label">Due date *</label>
                        <div class="input-icon">
                            <span class="input-icon-addon"><i class="far fa-calendar-alt"></i></span>
                            <input class="form-control" placeholder="Select a date" name="due_date" id="due_date" value="#dateFormat(qInvoice.dueDate, 'yyyy-mm-dd')#" required>
                        </div>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-4">
                        <label class="form-label mb-3">Prices</label>
                        <label class="form-check form-switch">
                            <input class="form-check-input" name="netto" type="checkbox" <cfif qInvoice.isNet eq 1 or qInvoice.isNet eq "">checked</cfif>>
                            <span class="form-check-label">Netto</span>
                        </label>
                    </div>
                    <div class="col-lg-8">
                        <label class="form-label mb-3">Vat type</label>
                        <label class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="type" value="1" <cfif qInvoice.vatType eq 1 or qInvoice.vatType eq "">checked</cfif>>
                            <span class="form-check-label small pt-1">Incl. VAT</span>
                        </label>
                        <label class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="type" value="2" <cfif qInvoice.vatType eq 2>checked</cfif>>
                            <span class="form-check-label small pt-1">Excl. VAT</span>
                        </label>
                        <label class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="type" value="3" <cfif qInvoice.vatType eq 3>checked</cfif>>
                            <span class="form-check-label small pt-1">No VAT</span>
                        </label>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                <button type="submit" class="btn btn-primary ms-auto">
                    Save settings
                </button>
            </div>
        </div>
    </div>
</div>
</form>

<div id="dynModal" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content" id="dyn_modal-content">
            <!--- dynamic content from ajax request (ajax_payments.cfm) --->
        </div>
    </div>
</div>

</cfoutput>


<script>
    document.addEventListener("DOMContentLoaded", function () {
        window.Litepicker && (new Litepicker({
            element: document.getElementById('invoice_date'),
            buttonText: {
                previousMonth: `<i class="fas fa-angle-left" style="cursor: pointer;"></i>`,
                nextMonth: `<i class="fas fa-angle-right" style="cursor: pointer;"></i>`,
            },
        }));
    });
    document.addEventListener("DOMContentLoaded", function () {
        window.Litepicker && (new Litepicker({
            element: document.getElementById('due_date'),
            buttonText: {
                previousMonth: `<i class="fas fa-angle-left" style="cursor: pointer;"></i>`,
                nextMonth: `<i class="fas fa-angle-right" style="cursor: pointer;"></i>`,
            },
        }));
    });
</script>