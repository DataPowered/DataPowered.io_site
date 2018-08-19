+++
date = "2018-08-18"
draft = false
title = "Linking Google Analytics data to website changes or GitHub commits"
tag = ["R", "Google Analytics", "GitHub"]
author = ["Caterina"]
+++



<a id="top"></a>

<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits/ViewsVsTimeWithCommitLabels.png" alt="Views over time with labelled commits PNG" width="100%"/>


If you've wondered how page views may vary in response to website changes, you've come to the right place. Setting up your website around a GitHub repo (see options: [Netlify](https://www.netlify.com/) + [Hugo](https://gohugo.io/), and [GitHub Pages](https://pages.github.com/) + [Jekyll](https://jekyllrb.com/)) is a great way to ensure that this is a smooth process. The beauty of relying on GitHub to store your site is that you are creating an effortless log of site changes as you go, without having to devote attention to this as a separate process. 

Take for instance the plot above: it gives a good overview of what was happening with my views in parallel with various website updates. You can see for example that views took off shortly after a bio update. While this of course doesn't mean the bio update _caused_ the increase, following such incidents over time could be informative and show some interesting patterns.   

To get started, you'll need two things: to extract your history of commits (git log), and to download your Google Analytics data. Keep reading if you want more details on the entire process.
 

<br/>



### 1. Getting the data 

Setting up a [Google Analytics](https://marketingplatform.google.com/about/analytics/) account will allow you to download `.csv` reports of page views and other measures directly from the platform: see the Behaviour Tab &rightarrow; Overview &rightarrow; View full report (botton right). You can also restrict the interval of interest using specific dates. Another route could be via the [R package `googleAnalyticsR`](http://code.markedmondson.me/googleAnalyticsR/)).

To give a quick example, I've exported some data directly from Google Analytics as a `.csv` file, i.e., daily views (unique and otherwise) for my home page. Depending on what you are trying to do, it might be worth looking into other pages separately, or the total views across all pages / daily sessions. 

You should get something of this nature:

| Day Index | Pageviews | Unique Pageviews | Avg. Time on Page |
|-----------|-----------|------------------|-------------------|
| 10/15/17  | 0         | 0                | 00:00:00          |
| 10/16/17  | 19        | 16               | 00:12:17          |
| 10/17/17  | 6         | 6                | 00:00:13          |
 
 
 Once that is taken care of, you can also extract your git log in a format of your choice. Bring up a Terminal and type: 

	
{{< highlight bash >}}
cd /my/website/repo/
git log --pretty='format:"%an"~"%ai"~"%s"' > /my/path/Events.csv
{{< / highlight >}}

What I've chosen to do above is structure my commit history into individual rows containing: the user name associated with the commit (`%an`), its date-time with timezone offset (`%ai`), and the title of the commit (`%s`) - all delimited by a tilde sign (`~`). You can pick any other separator you wish, as long as it is not already present anywhere else in the output. Then the output is directed to a `.csv` file, with a title, and at a location of your choice. 

Alternatively, you can get rid of the timezone offset and request just local time, by following the code example below. For other types of information you can chain to the same query, check out [Devhints](https://devhints.io/git-log-format). 

{{< highlight bash >}}
git log --pretty='format:"%an"~"%ad"~"%s"' --date=local
{{< / highlight >}}



<br/>





### 2. Reading in the data

Now that we're armed with both Google Analytics data and GitHub logs, we can set the scene for the work lying ahead in R (i.e., creating the plot at the <a href="#top">top of this post</a>).



<script src="https://gist-it.appspot.com/https://github.com/DataPowered/DataPowered.io_site/blob/master/site/content/Rscripts/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits.R?slice=2:32&footer=0"></script>


You've already seen a snippet of the Google Analytics data above. The GitHub log should look something like this after the manipulations carried out in R (minus the `User` column which was deleted above):


| User      | Date                      | Event                                                     |
|-----------|---------------------------|-----------------------------------------------------------|
| CaterinaC | 2017-10-17 00:40:45 +0100 | Added pygments syntax highlighting for posts              |
| CaterinaC | 2017-10-16 22:43:32 +0100 | Scaled background image                                   |
| CaterinaC | 2017-10-16 22:32:54 +0100 | Merge remote-tracking branch 'DataPowered.io_site/master' |


<br/>


### 3. Merging Google Analytics and GitHub commits

Now let's proceed to some further operations, followed by merging the git log with the daily Google Analytics data:

<script src="https://gist-it.appspot.com/https://github.com/DataPowered/DataPowered.io_site/blob/master/site/content/Rscripts/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits.R?slice=34:64&footer=0"></script>


At this point, the joined / merged object `views_time_events` looks like so:

<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits/JoinedGitHubCommitsWithGoogleAnalyticsData.png" alt="Data printscreen PNG" width="100%"/>


<br/>



### 4. Plotting the data

From here, a good next step would be to plot the data. We can just use the events under `Event_1`, guaranteed to have a value each time a commit was made on a given day (the other columns will only be populated if multiple commits were made on the same date). Further Event-type columns could also be incorporated into the graph by adding to the tabularised 'legend', and to the `LETTERS` below:

<script src="https://gist-it.appspot.com/https://github.com/DataPowered/DataPowered.io_site/blob/master/site/content/Rscripts/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits.R?slice=72:134&footer=0"></script>


You'll find the resulting plot at the <a href="#top">top of this post</a>.


<br/>


### 5. Going further

A good way to take this further would be to have a think about what sorts of events could meaningfully be tied to changes in views (given a certain lag). This may be more than website updates, and might also include things like networking (e.g., if people come across your site when searching for you online after having met you). Importing your Google Calendar could come in handy here, so you might want to check out R packages like [googlecalendar](https://rdrr.io/github/benjcunningham/googlecalendar/api/) and [gcalendar](https://github.com/jdeboer/gcalendar).

You can get my full R code [here](https://github.com/DataPowered/DataPowered.io_site/blob/master/site/content/Rscripts/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits.R) and explore things further.

<br/>