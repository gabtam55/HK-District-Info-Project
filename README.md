# Practices
A place for my R learnings using open data and participating in the <a href="https://github.com/Hong-Kong-Districts-Info">Hong Kong Districts Info Project</a>.

## 18th November 2020 - Hypothesis Testing Using Chi-squared Test (Using {infer})
>The General Social Survey (GSS) is a sociological survey created and regularly collected since 1972 by the National Opinion Research Center at the University of Chicago. It is funded by the National Science Foundation. The GSS collects information and keeps a historical record of the concerns, experiences, attitudes, and practices of residents of the United States. (<a href="https://en.wikipedia.org/wiki/General_Social_Survey">Wikipedia, 2020</a>)

Using the results from the GSS conducted since 2000, we would like to look at the relationship between socioeconomic class and political party affiliation.

First of all, we explore that data a bar plots. The biggest supporter for the democratic party was the working class, whereas the biggest supporter for the republican party was the middle class. It seems to suggest that there is a relationship between socioeconomical class and political party affiliation.
<img src="https://github.com/gabtam55/Practices/blob/master/181120%20-%20Hypothesis%20Testing%20(Chi-squared%20Test)/Socioeconomic%20class%20by%20political%20party%20affilliation.png?raw=true" alt="Socioeconomic class by political party affilitation" height="350" />

To find out whether this relationship happened by chance, we perform the chi-squared test using the computational approach. See extract of code below. The hypothesis are:
>Null hypothesis: The socioeconomic class of US residents is independent of their political party affiliations.
Alternative hypothesis: The socioeconomic class of US residents is dependent on their political party affiliations.

<img src="https://github.com/gabtam55/Practices/blob/master/181120%20-%20Hypothesis%20Testing%20(Chi-squared%20Test)/code.png?raw=true" alt="Code" height="350" />

Results indicated a p-value of 0.016. The density plot below show the proportion of chi-squares from the null distribution that are bigger than the observed chi-square.
<img src="https://github.com/gabtam55/Practices/blob/master/181120%20-%20Hypothesis%20Testing%20(Chi-squared%20Test)/Null%20distribution%20of%20chi-squared%20distances.png?raw=true" alt="null distribution" height="350" />

Since p-value is smaller than 0.05, we reject the null hypothesis and are in favor of the alternative hypothesis that socioeconomic class of US residents is dependent on their political party affiliations.

## 28th October 2020 - Hypothesis Testing On A Single Proportion (Using {infer})
<img src="https://github.com/gabtam55/Practices/blob/master/281020%20-%20Hypothesis%20Testing%20(Single%20Proportion)/code.png?raw=true" alt="HypoTestOneProp" height="500" />

## 2nd October 2020 - Job Description Generator (shiny interactive form)
The idea of this app is to speed up the job description creation process by providing the user with standard job information pulled from the O*NET to start with. The job information displayed on the right hand side of the app are editable, which allows users to customise them accordingly. An export feature is yet to be built to allow the edited job information to be downloaded.
<br/>
<br/>
<a href="https://hfigabriel.shinyapps.io/job_profile/?_ga=2.71492179.1301702451.1601633849-849884923.1596283104">Link</a> to shiny app
<br/>
<br/>
<img src="https://github.com/gabtam55/Practices/blob/master/021020%20-%20Job%20Description%20Generator/Job%20Description%20Generator.png?raw=true" alt="JDGeneratorpng" width="500" />
<p style="text-align: center"><a href="https://services.onetcenter.org/" title="This shiny app incorporates information from O*NET Web Services. Click to learn more."></a></p>
<p>This shiny app incorporates information from <a href="https://services.onetcenter.org/">O*NET Web Services</a> by the U.S. Department of Labor, Employment and Training Administration (USDOL/ETA). O*NET&reg; is a trademark of USDOL/ETA.</p>


## 30th August 2020 - Hong Kong Traffic Collision Data - Wireframe For Later Use (shinydashboard wireframe)
<img src="https://raw.githubusercontent.com/gabtam55/Practices/master/300820%20-%20Hong%20Kong%20Collision%20Data%20Wireframe/Shinydashboard%20Wireframe%20300820.png" alt="HKColShinydashboardpng" width="500" />


## 21st August 2020 - Mental Issue and Socioeconomic Status (shiny interactive plot & table)
<a href="https://gabtam55.shinyapps.io/unemployment_and_mental_illness_survey_190820/?_ga=2.116531782.1301702451.1601633849-849884923.1596283104">Link</a> to shiny app
<br/>
<br/>
<img src="https://raw.githubusercontent.com/gabtam55/Practices/master/210820%20-%20Mental%20Health%20%26%20Socioeconomic%20Status/Shiny%20App%20210820.png" alt="MHShinypng" width="500" />


## 17th August 2020 - Hong Kong Traffic Collision Incident Map (shiny interactive map)
<img src="https://raw.githubusercontent.com/gabtam55/Practices/master/170820%20-%20Hong%20Kong%20Collision%20Data%20Map/Shiny%20Map%20170820.png" alt="HKColShinypng" width="500" />
