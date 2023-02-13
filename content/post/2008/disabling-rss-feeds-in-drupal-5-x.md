---
title: Disabling RSS Feeds In Drupal 5.x
date: 2008-04-09 07:58:28
---

You might want to create a site that doesn't have RSS. I did this for my employer to create the admission exam system. Having the RSS icons show up just annoyed me, here is how to do it:<!--more-->

In theme.inc, just comment all the code lines in this function:

```php
function theme_feed_icon($url) {
//  if ($image = theme('image', 'misc/feed.png', t('Syndicate content'), t('Syndicate content'))) {
//    return '<a href="'. check_url($url) .'" class="feed-icon">'. $image. '</a>';
//}
}
```

In common.inc do the same with this function except for the first and last lines:

```php
function drupal_add_feed($url = NULL, $title = '') {
  static $stored_feed_links = array();

/*  if (!is_null($url)) {
    $stored_feed_links[$url] = theme('feed_icon', $url);

    drupal_add_link(array('rel' => 'alternate',
                          'type' => 'application/rss+xml',
                          'title' => $title,
                          'href' => $url));
  }*/
  return $stored_feed_links;
}
```