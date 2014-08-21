---
layout: post
title:  "Welcome to Jekyll!"
date:   2014-12-25 11:20:54
categories: jekyll update
---

{% examples "welcome" %}

You'll find this post in your `_posts` directory - edit this post and re-build
(or run with the `-w` switch) to see your changes!  To add new posts, simply add
a file in the `_posts` directory that follows the convention:
YYYY-MM-DD-name-of-post.ext.

Jekyll also offers powerful support for [code snippets][snippet]:

{% show "hello_world.rb" lang=ruby "to"=3 %}

{% show hello_world.rb "linenos" from="4" %}

You can download this files in [tar][tar] or [zip][zip] format.

{% show d36d572.diff from=21 to=41 %}

Check out the [Jekyll docs][jekyll] for more info on how to get the most out of
Jekyll. File all bugs/feature requests at [Jekyll's GitHub repo][jekyll-gh].

[snippet]:   {% file_url hello_world.rb %}
[tar]:       {% tar_archive_url %}
[zip]:       {% zip_archive_url %}
[jekyll-gh]: https://github.com/jekyll/jekyll
[jekyll]:    http://jekyllrb.com
