+++
date = "2018-08-18"
draft = true
title = "Linking Google Analytics data to website changes or GitHub commits"
tag = ["R", "Google Analytics", "GitHub"]
author = ["Caterina"]
+++



<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits/ViewsVsTimeWithCommitLabels.png" alt="Views over time with labelled commits PNG" width="100%"/>


I've been searching for a topic to write about and think I may finally have found something to explore. If you've set up your website around a GitHub repo (see options: [Netlify](https://www.netlify.com/) + [Hugo](https://gohugo.io/), and [GitHub Pages](https://pages.github.com/) + [Jekyll](https://jekyllrb.com/)), then you have a relatively straightforward way to tie website changes to views. Take for instance the plot above: it gives a good overview of what was happening with views in parallel with various website changes - you can see for instance that views took off shortly after a bio update. While this of course doesn't mean the bio update _caused_ the increase, following such incidents over time could be informative and show some interesting patterns.   

The beauty of using GitHub to store your site is that as you go, you are creating an effortless log of changes. This can be very useful if you want to get a rough idea of what changes / posts might be bringing you more views. To get started, you'll first need to separately download your history of commits. Then you'll be able to merge that with your Google Analytics data. Here are some details on the whole process:
 


### Getting the data

Assuming you have set up a [Google Analytics](https://marketingplatform.google.com/about/analytics/) account, you can for instance download `.csv` reports of page views and other measures directly from the platform: see the Behaviour Tab &rightarrow; Overview &rightarrow; View full report (botton right). You can also restrict the interval of interest using specific dates. Another route could be via the [R package `googleAnalyticsR`](http://code.markedmondson.me/googleAnalyticsR/)).

To give a quick example, I've exported some data dirctly from Google Analytics as a `.csv` file, i.e., daily views (unique and otherwise) for my home page. Depending on what you are trying to do, it might be worth looking into other pages separately, or total views across all pages / daily sessions. 

You should get something of this nature:

| Day Index | Pageviews | Unique Pageviews | Avg. Time on Page |
|-----------|-----------|------------------|-------------------|
| 10/15/17  | 0         | 0                | 00:00:00          |
| 10/16/17  | 19        | 16               | 00:12:17          |
| 10/17/17  | 6         | 6                | 00:00:13          |
 
 Once that is taken care of, you can start extracting commit information in a tidy format. Open up a Terminal and type: 

	
{{< highlight bash >}}
cd /my/website/repo/
git log --pretty='format:"%an"~"%ai"~"%s"' > /my/path/Events.csv
{{< / highlight >}}

This will structure your commit history into individual rows containing: the user name tied to the commit, its date-time with timezone offset, and the title of the commit - all separated by a tilde (~), or any other separator you might want, and is not already present anywhere else in the output. This output is then directed to a `.csv` file with a title and location of your choice. You can also check out other pieces of information you can chain to the same request [here](https://devhints.io/git-log-format). 


Alternatively, to get rid of the timezone offset and get just local time, try:

{{< highlight bash >}}
git log --pretty='format:"%an"~"%ad"~"%s"' --date=local
{{< / highlight >}}



<br/>





### Merging Google Analytics and GitHub commits

Armed with both Google Analytics data and GitHub logs, we can 


{{< highlight r "linenos=table, linenostart=1" >}}
# Packages ----------------------------------------------------------------

library( data.table )
library( stringr )
library( plyr )
library( tidyr )

library( ggplot2 )
library( scales ) # to access breaks/formatting functions

setwd( "/my/path" )


# Read in data ------------------------------------------------------------


google_analytics_measures <- fread( "Analytics20171001-20180811.csv" )
setnames( google_analytics_measures, c( "Date", "PageViews", "UniquePageViews", "AverageTimeOnPage" ) )


# GitHub log is extracted without a header, so we'll have to fix that:
git_commits <- fread( "Events.csv", sep = "~", header = FALSE )
setnames( git_commits, c( "User", "Date", "Event" ) )
{{< / highlight >}}


You've already seen a snippet of the Google Analytics data above. The GitHub log should look something like this after the manipulations carried out in R:


| User      | Date                      | Event                                                     |
|-----------|---------------------------|-----------------------------------------------------------|
| CaterinaC | 2017-10-17 00:40:45 +0100 | Added pygments syntax highlighting for posts              |
| CaterinaC | 2017-10-16 22:43:32 +0100 | Scaled background image                                   |
| CaterinaC | 2017-10-16 22:32:54 +0100 | Merge remote-tracking branch 'DataPowered.io_site/master' |


In this particular case, most commits will be from the same user, so for the sake of simplicity, I shall remove that column and carry on with further manipulations:


{{< highlight r "linenos=table, linenostart=1" >}}
 
git_commits[ , User := NULL ]

# Data prep ---------------------------------------------------------------

# Converting to Date class:
google_analytics_measures[ , Date := as.Date( Date, format = "%m/%d/%y" ) ]


# Extracting just date part from full string, and again converting to Date class:
git_commits[ , Date := substr( Date, 1, 10 ) ]
git_commits[ , Date := as.Date( Date, format = "%Y-%m-%d" ) ]


# There is a choice to make here between keeping the GitHub log as is (long format), 
# Or switching to wide format if there are multiple commits in the same day.
# Will demonstrate the latter approach.


# First choose a separator for events which does not occur anywhere within the text,
# And supply it below as the 'collapse' argument of paste():
git_commits_wide <- aggregate( Event ~ Date, 
                               FUN = function( x ){ paste( x, collapse = "___" ) },
                               data = git_commits )

# What is the maximum number of commits in a day?
maximum_commits_in_a_day <- max( table( git_commits$Date ) )

# We now know how many columns to split the data into:
git_commits_wide <- separate( git_commits_wide, 
                              Event, 
                              into = paste( "Event", 1 : maximum_commits_in_a_day, sep = "_"),
                              sep = "___" )



# Join by date is now possible:
views_time_events <- join( google_analytics_measures, git_commits_wide, by = "Date" )
setDT( views_time_events )
{{< / highlight >}}


At this point, `views_time_events` looks like so:

<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits/JoinedGitHubCommitsWithGoogleAnalyticsData.png" alt="Data printscreen PNG" width="100%"/>




From here, a good next step could be to plot the data. We can just use the events under `Event_1`, guaranteed to have a value each time a commit was made on a given day (the other columns will only be populated if multiple commits were made on the same date).


{{< highlight r "linenos=table, linenostart=1" >}}

# Graphs ------------------------------------------------------------------


single_event_index <- na.exclude( views_time_events[ , c( "Date", "Event_1" ) ] )
single_event_index <- cbind( Event = LETTERS[ 1:4 ], single_event_index )
names( single_event_index ) <- c( "Event", "Date", "Description" )



ggplot( data = views_time_events,
                aes( x = Date, y = cumsum( UniquePageViews ) ) ) +  
  
  # geom_vline goes in first to be *underneath* the lines and points.
  geom_vline( xintercept = views_time_events[ ! is.na( Event_1 ), Date ],
              lwd = 0.5, color = "white" ) +
  geom_label( data = single_event_index,
              aes( x = Date, y = -10,
                   label = LETTERS[ 1 : nrow( single_event_index ) ] ),
              #str_wrap( Event_1, width = 18 )
              size = 5, angle = 90,
              color = "black", fontface = 2 ) +

  
  geom_line( aes( x = Date, y = cumsum( PageViews ) ),
             color = "#fcc49f", size = 2 ) +
  annotate( "text", 
            y = max( cumsum( views_time_events$PageViews ) ), 
            x = max( views_time_events$Date ) + 12,
            label = str_wrap( "Page views", width = 15 ),
            size = 4.5, fontface = 1, 
            color = "#fcc49f" ) +
  
  
  geom_line( size = 2, color = "#f46036" ) +
  annotate( "text", 
            y = max( cumsum( views_time_events$UniquePageViews ) ), 
            x = max( views_time_events$Date ) + 12,
            label = str_wrap( "Unique page views", width = 15 ),
            size = 4.5, fontface = 1,
            color = "#f46036" ) +
  
  
  theme( text = element_text( size = 16 ),
         axis.text.x = element_text( angle = 90 ) ) +
  ggtitle( "Cumulative views over time, given labelled Git commits" ) +
  ylab( "Views" ) +
  xlab( "Date" ) +
  scale_x_date( breaks = date_breaks( "months" ), labels = date_format( "%b-%y" ) ) +
  annotation_custom( tableGrob( data.frame( single_event_index ),
                                rows = NULL,
                                theme = ttheme_default( base_size = 11,
                                                        core = list( fg_params = list( hjust = 0, x = 0 ) ),
                                                        rowhead = list( fg_params = list( hjust = 0, x = 0 ) ) ) ), 
                     xmin = quantile( as.numeric( views_time_events$Date ), probs = 0.22 ), 
                     xmax = NA, 
                     ymax = 247,
                     ymin = NA  ) 

{{< / highlight >}}




### Going further

Maybe import you Google Caledar events (like going to a conference, or meetings with new clients) - and link _those_ to any changes in views.
See packages [here](https://rdrr.io/github/benjcunningham/googlecalendar/api/) and [here](https://github.com/jdeboer/gcalendar).
