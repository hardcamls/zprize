$(document).ready(function () {
    var sidenav = $("#sidebar");
    var body = $("body");
    var hamburger = $(".navbar-toggler");

    // Toggle sidenav on hamburger icon in mobile view
    hamburger.on('click', function () {
        sidenav.toggleClass('active');
        body.toggleClass("sidenav-active");
    });

    // Hide sidenav when clicking outside of sidenav/header
    body.click(function(e){
        if (sidenav.hasClass('active')
            && !$(e.target).closest(sidenav).length
            && $(e.target).closest(".navbar-toggler").length == 0) {
            body.toggleClass("sidenav-active");
            sidenav.removeClass("active");
        }
    });
});
