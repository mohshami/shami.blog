---
date: 2017-04-23T08:15:09+03:00
title: Ordering Select Options With Javascript
---

I've been building trivial web pages for automating tasks for years, but one of things that bothered me the most was having to manually order the OPTIONSs inside SELECTs. I don't remember where I got the code from but just wanted to share<!--more-->

```html
<script type="text/javascript">
function sortlist(){
	var cl = document.getElementById('SELECT_TO_SORT');
	var clTexts = new Array();

	for(i = 0; i < cl.length; i++){
		clTexts[i] =
		cl.options[i].text.toUpperCase() + "," +
		cl.options[i].text + "," +
		cl.options[i].value + "," +
		cl.options[i].selected;
	}

	clTexts.sort();

	for(i = 0; i < cl.length; i++){
		var parts = clTexts[i].split(',');

		cl.options[i].text = parts[1];
		cl.options[i].value = parts[2];
	}
	cl.options[0].selected=true;
}

sortlist();
</script>
```
