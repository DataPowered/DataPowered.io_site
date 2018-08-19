

# Packages ----------------------------------------------------------------

# library( devtools )
# install_github( "cttobin/ggthemr" )


library( data.table )
library( stringr )
library( plyr )
library( tidyr )

library( ggplot2 )
library( scales ) # to access breaks/formatting functions
library( gridExtra )
library( ggthemr )

ggthemr( "chalk", type = "outer", layout = "scientific", spacing = 2 )

setwd( "/home/caterina/Documents/DataPoweredIO/victor-hugo-website/site/content" )






# Read in data ------------------------------------------------------------

git_commits <- fread( "./datasets/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits/Events.csv", 
                      sep = "~", header = FALSE )
setnames( git_commits, c( "User", "Date", "Event" ) )
# In this case, almost all commits are from the same user, so shall remove from data:
git_commits[ , User := NULL ]


google_analytics_measures <- fread( "./datasets/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits/Analytics20171001-20180811.csv" )
setnames( google_analytics_measures, c( "Date", "PageViews", "UniquePageViews", "AverageTimeOnPage" ) )





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



# Maybe skip Oct/Nov as there are too many commits merely for setting up site. Not super relevant
views_time_events <- views_time_events[ Date > "2017-10-20", ]





# Graphs ------------------------------------------------------------------


single_event_index <- na.exclude( views_time_events[ , c( "Date", "Event_1" ) ] )
single_event_index <- cbind( Event = LETTERS[ 1:4 ], single_event_index )
names( single_event_index ) <- c( "Event", "Date", "Description" )



png( "./graphics/2018-08-18-post-linking-google-analytics-data-to-website-changes-or-github-commits/ViewsVsTimeWithCommitLabels.png",
     width = 14,
     height = 6, 
     units = "in", res = 200 )

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

dev.off()


