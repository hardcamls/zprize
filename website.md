---
layout: default
title: site_build
---

# OCamldocs

We are looking to publish this as a github pages site.

The repo includes a whole bunch of ocaml doc documentation that we can reference from the main site.  This is built with

```
dune build @odoc
```

from the top level directory containing all the projects.  Copy `_build/default/_doc/_html` to the odoc folder.  If you
have libraries like `reedsolomon` or `hardcaml_video_codecs` remove the documentation.

With a bit of luck we wont have to do this often...

# Web app

```
dune build --profile=release
```

Dont forget the release profile!  It reduces the js file size considerably.

# Jekyll

To test the site locally.

```
jekyll serve
```
