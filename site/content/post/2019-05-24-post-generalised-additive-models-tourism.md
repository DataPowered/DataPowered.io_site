+++
date = "2019-05-24"
draft = true
title = "Using Generalised Additive Mixed Models (GAMMs) to predict visitors to Edinburgh and Craigmillar Castles"
tag = ["R", "gamm"]
author = ["Caterina"]
+++

I'd been curious about generalised additive (mixed) models for some time, and the opportunity to learn more about them finally presented itself when a new project came my way. The aim of this project was to understand the pattern of visitors recorded at two historic sites in Edinburgh: Edinburgh and Craigmillar Castles - both of which are managed by [Historic Environment Scotland](https://www.historicenvironment.scot/).

Time series available in daily & monthly format:
Split by: Visitors’ country of origin + Ticket Type purchased for the
visit
Interval start: 2012 (Edinburgh Castle) or 2013 (Craigmillar Castle)
Interval end: March 2018




Hence, collect ‘plausible’ predictor data for this purpose...

* [Organisation for Economic Co-operation and Development (OECD) Consumer Confidence Index (CCI)](https://data.oecd.org/leadind/consumer-confidence-index-cci.htm)
* [Google Trends R package](https://cran.r-project.org/web/packages/gtrendsR/index.html) `gtrendsR`
* [Global Data on Events, Language and Tone (GDELT)](https://www.gdeltproject.org/about.html)
* [Internet Movie Database](https://www.imdb.com/) + [Open Movie Database](http://www.omdbapi.com/)
* [Local weather data](https://www.geos.ed.ac.uk/~weather/jcmb_ws/)
* For-Sight hotel booking data.


<object data="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf" type="application/pdf" width="700px" height="700px">
    <iframe src="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf" width="100%" height="500px">
        <p>This browser does not support PDFs. Please download the PDF to view it <a href="https://github.com/DataPowered/DataPowered.io_site/raw/master/site/content/talks/HES_GAMs_Newcastle.pdf">here</a>.
        </p>
    </iframe>
</object>

