+++
date = "2017-10-19"
draft = true
title = "Analysing historical event data in R: Tracking cooperation patterns over time and space"
tag = ["R"]
author = ["Caterina"]
+++

> This content was first published on [The Data Team @ The Data Lab blog](???).

For this post, I've managed to find some very interesting data offered by the [Cline Center](http://www.clinecenter.illinois.edu/) on [this page](http://www.clinecenter.illinois.edu/data/event/phoenix/ ). To quote the Center's own description of it, this data:

> [...] covers the period 1945-2015 and includes several million events extracted from 14 million news stories. This data was produced using [...] content from the New York Times (1945-2005), the BBC Monitoring's Summary of World Broadcasts (1979-2015) and the CIA’s Foreign Broadcast Information Service (1995-2004). It documents the agents, locations, and issues at stake in a wide variety of conflict, cooperation and communicative events [...].

I chose to explore the BBC dataset ("BBC Summary of World Broadcasts ") in this post, since it spans a fairly large period (1979 - 2015), and is also the largest of the datasets offered. It can be downloaded [here](https://uofi.box.com/s/zp4mppzcpdvgs82rzwpme13xt6z4hq6j), and also comes with some metadata presented [here](https://uofi.box.com/s/1ftwk1rt743ynl31voz37bmv23y6nrva). Finally, you can also check out the variable codebook [here](https://uofi.box.com/s/bmh9i39m6bf0vhnuebtf3ak3j6uxy2le).

This is a window onto how the original data looks, before I implemented any edits of my own:
![Silvrback blog image ](https://silvrback.s3.amazonaws.com/uploads/eb934e00-d379-476d-b909-dcbcdac02f10/FullBBCEventDataView.png)

Before we dive in, it's also important to mention a few things about the structure of this BBC dataset. For instance, some characteristics of this dataset are in conflict with the set of data guidelines I recommended in the previous post [here](https://thedatateam.silvrback.com/data-guidelines)

i.e., there often aren't atomic values within the columns for source and target.

These source and target codes dont mean much in themselves. So I'm going to match them up to the explanations from the codebook...

