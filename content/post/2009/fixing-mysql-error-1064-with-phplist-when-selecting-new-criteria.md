---
title: Fixing MySQL Error 1064 With PHPList When Selecting New Criteria
date: 2009-03-14 16:48:26
categories:
  - MySQL
---

I'm currently experimenting with PHPlist to use for our corporate newsletters. During the tests I got the following error.<!--more-->

Database error 1064 while doing query You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '1)' at line 3

Tracking this problem down I found the following code segment in "admin/send_core.php"

```none
if (is_array($_POST["criteria_values"])) {
$values = join(", ",$_POST["criteria_values"]);
} else {
$values = $_POST["criteria_values"];
}
```

$values in this segment will always start with a comma. We just need to add a substr statement to fix that. Just change it to

```none
if (is_array($_POST["criteria_values"])) {
$values = join(", ",$_POST["criteria_values"]);
} else {
$values = $_POST["criteria_values"];
}
if (substr($values, 0, 1) == ",") {
$values = substr($values, 1);
}
```

That's it. This will remove the starting comma (If it exists)