---
title: "Corrupted image_captcha In Drupal"
date: 2016-04-23 22:46:54
categories:
  - Technical
---

I have noticed that the image_captcha Drupal module has been showing empty images on some of the websites I administer. When checking the cause of this I tried to view the image directly and got:<!--more-->
{{< thumbnail thumbnail="captcha.png" full="captcha.png" >}}

What baffled me was the fact there were errors in either Drupal's or the server's error logs.

So I downloaded the file through curl
```bash
# Save the corrupted image to disk
curl 'http://site/en/image_captcha?sid=2481564&ts=1461450252' -o /root/img.jpg
```

After checking the binary content of the file I noticed the following

```bash
# get the binary content of the file
hexdump -x img.jpg | head
```

```none
Valid JPG file (Some spaces removed to improve appearance)
0000000  d8ff  e0ff  1000  464a  4649  0100  0001  0100
0000010  0100  0000  feff  3e00  5243  4145  4f54  3a52
0000020  6720  2d64  706a  6765  7620  2e31  2030  7528
0000030  6973  676e  4920  474a  4a20  4550  2047  3876
0000040  2930  202c  6564  6166  6c75  2074  7571  6c61
0000050  7469  0a79  dbff  4300  0800  0606  0607  0805
0000060  0707  0907  0809  0c0a  0d14  0b0c  0c0b  1219
0000070  0f13  1d14  1f1a  1d1e  1c1a  201c  2e24  2027
0000080  2c22  1c23  281c  2937  302c  3431  3434  271f
0000090  3d39  3238  2e3c  3433  ff32  00db  0143  0909
```

```none
Invalid JPG file  (Some spaces removed to improve appearance)
0000000  ff0a  ffd8  00e0  4a10  4946  0046  0101  0000
0000010  0001  0001  ff00  00fe  433e  4552  5441  524f
0000020  203a  6467  6a2d  6570  2067  3176  302e  2820
0000030  7375  6e69  2067  4a49  2047  504a  4745  7620
0000040  3038  2c29  6420  6665  7561  746c  7120  6175
0000050  696c  7974  ff0a  00db  0043  0608  0706  0506
0000060  0708  0707  0909  0a08  140c  0c0d  0b0b  190c
0000070  1312  140f  1a1d  1e1f  1a1d  1c1c  2420  272e
0000080  2220  232c  1c1c  3728  2c29  3130  3434  1f34
0000090  3927  383d  3c32  332e  3234  dbff  4300  0901
```
If you notice the invalid file has an extra ff0a at the beginning. This means there is an extra blank line before the `&lt;?php` tag in one of the files. After digging around it was index.php for me, could be settings.php or an incorrectly edited module file.

Also, it could be a PHP file saved with UTF-8 or some other encoding.

The reason this doesn't generate any errors if the fact that:

```php
empty-line
<?php
```

Is valid PHP syntax that generates an empty line and then the output of whatever PHP come that comes after.
