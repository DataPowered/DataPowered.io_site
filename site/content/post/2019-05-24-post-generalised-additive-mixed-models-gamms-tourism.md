+++
date = "2019-05-24"
draft = true
title = "Using Generalised Additive Mixed Models (GAMMs) to predict visitors to Edinburgh and Craigmillar Castles"
tag = ["R", "gamm", "time series"]
author = ["Caterina"]
+++


---

<mark style="background-color:#76e2c7;">If you attended my talk on "Generalised Additive Models applied to tourism data" at the Newcastle Upon Tyne Data Science Meetup in May 2019, please find my (more detailed) slides below.</mark>

---


<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2019-05-24-post-generalised-additive-mixed-models-gamms-tourism/CraigmillarCastle.jpg" alt="Craigmillar Castle" style="width:100%">
_Craigmillar Castle. Image source [here](https://www.visitscotland.com/blog/films/world-outlander-day/)._



I'd been curious about **generalised additive (mixed) models** for some time, and the opportunity to learn more about them finally presented itself when a new project came my way. The aim of this project was to understand the pattern of visitors recorded at two historic sites in Edinburgh: Edinburgh and Craigmillar Castles - both of which are managed by [Historic Environment Scotland](https://www.historicenvironment.scot/).

By _understand_ the pattern of visitors, I really mean _predict_ it on the basis of several 'reasonable' predictor variables (which I will detail a bit later). However, it is perhaps worth starting off with a simpler model, that predicts (or in this case, _forecasts_) visitor numbers from... visitor numbers in the past. This is a classic time series scenario, where we will _use the data to predict itself_. 


<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2019-05-24-post-generalised-additive-mixed-models-gamms-tourism/EdinburghCastle.jpg" alt="Edinburgh Castle" style="width:100%">
_Edinburgh Castle. Image source [here](http://502.doinghistory.com/making-history-more-than-a-ghost-story/)._


We will begin our discussion by first having a quick look at the data available. Then we will very briefly pause on some modelling aspects, to then be have a more meaningful discussion of our data forecast (created in `R` using package `mgcv`). After setting the scene, we can then discuss the additional sources of data that were used as predictors in a more complex, subsequent model. This is the overall structure we will follow:


* [1. The data](#Data) 
* [2. Types of models](#Models) 
* [3. Forecast model](#ForecastMod) 
* [4. Explanatory model](#ExplanatoryMod) 
* [5. Going further: Extra materials and Newcastle meetup slides](#GoingFurther) 

---


 

# <span id="Data">The data</span>

Our _monthly_ time series (courtesy of [Historic Environment Scotland](https://www.historicenvironment.scot/)) presents itself in long format, split by visitors' country of origin as well as the ticket type they purchased to gain entry to the two sites. Thus each row in the dataset details how many visitors were recorded:

 * for a given month (starting with March 2012 for Edinburgh and March 2013 for Craigmillar Castle, until March 2018), 
 * from a given country (UK, for internal tourism, but also USA or Italy etc.)
 * purchasing a given ticket type (Walk up, or Explorer Pass etc.)

To build our first, simpler `gamm` model, we will collapse visitor numbers across these categories and only look at variations in the total number of visitors per month (without concerning ourselves with ticket types or countries yet). This collapsed data looks like this if plotted in `R` using `ggplot2`:
 
<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2019-05-24-post-generalised-additive-mixed-models-gamms-tourism/Edinburgh_Craigmillar_linegraph_facets.jpg" alt="Edinburgh Castle" style="width:100%">
_These data exhibit an interesting pattern of **seasonality** over summer (both castles) and around Easter (especially for Craigmillar Castle), as well as a general - but modest - upward **trend**. But will our `gamm` model pick up on these aspects correctly?_

 So what are `gamm` models? To get a better idea, let's have a look at where they fit within a conceptual progression of other models:



# <span id="Models">Types of models</span>

If trying to predict an outcome `y` on the basis of two predictors x<sub>1</sub> and x<sub>2</sub> via multiple linear regression, our model would have this general form:

 * y = b<sub>0</sub> + b<sub>1</sub>x<sub>1</sub> + b<sub>2</sub>x<sub>2</sub> + e

Translated into `R`, a model could look like:
{{< highlight r>}}
lm _ mod <- lm( Visitors ~ TicketType + Site + Country , data = dat )
{{< / highlight >}}

As the name suggests, this type of model works for (assumed) **linear** relationships between variables (which, as we've seen from the plot above, is not the case here!), as well as independent observations - which, again, is highly unlikely in our case (visitor numbers during one month will have some relationship to the following month). Under these circumstances, enter `gam` models (generalised additive models), which have this general form:

 * y = b<sub>0</sub> + f<sub>1</sub>(x<sub>1</sub>) + f<sub>2</sub>(x<sub>2</sub>) + e
 
 Using `R` syntax, this becomes something like:
 
{{< highlight r>}}
library( mgcv )
gam_mod <- gam( Visitors ~ s( Month ) + 
                  s( as.numeric( Date ) ) + 
                  te( Month, as.numeric( Date ) ) + # But see ?te and ?ti 
                  Site, 
                data = dat )
{{< / highlight >}}
 
As you will have noticed, in this case the single beta coefficients have been replaced with entire (smooth) functions or splines. These in turn consist of smaller **basis functions**. Multiple types of basis functions exist (and are suitable for various data problems), and can be chosen through the `mgcv` package in `R`. These smooth functions allow to follow the shape of the data much more closely, and are not constrained by linearity, unlike the previous type of model. However, `gam` models do still assume that that data points are independent - which for time series data, is not realistic. 

For this reason, we now turn to `gamm` (generalised additive **mixed**) models - also supported by package `mgcv` in `R`. These allow the same flexibility of `gam` models (in terms of integrating smooth functions), as well as correlated data points. This can be done by specifying various types of autoregressive correlation structures, via some functionality 'borrowed' from the separate `nlme` package and `lme()` function for fitting linear mixed models (LMMs).


Unlike [(seasonal) ARIMA](https://people.duke.edu/~rnau/411arim.htm) models, with `gams` or `gamms` we needn't concern ourselves with differencing or detrending the time series - we just need to take these elements correctly into account as part of the model itself. One way to do so is to use both the month (values cycling from `1` to `12`), as well as the overall date as predictors, to capture the seasonality and trend aspects of the data, respectively. If we believe that the amount of seasonality may change over time, we can also add an interaction between the month and date. Finally, we can also specify various autoregressive correlation structures into our `gamm`, as follows: 


{{< highlight r>}}
# mgcv::gamm() = nlme::lme() + mgcv::gam()
gamm_mod <- gamm( Visitors ~
                       s( Month, bs = "cc" ) +
                       s( as.numeric( Date ) ) +
                       te( Month, as.numeric ( Date ) ) +
                       Site,
                     data = dat,
                     correlation = corARMA( p = 1, q = 0 ) )
{{< / highlight >}}



# <span id="ForecastMod">Forecast model</span>

We can now essentially apply a similar model to the one above to our data, the key difference being that we can allow the shape of the smooths to vary Site (Edinburgh or Craigmillar), like so: `s ( Month , bs = " cc " , by = Site )`, as well as adding in the `Site` as a main effect. All this will have been done after standardising the data separately within each site, to avoid results being distorted by the huge scale difference in visitor numbers between sites. The output we get from our `gamm` is this:

{{< highlight r>}}
Family: gaussian 
Link function: identity 

Formula:
Visitors ~ s(Month, bs = "cc", by = Site) + s(as.numeric(Date), 
    by = Site) + te(Month, as.numeric(Date), by = Site) + Site

Parametric coefficients:
              Estimate Std. Error t value Pr(>|t|)  
(Intercept)   -0.04312    0.03878  -1.112   0.2687  
SiteEdinburgh  0.08738    0.05119   1.707   0.0908 .
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Approximate significance of smooth terms:
                                             edf Ref.df      F              p-value    
s(Month):SiteCraigmillar                   7.274  8.000 22.707 < 0.0000000000000002 ***
s(Month):SiteEdinburgh                     6.409  8.000 63.818 < 0.0000000000000002 ***
s(as.numeric(Date)):SiteCraigmillar        1.001  1.001 38.212     0.00000000931069 ***
s(as.numeric(Date)):SiteEdinburgh          1.000  1.000 57.220     0.00000000000612 ***
te(Month,as.numeric(Date)):SiteCraigmillar 6.276  6.276  2.935              0.00787 ** 
te(Month,as.numeric(Date)):SiteEdinburgh   3.212  3.212  3.316              0.02018 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

R-sq.(adj) =  0.913   
  Scale est. = 0.081956  n = 132
{{< / highlight >}}


Based on this model, we can generate a forecast (more details on how to get this in R are in my slides below). After converting the prediction back to the original scale, this is how it compares to the raw visitor numbers: 

<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2019-05-24-post-generalised-additive-mixed-models-gamms-tourism/PredVsObsSimplerGAMM.jpg" alt="Edinburgh Castle" style="width:100%">
_While the prediction produced follows the original data quite closely (notice also the very large adjusted R squared!), it's worth noting the confidence intervals are impractically large and following the conversion back to the original scale, also cross 0 (which for visitor numbers makes little sense). Possible solutions would be to use a different `family` in the `gamm`, or at least truncate the lower bound of the intervals._



# <span id="ExplanatoryMod">Explanatory model</span>



Hence, collect ‘plausible’ predictor data for this purpose...

* [Organisation for Economic Co-operation and Development (OECD) Consumer Confidence Index (CCI)](https://data.oecd.org/leadind/consumer-confidence-index-cci.htm)
* [Google Trends R package](https://cran.r-project.org/web/packages/gtrendsR/index.html) `gtrendsR`
* [Global Data on Events, Language and Tone (GDELT)](https://www.gdeltproject.org/about.html)
* [Internet Movie Database](https://www.imdb.com/) + [Open Movie Database](http://www.omdbapi.com/)
* [Local weather data](https://www.geos.ed.ac.uk/~weather/jcmb_ws/)
* For-Sight hotel booking data.

So can these explain anything above and beyond the previous, simpler model?

{{< highlight r>}}
refining_best_gamm <- 
  gamm( Visitors ~ 
          s( Month, bs = "cc", by = Site )  +
          s( as.numeric( Date ), by = TicketType, bs = "gp" ) +
          te( Month, as.numeric( Date ), by = Site ) +
          s( NumberOfAdults ) +
          s( Temperature ) +
          
          Site +
          TicketType +

          s( LaggedCCI ) + 
          s( LaggedNumArticles ) +
          s( LaggedimdbVotes ) + 
          s( Laggedhits, by = Site ),

        data = best_lag_solution,
        
        control = lmeControl( opt = "optim", msMaxIter = 10000 ),
        random = list( GroupingFactor = ~ 1 ),
        # GroupingFactor = Site x TicketType x Country
        REML = TRUE,
        correlation = corARMA( p = 1, q = 0 )
  )
{{< / highlight >}}


{{< highlight r>}}
Family: gaussian 
Link function: identity 

Formula:
Visitors ~ s(Month, bs = "cc", by = Site) + s(as.numeric(Date), 
    by = TicketType, bs = "gp") + te(Month, as.numeric(Date), 
    by = Site) + s(NumberOfAdults) + s(Temperature) + Site + 
    TicketType + s(LaggedCCI) + s(LaggedNumArticles) + s(LaggedimdbVotes) + 
    s(Laggedhits, by = Site)

Parametric coefficients:
                        Estimate Std. Error t value Pr(>|t|)    
(Intercept)              0.06296    0.06656   0.946 0.344439    
SiteEdinburgh            0.22692    0.06350   3.573 0.000372 ***
TicketTypeEducation      0.07420    0.14545   0.510 0.610085    
TicketTypeExplorer Pass -0.22165    0.06590  -3.363 0.000804 ***
TicketTypeMembership    -0.43625    0.06684  -6.527 1.14e-10 ***
TicketTypePre-Paid      -0.93159    0.14608  -6.377 2.91e-10 ***
TicketTypeTrade         -0.09395    0.06916  -1.358 0.174698    
TicketTypeWeb           -0.10447    0.06915  -1.511 0.131229    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Approximate significance of smooth terms:
                                                 edf Ref.df      F  p-value    
s(Month):SiteCraigmillar                    4.954928  8.000  7.941 6.94e-15 ***
s(Month):SiteEdinburgh                      7.281621  8.000 20.031  < 2e-16 ***
s(as.numeric(Date)):TicketTypeWalk Up       1.000001  1.000  2.854  0.09149 .  
s(as.numeric(Date)):TicketTypeEducation     1.000002  1.000  1.658  0.19821    
s(as.numeric(Date)):TicketTypeExplorer Pass 1.000014  1.000  2.690  0.10132    
s(as.numeric(Date)):TicketTypeMembership    7.325579  7.326 27.817  < 2e-16 ***
s(as.numeric(Date)):TicketTypePre-Paid      1.000004  1.000  0.231  0.63072    
s(as.numeric(Date)):TicketTypeTrade         1.000000  1.000  6.328  0.01206 *  
s(as.numeric(Date)):TicketTypeWeb           1.000000  1.000 22.546 2.39e-06 ***
te(Month,as.numeric(Date)):SiteCraigmillar  0.001085 15.000  0.000  0.31354    
te(Month,as.numeric(Date)):SiteEdinburgh    5.443975 15.000  2.090 4.26e-07 ***
s(NumberOfAdults)                           1.000009  1.000 40.617 2.93e-10 ***
s(Temperature)                              5.675452  5.675  3.058  0.00436 ** 
s(LaggedCCI)                                1.000019  1.000  3.921  0.04798 *  
s(LaggedNumArticles)                        1.985548  1.986  5.661  0.00598 ** 
s(LaggedimdbVotes)                          2.702820  2.703  5.187  0.00188 ** 
s(Laggedhits):SiteCraigmillar               1.000011  1.000  8.012  0.00475 ** 
s(Laggedhits):SiteEdinburgh                 3.106882  3.107  3.756  0.01092 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

R-sq.(adj) =  0.694   Scale est. = 0.3072    n = 932
{{< / highlight >}}


# <span id="GoingFurther">Going further</span>

Assumption checks...

Extras
 
* [Noam Ross' GAMs Intro Course](https://noamross.github.io/gams-in-r-course/)
* [Mitchell Lyons' post](http://environmentalcomputing.net/intro-to-gams/)
* [Gavin Simpson's blog](https://www.fromthebottomoftheheap.net/blog/)
* [Noam Ross - Nonlinear Models in R: The Wonderful World of mgcv](https://www.youtube.com/watch?v=q4_t8jXcQgc)
* [Josef Fruehwald - Studying Pronunciation Changes with gamms](http://edinbr.org/edinbr/2017/10/10/october-meeting.html)



<mark style="background-color:#76e2c7;">If you attended my talk on "Generalised Additive Models applied to tourism data", you can get my slides [**here**](https://github.com/DataPowered/DataPowered.io_site/blob/master/site/content/talks/HES_GAMs_Newcastle.pdf)</mark>.


<!--
<object data="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf" type="application/pdf" width="700px" height="700px">
    <iframe src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf" width="100%" height="500px">
        <p>This browser does not support PDFs. Please download the PDF to view it <a href="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf">here</a>.
        </p>
    </iframe>
</object>
-->
