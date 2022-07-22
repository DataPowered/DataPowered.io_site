

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

setwd( "/your/dir/" )


# Read in data ------------------------------------------------------------

# Reading in GitHub log, specifying the ~ separator we used earlier.
git_commits <- fread( "Events.csv", 
                      sep = "~", header = FALSE )
setnames( git_commits, c( "User", "Date", "Event" ) )
# In this case, almost all commits are from the same user, so shall remove from data:
git_commits[ , User := NULL ]

google_analytics_measures <- fread( "Analytics20171001-20180811.csv" )
setnames( google_analytics_measures, c( "Date", "PageViews", "UniquePageViews", "AverageTimeOnPage" ) )


# Data prep ---------------------------------------------------------------

# Converting to Date class:
google_analytics_measures[ , Date := as.Date( Date, format = "%m/%d/%y" ) ]

# Extracting just the date part from full string, and also converting to Date class:
git_commits[ , Date := substr( Date, 1, 10 ) ]
git_commits[ , Date := as.Date( Date, format = "%Y-%m-%d" ) ]

# There is a choice to make here between keeping the git log as is (long format), 
# or switching to wide format (splitting commit titles across multiple columns if they occurred in the same day).
# Will demonstrate the latter approach.

# First choose some 'separator' for events which does not occur anywhere within the text,
# and supply it below as the 'collapse' argument of paste():
git_commits_wide <- aggregate( Event ~ Date, 
                               FUN = function( x ){ paste( x, collapse = "___" ) },
                               data = git_commits )

# Find the maximum number of commits in a day, i.e., the no. of columns to split text across:
maximum_commits_in_a_day <- max( table( git_commits$Date ) )

git_commits_wide <- separate( git_commits_wide, 
                              Event, 
                              into = paste( "Event", 1 : maximum_commits_in_a_day, sep = "_"),
                              sep = "___" )

# Finally, join by date is now possible:
views_time_events <- setDT( join( google_analytics_measures, git_commits_wide, by = "Date" ) )


# Maybe skip Oct/Nov as there are too many commits merely for setting up site. Not super relevant
views_time_events <- views_time_events[ Date > "2017-10-20", ]





# Graphs ------------------------------------------------------------------

# Create an index of events to annotate on the plot:
single_event_index <- na.exclude( views_time_events[ , c( "Date", "Event_1" ) ] )
single_event_index <- cbind( Event = LETTERS[ 1 : nrow( single_event_index ) ], single_event_index )
names( single_event_index ) <- c( "Event", "Date", "Description" )

# # Export to png:
# png( "ViewsVsTimeWithCommitLabels.png",
#      width = 14,
#      height = 6, 
#      units = "in", res = 200 )

# Setting the scene:
ggplot( data = views_time_events,
        aes( x = Date, y = cumsum( UniquePageViews ) ) ) +  
  # Marking location of events, and labelling them with letters:
  geom_vline( xintercept = views_time_events[ ! is.na( Event_1 ), Date ],
              lwd = 0.5, color = "white" ) +
  geom_label( data = single_event_index,
              aes( x = Date, y = -10,
                   label = LETTERS[ 1 : nrow( single_event_index ) ] ),
              #str_wrap( Event_1, width = 18 )
              size = 5, angle = 90,
              color = "black", fontface = 2 ) +
  # Draw line of cumulative page views, and label it:
  geom_line( aes( x = Date, y = cumsum( PageViews ) ),
             color = "#fcc49f", size = 2 ) +
  annotate( "text", 
            y = max( cumsum( views_time_events$PageViews ) ), 
            x = max( views_time_events$Date ) + 12,
            label = str_wrap( "Page views", width = 15 ),
            size = 4.5, fontface = 1, 
            color = "#fcc49f" ) +
  # Draw line of cumulative UNIQUE page views, and label it also:
  geom_line( size = 2, color = "#f46036" ) +
  annotate( "text", 
            y = max( cumsum( views_time_events$UniquePageViews ) ), 
            x = max( views_time_events$Date ) + 12,
            label = str_wrap( "Unique page views", width = 15 ),
            size = 4.5, fontface = 1,
            color = "#f46036" ) +
  # Tweak the theme and surrounding text:
  theme( text = element_text( size = 16 ),
         axis.text.x = element_text( angle = 90 ) ) +
  ggtitle( "Cumulative views over time, given labelled Git commits" ) +
  ylab( "Views" ) +
  xlab( "Date" ) +
  scale_x_date( breaks = date_breaks( "months" ), labels = date_format( "%b-%y" ) ) +
  # Add event index as grob - will serve as legend for the letter codes:
  annotation_custom( tableGrob( data.frame( single_event_index ),
                                rows = NULL,
                                theme = ttheme_default( base_size = 11,
                                                        core = list( fg_params = list( hjust = 0, x = 0 ) ),
                                                        rowhead = list( fg_params = list( hjust = 0, x = 0 ) ) ) ), 
                     xmin = quantile( as.numeric( views_time_events$Date ), probs = 0.22 ), 
                     xmax = NA, 
                     ymax = 247,
                     ymin = NA  ) 

# dev.off()


