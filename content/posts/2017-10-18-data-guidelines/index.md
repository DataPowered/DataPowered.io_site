---
title: "Data guidelines for clean and usable data"
date: 2017-10-18
lastmod: 2022-07-21
draft: false
tags: ["data cleaning"]
categories: ["pre-analysis"]
featuredImage: "images/header_image_credit_enjo_co_uk.jpg"
---


## The 80/20 split

Since project deadlines tend to be more or less fixed, the extent to which a dataset follows a set of commonly expected guidelines will often determine how much time you have left to spend thinking about your analysis. To use the split that everyone conventionally mentions, you would hope to spend a modest 20% of your time cleaning the data for a project, and 80% planning and carrying out your actual analysis. But often, these numbers might be reversed. Hence a messy, non-standardized dataset can take up most of your time, so that when you finally convert it into a usable format, you realize you have to rush and wrap up your project. 

Sound familiar? It's definitely happened to me before. So I've started thinking if there is a way to avoid this pattern of work. Whenever you're not driving your own data collection (which can happen frequently), you have no control over the format your data arrives in. But what you _can_ do is spread the word on what 'clean' data means, in the hope that at some point, good practices will become standard and the 80% of time spent on cleaning data will be a thing of the past. 

Here are some of my ideas for how to improve (or even prevent) messy data. This is not meant to be an exhaustive list, so feel free to pitch in if you think I've missed something! It would be really interesting to get other people's input on this. 


## A list of tidy data recommendations

|  | Guideline 	| Details 	| Examples 	|
|----	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| 1 	| Same code used consistently throughout the database to indicate missing / unknown values. 	| Blank cells should not be used as a substitute, as these can be misleading. 	| Suggestions for missing value codes: “NA” or “999” etc.  	|
| 2 	| An accompanying data codebook should be provided. 	| This is a record of all variables within the database, with an explanation for what each of them means, the range of possible values, and the column type (e.g., integer, numeric, categorical etc.) 	| For a variable named ‘ConsumSatisf’, an explanatory entry would be provided in the codebook to say that this variable represents a measure of consumer satisfaction with product ‘X’, and that possible values range from 0 to 9 (with column type as integer).  	|
| 3 	| In case multiple datasets are shipped to the analyst, clear indications should be given for whether there is a linking key between these, and what this is. 	|  	| If two datasets are sent, one containing GP referral data, and the other containing specialist care medical data, then the two datasets should contain a common key for patient IDs, which would share the same meaning between dataset (i.e., patient ‘1234567’ should refer to the same person across the two datasets). 	|
| 4 	| Removing duplicated rows, i.e., rows that are perfectly identical within the database (from the first, through to the final column). 	| In more sensitive cases, it may not be enough to remove just perfect duplicates, but special care should also be taken when two rows are identical - with only the exception of a few columns.  	| In a database with patient records, a pair of rows is found that share the same patient ID, the same assessment date, the same prescription, and yet one row suggest the patient was discharged, whereas the other suggests the patient was not discharged. Wherever possible, such situations should be avoided before ever shipping the data, as they are misleading. 	|
| 5 	| Removing trailing whitespaces. 	| There should be no spaces padding the actual values within cells. 	| A database cell should only contain values such as “3”, rather than  “3 ” or “  3 ” etc. 	|
| 6 	| There should only be one ‘atomic’ value per cell. 	| That is, a value coding only one specific characteristic. 	| A single ‘Name’ variable should be replaced by two atomic variables: ‘Surname’ and ‘Forename’. Similarly, a variable called ‘HotelPreferences’ (with a value such as ‘Hilton;Marriot;Ibis’) should be divided into as many separate columns as necessary, e.g., ‘HotelPreference1’ (value = ‘Hilton’), ‘HotelPreference2’ (value = ‘Marriot’), and so on. 	|
| 7 	| The same unit of measuremement should be used consistently throughout the same column. If this is not possible, alternatively, the units of measurement can also be mixed, however this can be allowed only if one variable contains the numeric values, and another vartiable specifies the associated unit of measurement. 	|  	| For medication dosages per patient, a variable could be called ‘DailyIbuprofenDosageMg’, and the values in that column should be restricted to only numeric values, e.g., ‘0.5’, ‘1.5’ - which would be known to be in milligrams. Alternatively, if mixing units of measurement, this format is also possible: for a variable called, ‘DailyIbuprofenDosage’, with values ‘0.5’, ‘1.5’ etc, another variable should be created, e.g., ‘DailyIbuprofenUnit’, with values: ‘mg’, ‘mcg’ etc. Of course, the units of measurement would need to be typed in consistentently (e.g., using either ‘mcg’ or ‘micrograms’, but never both interchangeably).   	|
| 8 	| Related variables should follow the same naming scheme. 	|  	| Reusing the hotel preferences example above, variables should be named consistently, e.g., ‘HotelPref1’, ‘HotelPref2’ etc, rather than ‘HotelPreference1’, ‘HotelPref2’, ‘Pref3’ etc. 	|
| 9 	| Variable names should not contain spaces. 	|  	| A variable name such as ‘Date of birth’ should be replaced with ‘DateOfBirth’ or ‘date_of_birth’ etc. 	|
| 10 	| For dates, the same convention should be used consistently and mentioned in the data codebook. 	|  	| If the format ‘dd/mm/yyyy’ is preferred, this should be maintainted everywhere within the date variable, without cases such as ‘mm/dd/yyyy’, or ‘dd-mm-yyyy’ ever occurring. 	|
| 11 	| Use spelling and capitalisation consistently within columns. 	|  	| In a ‘Gender’ variable, values could be coded as either 0 and 1 (with the explanation provided in the database codebook for which is female and which is male), or if the genders are typed in as words, then ‘male’ should not get mixed with ‘Male’ etc.  	|

As I've said above, I'd be really interested in getting feedback on this, based on other people's experiences with messy data. You can let me know your thoughts in the comment section below, or [email](mailto:info@datapowered.io) me. 


> This content was first published on [The Data Team @ The Data Lab blog](https://thedatateam.silvrback.com/data-guidelines).
