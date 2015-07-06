---
title: Blog Rebooted
tags: news
---
<figure class="feature-image">
 <img alt="Hello (again) world" src="http://placehold.it/400x200&amp;text=Hello%20(again)%20world" class="img-responsive center-block" />
</figure>
If you have been a regular visitor then you will find that I have changed the design.
But this is only what the eye sees, in fact, I have changed the entire architecture.
The old website was driven by [WordPress][2] blog engine, however I have switched to the static page generator [Hakyll][1].
<!--more-->

My motivation for changing engine mainly boiled down to three issues I had with [WordPress][2]:

1. I was unhappy about the design (theme).
2. It was relatively slow.
3. It was unsecure, and constantly under attack from what I assume are malicious robots.

I suppose items 2 and 3 could have been solved by some WordPress-plugin. But it was the design that ultimately made me go for another engine.
I found myself "hacking" the theme templates to apply my adjustments, but silly-me accidentally applied an update to the site which reverted all my changes.
So it became that I grew tired of it.

I recently stumbled upon [Hakyll][1] which is developed by [Jasper Van der Jeugt](http://jaspervdj.be).
The generator is written in Haskell and features an *embedded domain specific language* which makes it possible to apply, virtually, any customisation you would ever want.
It ships with the essential building blocks to build a personal blog.
Honestly, I was hooked immediately when I learned about it.

For rendering [Hakyll][1] uses the universal document converter [Pandoc][3]. Document conversion provides flexibility as I can typeset my articles in a variety of typesetting languages and convert between these languages. At the moment I am typesetting in Markdown. [Hakyll][1] and [Pandoc][3] translate my Markdown formatted articles to HTML formatted ones. Furthermore, [Hakyll][1] provides a templating mechanism allows me decouple the articles and website layout. In the near future I might write a blog post about my [Hakyll][1]-setup. Until then you can find [the complete source code for my website on GitHub](https://github.com/dhil/dhil.github.io).
I will briefly address how [Hakyll][1] solves the aforementioned issues I had with [WordPress][2].

## Theming { .page-header }
Hakyll, like WordPress, decouples layout code and typesetting. Creating a theme for WordPress is no straightforward process and editting is limited to changing a few variables predetermined by the theme author. Alternatively, one can edit the theme files direct, however it requires you to delve into the WordPress php api for themes.
In constrast, Hakyll themes are simple HTML files. To help you not repeat yourself it provides a small templating language, i.e. constructs for variables, looping and conditional expressions.
So, you can easily have the design you desire without compromises. I built this responsive layout using [Twitter's bootstrap](https://getbootstrap.com).

## From turtle to cheetah speed { .page-header }
I found that WordPress was really slow. By nature WordPress pages are dynamic, that is, they are generated upon request. I suppose the relatively high latency I experienced was due to WordPress' page rendering flow being rather bloated. I reckon some caching plugins could reduce this latency. Furthermore, I suspect my host may also be to blame as it rather slow itself.

Hakyll generates static pages, so the webserver only needs to serve the HTML files to the client. This approach is lighting fast compared to the dynamic compilation approach.

## Making the site secure { .page-header }
According to my WordPress-installation several thousands attacks on `wp-admin` were carried out each day. I suspect these malicious attempts to login into my website being carried out by robots that are specially tailored to attack WordPress-installations. It is probably a consequent of using a well-known and popular solution. But this problem rises from WordPress providing everything in the same box combined with its stateful nature. In the static world is problem does not exist as there is no state.
The caveat is that I have to compile blog posts before publishing them. However, the compilation and publish process can be mostly automated. My website reside on [GitHub pages](https://pages.github.com/) which I publish to through a SSH-tunnel because I do not have a SSL-certificate for my domain my WordPress-installation was inherently insecure. But with GitHub I get better security for free.


# In the near future { .page-header }
I am looking for a bibliography extension to Hakyll. Ideally, I would like something that is capable of inserting references from a BibTeX file into my blog posts. If I cannot find such a tool I suppose I have to write one myself! Furthermore, the only issue I really have with the static pages approach is the lack of a dynamic search/indexing support. However, I believe you can emulate search-support in the client, [it appears Geoffroy Coupie already has done](https://github.com/Geal/hakyll-search-prototype) this to some extent. I will have to look further into it. Moreover, I will investigate how to add automatical announcement of new blog post via Twitter, Facebook and other social platforms. I suppose Github's commit-hooks can be exploited to provide this functionality.

I will soon add more content!

[1]: http://jaspervdj.be/hakyll/
[2]: https://www.wordpress.com
[3]: http://pandoc.org