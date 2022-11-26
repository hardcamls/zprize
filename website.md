---
layout: default
title: site_build
---

We are looking to publish this as a github pages site.

The repo includes a whole bunch of ocaml doc documentation that we can reference from the main site.  This is built with

```
dune build @odoc
```

from the top level directory containing all the projects.  Copy `_build/default/_doc/_html` to the odoc folder.  If you
have libraries like `reedsolomon` or `hardcaml_video_codecs` remove the documentation.
