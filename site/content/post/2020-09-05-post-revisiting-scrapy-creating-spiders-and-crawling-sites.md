+++
date = "2020-09-05"
draft = true
title = "Revisiting Scrapy: Creating spiders and crawling sites"
tag = ["Web scraping", "Python"]
author = ["Caterina"]
+++

In my previous [post](https://datapowered.io/post/2020-04-14-post-getting-stuck-in-with-scrapy/) about Scrapy, we covered the basics of how to use CSS and XPath selectors to extract specific content from sites. We also looked at an introductory example of how to scrape a single page containing a list of the active offers and discounts of an e-shop. No crawling between pages was required for this simple example, and we used the `requests` library to make the introduction extra gentle. 

In this post, I'll share a few details about how to create spiders and crawl between multiple pages, and how to do so only using the `Scrapy` library as intended - without resorting to `requests`. We'll choose one page to start with, and build from there.
 

```bash
cd /path/to/my/desired/proj/location
scrapy startproject MyProjName
# Work on your spiders in that folder, then:
scrapy crawl mySpidersClassName -o /path/to/my/upcoming/scraped/output.csv
```

What you will see will be similar to this (except below you can already see a few scripts I've added in subsequently):

 <img src="https://raw.githubusercontent.com/DataPowered/DataPowered.io_site/master/site/content/graphics/2020-09-05-post-revisiting-scrapy-creating-spiders-and-crawling-sites/0ScrapyProjectOverview.png" alt="Scrapy project structure" style="width:40%">
 

First, we'll be extracting the list of broad job categories from [this page](https://nationalcareers.service.gov.uk/explore-careers) on the National Careers Service site. There you'll see job classes like 'Science and research', 'Construction and trades' or 'Government services' and so on.
 

{{< gallery-slider dir="/graphics/2020-09-05-post-revisiting-scrapy-creating-spiders-and-crawling-sites/2-6SingleJobDetails/"  width="800px" height="600px" arrow-left="fa-angle-left" arrow-right="fa-angle-right" auto-slide="2000" >}}

<br>

{{< highlight python >}}
import scrapy

class jobsSpider(scrapy.Spider):
    name = "jobs"
    start_urls  =[
        "https://nationalcareers.service.gov.uk/explore-careers"
    ]
    def parse(self, response):
        for category in response.css('.homepage-jobcategories > li'):
            yield {
                'category_name' : category.css("::text").get(),
                'link' : category.css("a::attr(href)").get()
            }


# In terminal: scrapy crawl jobs -o jobs.json
{{< / highlight >}}


{{< highlight python >}}
# url = "https://nationalcareers.service.gov.uk/job-categories/beauty-and-wellbeing"
# html = requests.get(url).content
# response = Selector(text = html)

import scrapy

root = "https://nationalcareers.service.gov.uk/explore-careers"

class nestedJobSpider(scrapy.Spider):
    name = "jobDetails"

    def start_requests(self):
        yield scrapy.Request(url=root, callback=self.parse)

    def parse(self, response):
        links = response.css('.homepage-jobcategories > li a::attr(href)').extract()
        for link in links:
            yield response.follow(url = link, callback = self.parse2)

    def parse2(self, response):
        parent_job_category = response.css('.heading-xlarge::text').extract()
        job_list_items = response.css('.job-categories_item')

        for job in job_list_items:
            j_name = job.css('.dfc-code-search-jpTitle::text').extract_first()

            alt_j_name = job.css(".dfc-code-search-jpAltTitle::text").extract_first()
            if not alt_j_name:
                alt_j_name = "None"

            j_descr = job.css('.dfc-code-search-jpOverview::text').extract_first()

            print(j_name)
            yield {
                'ParentCat' : parent_job_category,
                'JobName': j_name,
                'AltJobName': alt_j_name,
                'JobDescr': j_descr
            }

# In terminal:  scrapy crawl jobDetails -o /home/caterina/PycharmProjects/ScrapingOnlineOffers/JobCrawl/JobCrawl/spiders/jobDetails.json
{{< / highlight >}}


{{< highlight python >}}
import scrapy
from collections import defaultdict

root = "https://nationalcareers.service.gov.uk/explore-careers"

class nestedJobSpider(scrapy.Spider):
    name = "jobDetailsWithSalary"

    def start_requests(self):
        yield scrapy.Request(url = root, callback = self.parse)

    def parse(self, response):
        links = response.css('.homepage-jobcategories > li a::attr(href)').extract()
        for link in links:
            yield response.follow(url = link, callback = self.parse2)

    def parse2(self, response):

        parent_job_category = response.css('.heading-xlarge::text').extract_first()

        job_list_items = response.css('.job-categories_item')
        for job in job_list_items:
            j_name = job.css('.dfc-code-search-jpTitle::text').extract_first()

            alt_j_name = job.css(".dfc-code-search-jpAltTitle::text").extract_first()
            if not alt_j_name:
                alt_j_name = "None"

            j_descr = job.css('.dfc-code-search-jpOverview::text').extract_first()

            # Extract the URL from the job box to dig deeper and also get min & max salaries:
            fine_job_details = job.css('.dfc-code-search-jpTitle ::attr(href)').extract_first()
            print(fine_job_details)

            item = defaultdict(list)
            item['ParentJobCat'] = parent_job_category
            item['JobName'] = j_name
            item['AltJobName'] = alt_j_name
            item['JobDescr'] = j_descr

            yield response.follow(url = fine_job_details,
                                  callback = self.parse3,
                                  meta={'item': item}) # Save item here to pick up later in parse3

    def parse3(self, response):

        item = response.meta['item']  # retrieve item generated in previous request

        min_sal = response.css('.dfc-code-jpsstarter::text').extract_first()
        max_sal = response.css('.dfc-code-jpsexperienced::text').extract_first()

        if not min_sal:
            min_sal = "Not specified"
        else:
            min_sal = min_sal.strip()

        if not max_sal:
            max_sal = "Not specified"
        else:
            max_sal = max_sal.strip()

        print(min_sal + " - " + max_sal)

        item['MinSal'] = min_sal
        item['MaxSal'] = max_sal
        print(item)

        yield item

# In terminal:
# cd /home/caterina/PycharmProjects/ScrapingOnlineOffers/JobCrawl/JobCrawl/spiders
# scrapy crawl jobDetailsWithSalary -o /home/caterina/PycharmProjects/ScrapingOnlineOffers/JobCrawl/JobCrawl/spiders/jobDetailsWithSalary.json
# Or can export as .csv too
{{< / highlight >}}