window.addEventListener('load', function () {
    const mobileScreen = window.matchMedia("(max-width: 990px )");
    // document.getElementsByClassName("dashboard-nav-dropdown-toggle")[0].click(function () {
    //     this.closest(".dashboard-nav-dropdown")
    //         .classList.toggle("show")
    //         .find(".dashboard-nav-dropdown")
    //         .classList.remove("show");
    //     this.parent()
    //         .siblings()
    //         .classList.remove("show");
    // });
    document.getElementById("hamburger-icon").addEventListener("click", function () {
        if (mobileScreen.matches) {
            document.getElementById("header-nav").classList.toggle("mobile-show");
        } else {
            document.getElementsByClassName("dashboard")[0].classList.toggle("nav-open");
        }
    });
}, false);
