# Load packages----------------------------------------------------------------------------------
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(tidyverse)
library(ONETr)

# Read in data-----------------------------------------------------------------------------------
management_job <- read.csv("Management.csv")

# UI---------------------------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Job Profile"),
  
  ## Set shiny theme
  theme = shinythemes::shinytheme("lumen"),
  
  sidebarLayout(
    
    ## Side panel on the left (i.e. user input)
    sidebarPanel(
      width = 2,
      
      pickerInput(
        inputId = "job_title",
        label = NULL,
        choices = management_job$Occupation,
        options = list(
          title = "Select an occupation"
        )
      ),
      
      textInput(
        inputId = "organisation",
        label = NULL,
        placeholder = "Type in name of your organisation"
      ),
      
      textInput(
        inputId = "location",
        label = NULL,
        placeholder = "Type in location the role is based at"
      )
    ),
    
    ## Main panel on the right (i.e. job profile output)
    mainPanel(
      width = 10,
      
      textAreaInput(
        inputId = "job_title_template",
        label = "Job Title",
        width = "300px",
        height = "30px"
      ),
      
      textAreaInput(
        inputId = "organisation_template",
        label = "Organisation",
        width = "300px",
        height = "30px"
      ),
      
      textAreaInput(
        inputId = "location_template",
        label = "Location",
        width = "300px",
        height = "30px"
      ),
      
      textAreaInput(
        inputId = "overview_template",
        label = "Overview",
        width = "1000px",
        height = "50px"
      ),
      
      textAreaInput(
        inputId = "responsibilities_template",
        label = "Responsibilities",
        width = "1000px",
        height = "250px"
      ),
      
      textAreaInput(
        inputId = "skills_abilities_template",
        label = "Skills and Abilities",
        width = "1000px",
        height = "250px"
      ),
      
      textAreaInput(
        inputId = "characteristics_template",
        label = "Characteristics",
        width = "1000px",
        height = "250px"
      ),
      
      textAreaInput(
        inputId = "qualifications_template",
        label = "Qualifications",
        width = "1000px",
        height = "50px"
      ),
      
      textAreaInput(
        inputId = "experience_template",
        label = "Experience",
        width = "1000px",
        height = "50px"
      )
    )
  )
)


# Server----------------------------------------------------------------------------------------
server <- function(input, output, session){
  
  ## Pull SOC code based on user's selection of occupation
  occupation_soc <- reactive({
    management_job %>%
      filter(Occupation == input$job_title) %>%
      pull(1)
  })
  
  ## Set ONET API credentials
  observe({
    setCreds("123456", "123456")
  })
  
  ## Pull all job information (i.e. XML) of the chosen occupation
  job_info <- reactive({
    socSearch(occupation_soc())
  })
  
  ## Pull related job information of the chosen occupation
  overview_reactive <- reactive({
    occupation(job_info())[1, 3]
  })
  
  responsibilities_reactive <- reactive({
    paste("-", tasks(job_info())[, 2], collapse = "\n")
  })
  
  skills_reactive <- reactive({
    paste(skills(job_info())$name, "-", skills(job_info())$description, collapse = "\n")
  })
  
  abilities_reactive <- reactive({
    paste(abilities(job_info())$name, "-", abilities(job_info())$description, collapse = "\n")
  })
  
  work_styles_reactive <- reactive({
    paste(workStyles(job_info())$name, "-", workStyles(job_info())$description, collapse = "\n")
  })
  
  work_values_reactive <- reactive({
    paste(workValues(job_info())$name, "-", workValues(job_info())$description, collapse = "\n")
  })
  
  qualifications_reactive <- reactive({
    jobZone(job_info())[3, 2]
  })
  
  experience_reactive <- reactive({
    jobZone(job_info())[4, 2]
  })
  
  ## Provide default job information for the textAreaInput boxes in the main panel
  observe({
    updateTextAreaInput(
      session,
      inputId = "job_title_template",
      value = input$job_title
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "organisation_template",
      value = input$organisation
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "location_template",
      value = input$location
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "overview_template",
      value = overview_reactive()
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "responsibilities_template",
      value = responsibilities_reactive()
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "skills_abilities_template",
      value = paste0("Skills\n", skills_reactive(), "\n\nAbilities\n", abilities_reactive())
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "characteristics_template",
      value = paste0("Styles\n", work_styles_reactive(), "\n\nValues\n", work_values_reactive())
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "qualifications_template",
      value = qualifications_reactive()
    )
  })
  
  observe({
    updateTextAreaInput(
      session,
      inputId = "experience_template",
      value = experience_reactive()
    )
  })
  
}


# Run app---------------------------------------------------------------------------------
shinyApp(ui, server)