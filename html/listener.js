document.onkeyup = function (data) {
    if (data.which == 27) { // ESC
        $.post('http://boss/closepanel', JSON.stringify({
		}));
	}
};

$(document).on('change', '#vehicles', function() {
	var valueSelected = this.value;
	$.post('http://boss/refreshvehicle', JSON.stringify({
		vehiclename : valueSelected
	}));
});

$(function () {
	window.addEventListener('message', function (event) {
		switch (event.data.action) {
			case 'show':
				$('#box').show();
				break;
			case 'hide':
				$('#box').hide();
				$('#deal').hide();
				$("select").blur();
				break;
			case 'opencontent':
				$('#leftmenu').html(event.data.leftmenu);
				$('#content').html(event.data.content);
				break;
			case 'refreshvehicles':
				$("#vehicle-image").attr("src",event.data.vehicleimage);
				$('#vehicle-price').html(event.data.vehicleprice);
				break;
			case 'showdeal':
				$('#deal').show();
				$('#deal-content').html(event.data.content);
				break;
			default:
				console.log('ui_boss: unknown action!');
				break;
		}
	}, false);
});

function orderVehicle(){
	var valueSelected = $('#vehicles').val();
	$.post('http://boss/ordervehicle', JSON.stringify({
		vehiclename : valueSelected
	}));
}

function selectMenu(menu, data){
	if(data == null) data = "empty";
	$.post('http://boss/selectmenu', JSON.stringify({
		menu : menu,
		data : data
	}));
}

function selectAction(action, data){
	$.post('http://boss/selectmenu', JSON.stringify({
		menu : action,
		data : data 
	}));
}

function openUpdateForm(form, data){
	$.post('http://boss/updateform', JSON.stringify({
		form : form,
		data : data
	}));
}

function fireEmploye(charid){
	$.post('http://boss/saveupdateform', JSON.stringify({
		form : "fire",
		data : charid
	}));
}

function saveUpdateForm(form, data){
	var value = "";
	if(form == "job_grade" || form == "newemploye"){
		value = $("input[name='grades']:checked").val();
	}else{
		value = $("#tb_textvar").val();
	}

	$.post('http://boss/saveupdateform', JSON.stringify({
		form : form,
		data : data,
		value : value
	}));
}

function signDeal(){
	$.post('http://boss/signdeal', JSON.stringify({
	}));
}