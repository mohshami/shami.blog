---
date: 2017-04-11T14:57:12+03:00
title: Cropped Pagination Controls With Hugo
---

I'm currently in the middle of migrating my blog (yet again) from [Hexo](https://hexo.io/) to [Hugo](https://gohugo.io/). Hexo is nice but I'm learning some HTML/CSS and decided to give Hugo a try and I liked the following about it

-   Setting it up is just a matter of downloading a single EXE file and adding it to PATH, as opposed to having to install NodeJS, then Hexo

-   [Shortcodes](https://gohugo.io/extras/shortcodes/) are part of the theme, not a plugin

-   Go themes are close enough to Jinja2 which I have been using for a couple of years now with Salt and Ansible

-   In general, Hugo is easier to maintain in git as the whole folder can be tracked, whereas with Hexo, the node_modules folder needs to be in .gitignore

-   Hugo supports multiple categories per post, whereas Hexo doesn't<!--more-->

Unlike Hexo, the default pagination in Hugo doesn't react well to having lots of pages. \_internal/pagination.html will print all pages even if you have hundreds.

Just use the following code to handle the scenario

```html
{{ $pag := .Paginate (where .Data.Pages "Type" "post") }}
{{ $first := sub $pag.PageNumber 4 }}
{{ $last := add $pag.PageNumber 4 }}
<div class="block">
    <ul class="pagination" style="white-space:nowrap;">
    {{ if $pag.HasPrev }}
    <li><a href="{{ $pag.First.URL }}">&laquo;First</a></li>
    <li><a href="{{ $pag.Prev.URL }}">&laquo;Prev</a></li>
    {{ end }}

    <li {{ if not $pag.HasPrev }}class="active"{{ end }}><a href="{{ $pag.First.URL }}">1</a></li>
    {{ if gt $first 2 }}
    <li>...</li>
    {{ end }}

    {{ range $pag.Pagers }}
    {{ if and (gt .PageNumber 1) (ge .PageNumber $first) (lt .PageNumber $last) (lt .PageNumber $pag.TotalPages) }}
    <li {{ if eq . $pag }}class="active"{{ end }}><a href="{{ .URL }}">{{ .PageNumber }}</a></li>
    {{ end }}
    {{ end }}

    {{ if lt $last $pag.TotalPages }}
    <li>...</li>
    {{ end }}
    <li {{ if not $pag.HasNext }}class="active"{{ end }}><a href="{{ $pag.Last.URL }}">{{ $pag.TotalPages }}</a></li>

    {{ if $pag.HasNext }}
    <li><a href="{{ $pag.Next.URL }}">Next &raquo;</a></li>
    <li><a href="{{ $pag.Last.URL }}">Last &raquo;</a></li>
    {{ end }}
    </ul>
</div>
```