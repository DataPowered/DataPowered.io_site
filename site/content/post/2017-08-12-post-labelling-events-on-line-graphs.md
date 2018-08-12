+++
date = "2018-08-12"
draft = true
title = "Labelling events on ggplot2 line graphs"
tag = ["ggplot2"]
author = ["Caterina"]
+++


## Howdy,


### The data

Google Analytics - get daily view of (you can always aggregate up to weekly/monthly level, but not the other way around, so perhaps worth doing one download for daily-level data)

Grabbed following measures for only the home page: 


https://devhints.io/git-log-format


cd /my/repo/

git log --pretty='format:"%an"~"%ai"~"%s"' > /my/path/Events.csv


To get rid of the timezone offset and get just local time:


git log --pretty='format:"%an"~"%ad"~"%s"' --date=local

