// window.addEventListener('load', function () {
//     const mobileScreen = window.matchMedia("(max-width: 990px )");
//     // document.getElementsByClassName("dashboard-nav-dropdown-toggle")[0].click(function () {
//     //     this.closest(".dashboard-nav-dropdown")
//     //         .classList.toggle("show")
//     //         .find(".dashboard-nav-dropdown")
//     //         .classList.remove("show");
//     //     this.parent()
//     //         .siblings()
//     //         .classList.remove("show");
//     // });
//     document.getElementById("hamburger-icon").addEventListener("click", function () {
//         if (mobileScreen.matches) {
//             document.getElementById("header-nav").classList.toggle("mobile-show");
//         } else {
//             document.getElementsByClassName("dashboard")[0].classList.toggle("nav-open");
//         }
//     });
// }, false);



// const mobileScreen = window.matchMedia("(max-width: 990px )");
// $(document).ready(function () {
//     $(".dashboard-nav-dropdown-toggle").click(function () {
//         $(this).closest(".dashboard-nav-dropdown")
//             .toggleClass("show")
//             .find(".dashboard-nav-dropdown")
//             .removeClass("show");
//         $(this).parent()
//             .siblings()
//             .removeClass("show");
//     });
//     $(".menu-toggle").click(function () {
//         if (mobileScreen.matches) {
//             $(".dashboard-nav").toggleClass("mobile-show");
//         } else {
//             $(".dashboard").toggleClass("dashboard-compact");
//         }
//     });
// });


$(document).ready(function () {

    $('#sidebarCollapse').on('click', function () {
        $('#sidebar').toggleClass('active');
    });

});
