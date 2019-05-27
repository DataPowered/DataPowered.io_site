+++
date = "2019-05-24"
draft = true
title = "Using Generalised Additive Mixed Models (GAMMs) to predict visitors to Edinburgh and Craigmillar Castles"
tag = ["R", "gamm", "time series"]
author = ["Caterina"]
+++


<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2019-05-24-post-generalised-additive-mixed-models-gamms-tourism/CraigmillarCastle.jpg" alt="Craigmillar Castle" style="width:100%">
_Craigmillar Castle. Image source: https://www.visitscotland.com/blog/films/world-outlander-day/_



I'd been curious about **generalised additive (mixed) models** for some time, and the opportunity to learn more about them finally presented itself when a new project came my way. The aim of this project was to understand the pattern of visitors recorded at two historic sites in Edinburgh: Edinburgh and Craigmillar Castles - both of which are managed by [Historic Environment Scotland](https://www.historicenvironment.scot/).

By _understand_ the pattern of visitors, I really mean _predict_ it on the basis of several 'reasonable' predictor variables (which I will detail a bit later). However, it is perhaps worth starting off with a simpler model, that predicts (or in this case, _forecasts_) visitor numbers from... visitor numbers in the past. This is a classic time series scenario, where we will _use the data to predict itself_. 


<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2019-05-24-post-generalised-additive-mixed-models-gamms-tourism/EdinburghCastle.jpg" alt="Edinburgh Castle" style="width:100%">
_Edinburgh Castle. Image source: http://502.doinghistory.com/making-history-more-than-a-ghost-story/_


We will begin our discussion by first having a quick look at the data available. Then we will very briefly pause on some modelling aspects, to then be have a more meaningful discussion of our data forecast (created in `R` using package `mgcv`). After setting the scene, we can then discuss the additional sources of data that were used as predictors in a more complex, subsequent model. This is the overall structure we will follow:


* [Step 1: The data](#Data) 
* [Step 2: Types of models](#Models) 
* [Step 3: Forecast model](#Forecast) 
	
---


 

# <span id="Data">The data</span>

Our _monthly_ time series (courtesy of [Historic Environment Scotland](https://www.historicenvironment.scot/)) presents itself in long format, split by visitors' country of origin as well as the ticket type they purchased to gain entry to the two sites. Thus each row in the dataset is a record for a given month (starting with `March 2012` for Edinburgh and `March 2013` for Craigmillar Castle, until `March 2018`)

<img src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/graphics/2019-05-24-post-generalised-additive-mixed-models-gamms-tourism/Edinburgh_Craigmillar_linegraph_facets.png" alt="Edinburgh Castle" style="width:100%">
_Data visualisation created with `ggplot2` in `R`_



# <span id="Models">Types of models</span>



Hence, collect ‘plausible’ predictor data for this purpose...

* [Organisation for Economic Co-operation and Development (OECD) Consumer Confidence Index (CCI)](https://data.oecd.org/leadind/consumer-confidence-index-cci.htm)
* [Google Trends R package](https://cran.r-project.org/web/packages/gtrendsR/index.html) `gtrendsR`
* [Global Data on Events, Language and Tone (GDELT)](https://www.gdeltproject.org/about.html)
* [Internet Movie Database](https://www.imdb.com/) + [Open Movie Database](http://www.omdbapi.com/)
* [Local weather data](https://www.geos.ed.ac.uk/~weather/jcmb_ws/)
* For-Sight hotel booking data.



# <span id="Forecast">Forecast model</span>


Extras - https://noamross.github.io/gams-in-r-course/


<!--
<object data="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf" type="application/pdf" width="700px" height="700px">
    <iframe src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf" width="100%" height="500px">
        <p>This browser does not support PDFs. Please download the PDF to view it <a href="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf">here</a>.
        </p>
    </iframe>
</object>
-->
