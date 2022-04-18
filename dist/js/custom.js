

function sweetAlert(type, thisURL, textOne, textTwo, buttonOne, buttonTwo) {

	if (type == 'warning') {

		swal({
			title: textOne,
			text: textTwo,
			icon: "warning",
			buttons: [buttonOne, buttonTwo],
			dangerMode: true,
		  })
		  .then((willDelete) => {
			if (willDelete) {
				window.location.href = thisURL;
			}
		});

	} else {

		swal({
			title: textOne,
			text: textTwo,
			icon: "success"
		})

	}

};


$('#dragndrop_body').sortable({
	handle: ".move",
	start: function (event, ui) {
		if (navigator.userAgent.toLowerCase().match(/firefoxy/) && ui.helper !== undefined) {
			alert('ff');
			ui.helper.css('position', 'absolute').css('margin-top', $(window).scrollTop());
			//wire up event that changes the margin whenever the window scrolls.
			$(window).bind('scroll.sortableplaylist', function () {
				ui.helper.css('position', 'absolute').css('margin-top', $(window).scrollTop());
			});
		}
	},
	beforeStop: function (event, ui) {
		if (navigator.userAgent.toLowerCase().match(/firefoxy/) && ui.offset !== undefined) {
			$(window).unbind('scroll.sortableplaylist');
			ui.helper.css('margin-top', 0);
		}
	},
	helper: function (e, ui) {
	ui.children().each(function () {
		$(this).width($(this).width());
	});
	return ui;
	},
	scroll: true,
	stop: function (event, ui) {
		fnSaveSort();
	}
});

$(document).ready(function() {
	$(".hand").mouseup(function(){
		$(".hand").css( "cursor","grab");
	}).mousedown(function(){
		$(".hand").css( "cursor","grabbing");
	});
});

$(document).ready(function() {
	$("#checkAll").change(function () {
		$("input:checkbox").prop('checked', $(this).prop("checked"));
	});
	$('#checkall tr').click(function(event) {
		if (event.target.type !== 'checkbox') {
			$(':checkbox', this).trigger('click');
		}
	});
});

// load modal with dynamic content (general)
$(document).ready(function(){
    $('.openPopup').on('click',function(){
        var dataURL = $(this).attr('data-href');
        $('#dyn_modal-content').load(dataURL,function(){
            $('#dynModal').modal('show');
        });
    });
});

// load modal with dynamic content for payments
$(document).ready(function(){
    $('.openPopupPayments').on('click',function(){
        var dataURL = $(this).attr('data-href');
        $('#dyn_modal-content').load(dataURL,function(){
            $('#dynModalPayments').modal('show');
			window.Litepicker && (new Litepicker({
				element: document.getElementById('payment_date'),
				buttonText: {
					previousMonth: `<i class="fas fa-angle-left" style="cursor: pointer;"></i>`,
					nextMonth: `<i class="fas fa-angle-right" style="cursor: pointer;"></i>`,
				},
			}));
        });
    });
});

// Save payment
function sendPayment() {
	var paymentModal = $('#dyn_modal-content');
	var formData = $("#sendPayment").serialize();
	var formAction = $("#sendPayment").attr("action");
	var formReturn = $("#sendPayment").data("return");
	$.ajax({
		type: "POST",
		url: formAction,
		data: formData,
		success: function (){
			paymentModal.load(formReturn);
		}
	  });
}

// Delete payment
function deletePayment(paymentID) {

	var paymentModal = $('#dyn_modal-content');
	var formData = 'delete=' + paymentID;
	var formAction = $("#sendPayment").attr("action");
	var formReturn = $("#sendPayment").data("return");
	$.ajax({
		type: "POST",
		url: formAction,
		data: formData,
		success: function(){
			paymentModal.load(formReturn);
		}
	});
}


// Load trumbowyg editor
$('.editor').each(function(index, element){
    var $this = $(element);
    $this.trumbowyg({
		btns: [
			['viewHTML'], ['bold', 'italic'], ['link'], ['formatting'], ['justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull'], ['unorderedList', 'orderedList']
		]
    });
});

// for invoices (sysadmin)
function showResult(str) {
	if (str.length==0) {
		document.getElementById("livesearch").innerHTML="";
		return;
	}
	var xmlhttp=new XMLHttpRequest();
	xmlhttp.onreadystatechange=function() {
		if (this.readyState==4 && this.status==200) {
			document.getElementById("livesearch").innerHTML=this.responseText;
		}
	}
	xmlhttp.open("GET","/views/sysadmin/ajax_search_customer.cfm?search="+str,true);
	xmlhttp.send();
}
function intoTf(c, i) {
	var customer_name = document.getElementById("searchfield");
	customer_name.value = c;
	var customer_id = document.getElementById("customer_id");
	customer_id.value = i;
}
function hideResult() {
	document.getElementById("livesearch").innerHTML="";
	return;
}

// Change plan prices
$('input[type=radio][name=payment_changer]').change(function() {
    if (this.value == 'yearly') {
        $(".yearly").show();
		$(".monthly").hide();
    }
    else if (this.value == 'monthly') {
        $(".yearly").hide();
		$(".monthly").show();
    }
});