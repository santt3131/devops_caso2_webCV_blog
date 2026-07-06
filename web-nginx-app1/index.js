const ishow = 950;
const divTop = document.getElementById("top");

window.addEventListener("scroll", function () {
	if (document.documentElement.scrollTop > ishow) {
		divTop.style.display = "inherit";
	} else {
		divTop.style.display = "none";
	}
});
