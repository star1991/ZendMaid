Number.prototype.formatMoney = function(c, d, t){
var n = this, 
    c = isNaN(c = Math.abs(c)) ? 2 : c, 
    d = d == undefined ? "." : d, 
    t = t == undefined ? "," : t, 
    s = n < 0 ? "-" : "", 
    i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", 
    j = (j = i.length) > 3 ? j % 3 : 0;
   return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 };


// a string representing the date/time without any timezone information what so ever
function localDateString(date) {
    var s = date.toString();
    return s.slice(0, s.indexOf(" GMT"));
}


Date.prototype.formatDate = function() {
	var d = this;
	
	var curr_date = d.getDate();
	var curr_month = d.getMonth();
	curr_month++;
	var curr_year = d.getFullYear();
	
	return curr_month + "/" + curr_date + "/" + curr_year;
	
}

Date.prototype.formatDateInternational = function () {
	var d = this;
	
	var curr_date = d.getDate();
	var curr_month = d.getMonth();
	curr_month++;
	var curr_year = d.getFullYear();
	
	return curr_date + "/" + curr_month + "/" + curr_year;	
}

Date.prototype.formatTime = function() {
	var a_p = "";
	var d = this;
	
	var curr_hour = d.getHours();
	if (curr_hour < 12)
   	{	
   		a_p = "AM";
   	}
	else
   	{
   		a_p = "PM";
   	}

	if (curr_hour == 0)
   	{
   		curr_hour = 12;
   	}
	if (curr_hour > 12)
   	{
   		curr_hour = curr_hour - 12;
   	}

	var curr_min = d.getMinutes();

	curr_min = curr_min + "";

	if (curr_min.length == 1)
   	{
   		curr_min = "0" + curr_min;
   	}

	return curr_hour + ":" + curr_min + " " + a_p;
		
}

