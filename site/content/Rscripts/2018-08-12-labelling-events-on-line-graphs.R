

# Packages ----------------------------------------------------------------

library( data.table )

library( stringr )

library( plyr )
library( tidyr )

library( scales ) # to access breaks/formatting functions

library( ggplot2 )




# Read in data ------------------------------------------------------------

git_commits <- fread( "/home/caterina/Documents/DataPoweredIO/victor-hugo-website/site/content/datasets/2018-08-12-data-event-graph/Events.csv", sep = "~", header = FALSE )
setnames( git_commits, c( "User", "Date", "Event" ) )
# Actually might remove user name as not particularly relevant here:
git_commits[ , User := NULL ]


google_analytics_measures <- fread( "/home/caterina/Documents/DataPoweredIO/victor-hugo-website/site/content/datasets/2018-08-12-data-event-graph/Analytics20171001-20180811.csv" )
setnames( google_analytics_measures, c( "Date", "PageViews", "UniquePageViews", "AverageTimeOnPage" ) )





# Data prep ---------------------------------------------------------------

git_commits[ , Date := substr( Date, 1, 10 ) ]
git_commits[ , Date := as.Date( Date, format = "%Y-%m-%d" ) ]

# Switch to wide format so there is just one date per row.
git_commits_wide <- aggregate( Event ~ Date, 
                               FUN = function( x ){ paste( x, collapse = "___" ) },
                               data = git_commits )
git_commits_wide <- separate( git_commits_wide, Event, into = paste( "Event", 1:9, sep = "_"), sep = "___" )





google_analytics_measures[ , Date := as.Date( Date, format = "%m/%d/%y" ) ]

views_time_events <- join( google_analytics_measures, git_commits_wide, by = "Date" )
setDT( views_time_events )



# Maybe skip Oct/Nov as there are too many commits merely for setting up site. Not super relevant
views_time_events <- views_time_events[ Date > "2017-10-20", ]





# Graphs ------------------------------------------------------------------


# Step 1: fairly simple plot:
base <- ggplot( data = views_time_events,
                aes( x = Date, y = cumsum( UniquePageViews ) ) ) +  
  # geom_vline goes in first to be *underneath* the lines and points.
  geom_vline( xintercept = views_time_events[ ! is.na( Event_1 ), Date ],
              linetype = 2, color = "navy", alpha = 0.35, lwd = 1 ) +
  geom_point( size = 2 ) + 
  geom_line( size = 1 )
print( base )
# But there are improvements to be made:



better_labels <- base +
  ggtitle( "Daily views over time, against labelled Git commits" ) +
  ylab( "Views" ) +
  xlab( "Date" ) +
  scale_x_date( breaks = date_breaks( "months" ), labels = date_format( "%b-%y" ) )
print( better_labels )


# Adding text now:
# set.seed( 1566604 )
annotated_events <- better_labels + 
  geom_label( aes( x = Date, y = 160 + rnorm( nrow( views_time_events ), 0, 25 ), 
                   label = str_wrap( Event_1, width = 18 ) ), 
              size = 3, angle = 90, color = "navy" )
print( annotated_events )



set.seed( 1566604 )
# Why not also add total (non-unique) page views? Insert that UNDER all pre-existing layers:
annotated_events$layers <- c( geom_point( aes( x = Date, y = cumsum( PageViews ) ), 
                                          color = "red", alpha = 0.25,
                                          size = 2 ),
                              geom_line( aes( x = Date, y = cumsum( PageViews ) ),
                                         color = "red", alpha = 0.25,
                                         size = 1 ), 
                              annotated_events$layers )
print( annotated_events )




annotated_events + 
  annotate( "text", 
            y = max( cumsum( views_time_events$UniquePageViews ) ), 
            x = max( views_time_events$Date ) + 5,
            label = str_wrap( "Unique page views", width = 7 ),
            size = 3 ) +
  annotate( "text", 
            y = max( cumsum( views_time_events$PageViews ) ), 
            x = max( views_time_events$Date ) + 5,
            label = str_wrap( "Page views", width = 7 ),
            size = 3,
            color = "red" )




# But what if we want to include all the other events too? i.e., multiple commits pushed on the same date. Would get messy...





#   theme( axis.text.x = element_text( angle = 90, hjust = 1 ) ) +
#   geom_label( aes( y = -2, x = 1, label = "Event ID:" ),
#               angle = 0, fontface = 2, color = "black" ) +
#   geom_label( aes( y = -2, x = which( ! is.na( cecilia_plus_mailchimp_std$Event ) ),
#                    label = LETTERS[ 1 : length( which( ! is.na( cecilia_plus_mailchimp_std$Event ) ) ) ] ),
#               angle = 0, fontface = 2, color = "black" ) +
#   annotation_custom( tableGrob( EVENT_INDEX_BY_DATE_LEGEND,
#                                 rows = NULL,
#                                 theme = ttheme_default( base_size = 9,
#                                                         core = list( fg_params = list( hjust = 0, x = 0 ) ),
#                                                         rowhead = list( fg_params = list( hjust = 0, x = 0 ) ) ) ), 
#                      xmin = 1, xmax = 3, ymin = 2, ymax = 3 ) 





