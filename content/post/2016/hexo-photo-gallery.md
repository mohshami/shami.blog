---
title: "Hexo Photo Gallery"
date: "2016-09-27 17:14:07"
categories:
  - Technical
---

So while I was migrating my data over from wordpress there were a few posts with photo galleries. The options I had were to write each photo gallery by hand or use the photos array in the front matter. What I did was change the photos array a bit and added the following code as a module<!--more-->

<pre class="line-numbers"><code class="language-none">hexo.extend.tag.register('hexoGallery', function (args) {
	gallery = '&lt;div class="flex three demo"&gt;';
	this.photos.forEach(function(photo, i){
		gallery += '&lt;div&gt;&lt;img src="/imgs/spin.gif" class="lazy" data-src="';
		gallery += photo.split(",")[0];
		gallery += '"';
		gallery += 'data-jslghtbx="';
		gallery += photo.split(",")[1];
		gallery += '" data-jslghtbx-group="gallery"';
		gallery += '\&gt;';
		
		gallery += '&lt;/div&gt;';
	});
	gallery += "&lt;/div&gt;";
    return gallery;
});</code></pre>

The photos array needs to look like this:
<pre class="line-numbers"><code class="language-yaml">photos:
  -
    - /2009/11/fixing-banders-xbox-360/1-150x150.jpg
    - /2009/11/fixing-banders-xbox-360/1.jpg
  -
    - /2009/11/fixing-banders-xbox-360/2-150x150.jpg
    - /2009/11/fixing-banders-xbox-360/2.jpg
  -
    - /2009/11/fixing-banders-xbox-360/3-150x150.jpg
    - /2009/11/fixing-banders-xbox-360/3.jpg
  -
    - /2009/11/fixing-banders-xbox-360/4-150x150.jpg
    - /2009/11/fixing-banders-xbox-360/4.jpg
</code></pre>

The items ending with -150x150.jpg in the code above are the thumbnails and the files without that are the full size images. This will create a 3xN photo gallery.

Note that the code above uses the [Picnic CSS](http://picnicss.com/) framework for aligning the thumbnails and uses lazy loading. You can change to fit the libraries you use