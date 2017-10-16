+++
date = "2017-10-14T22:55:23+01:00"
draft = false
title = "LA maps of crime: Using R to map criminal activity in LA since 2010"

tag = ["R", "ggplot2", "maps"]
author = ["Lex"]
+++



I’ve recently come across [data.gov](https://catalog.data.gov/dataset?res_format=CSV) — a huge resource for open data. At the time of writing, there are close to 17,000 freely available datasets stored there, including [this one](https://catalog.data.gov/dataset/crime-data-from-2010-to-present) offered by the LAPD. Interestingly, this dataset includes almost 1.6M records of criminal activity occurring in LA since 2010 — all of them described according to a variety of measures (you can read about them [here](https://data.lacity.org/A-Safe-City/Crime-Data-from-2010-to-Present/y8tr-7khq)). 

Using information like the date and time of a crime, its location (longitude & latitude), and the type of crime committed (among other things), you can come up with some pretty interesting visualizations. For this intro to plotting geographical data, I’ll be using `R` and showing you a gradual approach to building your graphs. Keep reading if you want to find out more!


{{< highlight r "linenos=table, hl_lines=8 15-17, linenostart=1" >}}
# Packages to install, if necessary:
# install.packages( c( "data.table", "tidyr",  "stringr", "lubridate", "ggplot2", "ggmap", "ggrepel", "jsonlite" ) )

library( data.table )
library( tidyr )
library( stringr )
library( lubridate )
library( ggplot2 )	
library( ggmap )
library( ggrepel )
library( jsonlite )

# Read in data:
setwd("/your/path/here")
crime <- fread( "CrimeData.csv", na.strings = c( "", "NA", "-", "X" ) )
head( crime )
{{< / highlight >}}

![](https://silvrback.s3.amazonaws.com/uploads/ea94a5b2-e284-49ac-90ea-76e790f76a3e/Map_OneFacet.png)

