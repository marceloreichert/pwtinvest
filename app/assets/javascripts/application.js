//= require modernizr
//= require jquery
//= require jquery_ujs
//= require moment
//= require fullcalendar
//= require_tree .
//= require jquery.turbolinks

function showEventDetails(event){
    jQuery.ajax({
        data: 'id=' + event.id,
        dataType: 'script',
        type: 'get',
        url: '/home/get_click'
    });
};
