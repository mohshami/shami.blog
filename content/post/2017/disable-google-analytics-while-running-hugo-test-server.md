---
date: 2017-04-24T13:42:39+03:00
title: Disable Google Analytics While Running Hugo Test Server
categories:
  - Technical
---

So while I was writing my previous post I realized that Google Analytics was being called from the localhost server. I also had lots of grief with Disqus back when I migrated to Hexo; It filled my account with posts related to localhost. I wonder why Disqus built it this way.

I hard-coded the Disqus URL in my theme (Both Hexo and Hugo) but then realized I can't do the same for Google Analytics. I needed a way to disable it altogether. The [fix](https://discuss.gohugo.io/t/how-to-check-if-the-site-is-on-localhost/1490/5) turned out to be quite simple.<!--more-->

```none
{{ if ne (printf "%v" $.Site.BaseURL) "http://localhost:1313/" }}
{{ template "_internal/google_analytics_async.html" . }}
{{ end }}
```

It works for both Google Analytics and Disqus. It should apply to other cases as well.

Another [approach](https://discuss.gohugo.io/t/how-to-check-if-the-site-is-on-localhost/1490/14) also mentioned on the page is to use two configuration files, one for testing and one for production, and make the testing file the default.

```none
// config-release.toml
BaseURL  = "http://mydomain.com/"
PublishDir = "/var/www/mysite"
[params]
   isRelease = true

// config.toml
BaseURL   = http://localhost:1313/

// layout
{{ if .Site.Params.isRelease }}
  some release code, like Google Analytics
{{ else }}
  some dev code, like logging
{{ end }}
```

And use hugo switches to choose when to write the production files

```none
// to release
hugo --config ./config-release.toml

// to dev
hugo server
```

The first approach is enough for simple sites, but you might need to use the second approach if you need something more complex.

**Update: 1/3/2018**
As I am learning more about the ever evolving Hugo, I found I can just use the below in a partial

```none
{{- if in (string .Site.BaseURL) "localhost" -}}
    some dev code, like logging
{{- else -}}
    some release code, like Google Analytics
{{- end -}}
```