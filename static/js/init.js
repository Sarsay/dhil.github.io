$(document).ready(function(){
    //$('#search-field').hide();
    //Check to see if the window is top if not then display button
    $(window).scroll(function(){
	if ($(this).scrollTop() > 100) {
	    $('.scroll-top').fadeIn();
	} else {
	    $('.scroll-top').fadeOut();
	}
    });
	
    //Click event to scroll to top
    $('.scroll-top').click(function(){
	$('html, body').animate({scrollTop : 0},800);
	return false;
    });

    $('#identity').click(function() {
	$('html, body').animate({scrollTop : 0},800);
	return false;
    });

    /*   var toggled = false;
	 $('#search-submit').hover(function() {
         if (!toggled) {
         $('#search-field').animate({width:'toggle'}, 500);
           toggled = true;
           $('#search-field').focus();
         } // else submit
	 });
	 $('#search-field').focusout(function() {
    if ($(this).val().length == 0) {
    $(this).animate({width:'toggle'},500);
    toggled = false;
    }
    });*/

    $(window).scroll(function(){
	if ($(this).scrollTop() > 20) {
            $('.navbar-collapse').css('background-color', '#f8f8f8');
	} else {
            $('.navbar-collapse').css('background-color', '#ffffff');
	}
    });
});
