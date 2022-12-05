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

    let cookieBanner = document.getElementById("cookie-banner");
    let denyCookieMsg = document.getElementById("disagree-cookies-msg");
    let acceptCookieMsg = document.getElementById("accept-cookies");

    function showCookieBanner(){
        acceptCookieMsg.style.display = "block";
        cookieBanner.style.display = "block";
    }

    function hideCookieBanner(){
        localStorage.setItem("cb_isCookieAccepted", "yes");
        cookieBanner.style.display = "none";
    }

    function denyCookieBanner(){
        localStorage.setItem("cb_isCookieAccepted", "no");
        cookieBanner.style.display = "block";
        cookieBanner.classList.add("denied");
        denyCookieMsg.style.display = "block";
        acceptCookieMsg.style.display = "none";
    }

    function initializeCookieBanner(){
        let isCookieAccepted = localStorage.getItem("cb_isCookieAccepted");
        if(isCookieAccepted === null)
        {
            localStorage.setItem("cb_isCookieAccepted", "no");
            showCookieBanner();
        }
        if(isCookieAccepted === "no"){
            showCookieBanner();
        }
    }

    window.onload = initializeCookieBanner();
    window.cb_hideCookieBanner = hideCookieBanner;
    window.cb_denyCookieBanner = denyCookieBanner;
});
