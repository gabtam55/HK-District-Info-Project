# Load packages-----------------------------------------------------------------
library(tidyverse)
library(ggthemes)
library(shiny)
library(shinythemes)
library(shinyWidgets)


# Read data---------------------------------------------------------------------
survey_data <- readxl::read_xlsx(here::here("Cleaned Survey Data.xlsx"))


# Wrangle data------------------------------------------------------------------
survey_data <- survey_data %>%
  ## Assign those who didn't provide income data to the US average salary
  ## (i.e. $62000) group
  mutate(Income = case_when(
    `Household Income` == "Prefer not to answer" ~ "$50,000-$74,999",
    TRUE ~ `Household Income`
  )) %>%
  mutate(Income = case_when(
    Income == "$0-$9,999" ~ 1,
    Income == "$10,000-$24,999" ~ 2,
    Income == "$25,000-$49,999" ~ 3,
    Income == "$50,000-$74,999" ~ 4,
    Income == "$75,000-$99,999" ~ 5,
    Income == "$100,000-$124,999" ~ 6,
    Income == "$125,000-$149,999" ~ 7,
    Income == "$150,000-$174,999" ~ 8,
    Income == "$175,000-$199,999" ~ 9,
    TRUE ~ 10
  )) %>%
  ## Convert education to factor and re-order it
  mutate(Education = factor(Education,
                            levels= c("Some highschool",
                                      "High School or GED", 
                                      "Some Undergraduate",
                                      "Completed Undergraduate",
                                      "Some Masters",
                                      "Completed Masters",
                                      "Some Phd",
                                      "Completed Phd"))) %>%
  ## For some reason 'Some Masters' were not detected and were all converted
  ## into NA from the above step. Therefore, manual renaming was requried.
  mutate(Education = replace_na(Education, "Some Masters"))

# About text for the app-------------------------------------------------------
text_about <- HTML("Results based on a paid research survey that 
explores the linkage between mental illness and unemployment completed by 334 
individuals. Stratified sampling was used to include individuals with different 
characteristics (e.g. income, location). Mental health data were self-reported.
<br/>
<br/>
Corley, M. (2019, April). Unemployment and mental illness survey, 
Version 2. Retrieved August 8, 2020 from https://www.kaggle.com/michaelacorley/u
nemployment-and-mental-illness-survey/version/2.")


# Build UI----------------------------------------------------------------------
ui <- fluidPage(
  
  titlePanel("Mental Illness & Socioeconomic Status"),
  
  actionButton(inputId = "show_about", label = "About"),
  
  fluidRow(
    column(5, offset = 1,
           sliderTextInput(inputId = "income", label = "Household Income",
                           choices = c("$0-$9,999", "$10,000-$24,999",
                                       "$25,000-$49,999", "$50,000-$74,999",
                                       "$75,000-$99,999", "$100,000-$124,999",
                                       "$125,000-$149,999", "$150,000-$174,999",
                                       "$175,000-$199,999", "$200,000+"),
                           selected = c("$0-$9,999", "$200,000+")),
           selectInput(inputId = "education", label = "Education",
                       choices = c("All", levels(survey_data$Education)),
                       selected = c("All"),
                       multiple = TRUE),
           checkboxGroupButtons(inputId = "employment", label = "Employed?",
                                choices = c("Yes" = 0, "No" = 1),
                                selected = c(0, 1),
                                justified = TRUE,
                                checkIcon = list(yes = icon("ok", lib = "glyphicon")),
                                size = "sm"),
           checkboxGroupButtons(inputId = "foodstamp", label = "Food Stamp?",
                                choices = c("Yes" = 1, "No" = 0),
                                selected = c(0, 1),
                                justified = TRUE,
                                checkIcon = list(yes = icon("ok", lib = "glyphicon")),
                                size = "sm"),
           checkboxGroupButtons(inputId = "housing", label = "Section 8 Housing?",
                                choices = c("Yes" = 1, "No" = 0),
                                selected = c(0, 1),
                                justified = TRUE,
                                checkIcon = list(yes = icon("ok", lib = "glyphicon")),
                                size = "sm")
    ),
    
    column(5, offset = 1,
           sliderTextInput(inputId = "income_2", label = "Household Income",
                           choices = c("$0-$9,999", "$10,000-$24,999",
                                       "$25,000-$49,999", "$50,000-$74,999",
                                       "$75,000-$99,999", "$100,000-$124,999",
                                       "$125,000-$149,999", "$150,000-$174,999",
                                       "$175,000-$199,999", "$200,000+"),
                           selected = c("$0-$9,999", "$200,000+")),
           selectInput(inputId = "education_2", label = "Education",
                       choices = c("All", levels(survey_data$Education)),
                       selected = c("All"),
                       multiple = TRUE),
           checkboxGroupButtons(inputId = "employment_2", label = "Employed?",
                                choices = c("Yes" = 0, "No" = 1),
                                selected = c(0, 1),
                                justified = TRUE,
                                checkIcon = list(yes = icon("ok", lib = "glyphicon")),
                                size = "sm"),
           checkboxGroupButtons(inputId = "foodstamp_2", label = "Food Stamp?",
                                choices = c("Yes" = 1, "No" = 0),
                                selected = c(0, 1),
                                justified = TRUE,
                                checkIcon = list(yes = icon("ok", lib = "glyphicon")),
                                size = "sm"),
           checkboxGroupButtons(inputId = "housing_2", label = "Section 8 Housing?",
                                choices = c("Yes" = 1, "No" = 0),
                                selected = c(0, 1),
                                justified = TRUE,
                                checkIcon = list(yes = icon("ok", lib = "glyphicon")),
                                size = "sm")
    )
  ),
  
  fluidRow(
    column(6,
           tabsetPanel(
             tabPanel("Plot", plotly::plotlyOutput(outputId = "plot")),
             tabPanel("Table", DT::DTOutput(outputId = "table"))
           )
    ),
    column(6,
           tabsetPanel(
             tabPanel("Plot", plotly::plotlyOutput(outputId = "plot_2")),
             tabPanel("Table", DT::DTOutput(outputId = "table_2"))
           )
    )
  )
)

# Build Server------------------------------------------------------------------
server <- function(input, output, session) {

  ## About button
  observeEvent(input$show_about, {
    showModal(modalDialog(text_about, title = "About"))
  })
  
  ## Left panel
  ### Fit input income lower limit into a 1-10 scale
  income_lower_limit <- reactive({
    if(input$income[1] == "$0-$9,999") {
      income <- 1
    } else if(input$income[1] == "$10,000-$24,999") {
      income <- 2
    } else if(input$income[1] == "$25,000-$49,999") {
      income <- 3
    } else if(input$income[1] == "$50,000-$74,999") {
      income <- 4
    } else if(input$income[1] == "$75,000-$99,999") {
      income <- 5
    } else if(input$income[1] == "$100,000-$124,999") {
      income <- 6
    } else if(input$income[1] == "$125,000-$149,999") {
      income <- 7
    } else if(input$income[1] == "$150,000-$174,999") {
      income <- 8
    } else if(input$income[1] == "$175,000-$199,999") {
      income <- 9
    } else if(input$income[1] == "$200,000+") {
      income <- 10
    }
    return(income)
  })
  
  ### Fit input income upper limit into a 1-10 scale
  income_upper_limit <- reactive({
    if(input$income[2] == "$0-$9,999") {
      income <- 1
    } else if(input$income[2] == "$10,000-$24,999") {
      income <- 2
    } else if(input$income[2] == "$25,000-$49,999") {
      income <- 3
    } else if(input$income[2] == "$50,000-$74,999") {
      income <- 4
    } else if(input$income[2] == "$75,000-$99,999") {
      income <- 5
    } else if(input$income[2] == "$100,000-$124,999") {
      income <- 6
    } else if(input$income[2] == "$125,000-$149,999") {
      income <- 7
    } else if(input$income[2] == "$150,000-$174,999") {
      income <- 8
    } else if(input$income[2] == "$175,000-$199,999") {
      income <- 9
    } else if(input$income[2] == "$200,000+") {
      income <- 10
    }
    return(income)
  })
  
  ### Filer data based on user's input
  filtered_data <- reactive({
    data <- survey_data %>%
      filter(Income >= income_lower_limit() & Income <= income_upper_limit(),
             `I am unemployed` %in% input$employment,
             `I receive food stamps` %in% input$foodstamp,
             `I am on section 8 housing` %in% input$housing)
    
    if(input$education != "All") {
      data <- data %>%
        filter(Education %in% input$education)
    }
    data

  })
  
  ### Format filtered data
  formatted_data <- reactive({
    filtered_data() %>%
      summarise(`Y_Mental\nIllness` = sum(`I identify as having a mental illness`, na.rm = TRUE),
                `N_Mental\nIllness` = n() - sum(is.na(`I identify as having a mental illness`)) - `Y_Mental\nIllness`,
                Y_Anxiety = sum(Anxiety, na.rm = TRUE),
                N_Anxiety = n() - sum(is.na(Anxiety)) - Y_Anxiety,
                `Y_Compulsive\nBehaviour` = sum(`Compulsive behavior`, na.rm = TRUE),
                `N_Compulsive\nBehaviour` = n() - sum(is.na(`Compulsive behavior`)) - `Y_Compulsive\nBehaviour`,
                Y_Depression = sum(Depression, na.rm = TRUE),
                N_Depression = n() - sum(is.na(Depression)) - Y_Depression,
                `Y_Lack of\nConcentration` = sum(`Lack of concentration`, na.rm = TRUE),
                `N_Lack of\nConcentration` = n() - sum(is.na(`Lack of concentration`)) - `Y_Lack of\nConcentration`,
                `Y_Mood\nSwings` = sum(`Mood swings`, na.rm = TRUE),
                `N_Mood\nSwings` = n() - sum(is.na(`Mood swings`)) - `Y_Mood\nSwings`,
                `Y_Obsessive\nThinking` = sum(`Obsessive thinking`, na.rm = TRUE),
                `N_Obsessive\nThinking` = n() - sum(is.na(`Obsessive thinking`)) - `Y_Obsessive\nThinking`,
                `Y_Panic\nAttacks` = sum(`Panic attacks`, na.rm = TRUE),
                `N_Panic\nAttacks` = n() - sum(is.na(`Panic attacks`)) - `Y_Panic\nAttacks`,
                Y_Tiredness = sum(Tiredness, na.rm = TRUE),
                N_Tiredness = n() - sum(is.na(Tiredness)) - Y_Tiredness) %>%
      pivot_longer(everything(),
                   names_to = c(".value", "mental_issue"),
                   names_sep= "_") %>%
      mutate(prevalence = round((Y / (Y + N)), digit = 2)) %>%
      mutate(mental_issue= factor(mental_issue, levels = mental_issue))
  })
  
  ### Render table
  output$table <- DT::renderDT({
    formatted_data()
  }) 
  
  ### Render plot
  output$plot <- plotly::renderPlotly({
    formatted_data() %>%
      ggplot(aes(mental_issue, prevalence)) +
      geom_col() +
      scale_y_continuous(labels = scales::percent_format(), lim = c(0, 1)) +
      theme_economist() +
      theme(axis.title = element_blank(),
            axis.text.x = element_text(size = 8, vjust = 0.5),
            axis.text.y = element_text(size = 10))
  })
  
  ## Right panel
  income_lower_limit_2 <- reactive({
    if(input$income_2[1] == "$0-$9,999") {
      income <- 1
    } else if(input$income_2[1] == "$10,000-$24,999") {
      income <- 2
    } else if(input$income_2[1] == "$25,000-$49,999") {
      income <- 3
    } else if(input$income_2[1] == "$50,000-$74,999") {
      income <- 4
    } else if(input$income_2[1] == "$75,000-$99,999") {
      income <- 5
    } else if(input$income_2[1] == "$100,000-$124,999") {
      income <- 6
    } else if(input$income_2[1] == "$125,000-$149,999") {
      income <- 7
    } else if(input$income_2[1] == "$150,000-$174,999") {
      income <- 8
    } else if(input$income_2[1] == "$175,000-$199,999") {
      income <- 9
    } else if(input$income_2[1] == "$200,000+") {
      income <- 10
    }
    return(income)
  })
  
  income_upper_limit_2 <- reactive({
    if(input$income_2[2] == "$0-$9,999") {
      income <- 1
    } else if(input$income_2[2] == "$10,000-$24,999") {
      income <- 2
    } else if(input$income_2[2] == "$25,000-$49,999") {
      income <- 3
    } else if(input$income_2[2] == "$50,000-$74,999") {
      income <- 4
    } else if(input$income_2[2] == "$75,000-$99,999") {
      income <- 5
    } else if(input$income_2[2] == "$100,000-$124,999") {
      income <- 6
    } else if(input$income_2[2] == "$125,000-$149,999") {
      income <- 7
    } else if(input$income_2[2] == "$150,000-$174,999") {
      income <- 8
    } else if(input$income_2[2] == "$175,000-$199,999") {
      income <- 9
    } else if(input$income_2[2] == "$200,000+") {
      income <- 10
    }
    return(income)
  })
  
  ### Filer data based on user's input
  filtered_data_2 <- reactive({
    data <- survey_data %>%
      filter(Income >= income_lower_limit_2() & Income <= income_upper_limit_2(),
             `I am unemployed` %in% input$employment_2,
             `I receive food stamps` %in% input$foodstamp_2,
             `I am on section 8 housing` %in% input$housing_2)
    
    if(input$education_2 != "All") {
      data <- data %>%
        filter(Education %in% input$education_2)
    }
    data
    
  })
  
  ### Format filtered data
  formatted_data_2 <- reactive({
    filtered_data_2() %>%
      summarise(`Y_Mental\nIllness` = sum(`I identify as having a mental illness`, na.rm = TRUE),
                `N_Mental\nIllness` = n() - sum(is.na(`I identify as having a mental illness`)) - `Y_Mental\nIllness`,
                Y_Anxiety = sum(Anxiety, na.rm = TRUE),
                N_Anxiety = n() - sum(is.na(Anxiety)) - Y_Anxiety,
                `Y_Compulsive\nBehaviour` = sum(`Compulsive behavior`, na.rm = TRUE),
                `N_Compulsive\nBehaviour` = n() - sum(is.na(`Compulsive behavior`)) - `Y_Compulsive\nBehaviour`,
                Y_Depression = sum(Depression, na.rm = TRUE),
                N_Depression = n() - sum(is.na(Depression)) - Y_Depression,
                `Y_Lack of\nConcentration` = sum(`Lack of concentration`, na.rm = TRUE),
                `N_Lack of\nConcentration` = n() - sum(is.na(`Lack of concentration`)) - `Y_Lack of\nConcentration`,
                `Y_Mood\nSwings` = sum(`Mood swings`, na.rm = TRUE),
                `N_Mood\nSwings` = n() - sum(is.na(`Mood swings`)) - `Y_Mood\nSwings`,
                `Y_Obsessive\nThinking` = sum(`Obsessive thinking`, na.rm = TRUE),
                `N_Obsessive\nThinking` = n() - sum(is.na(`Obsessive thinking`)) - `Y_Obsessive\nThinking`,
                `Y_Panic\nAttacks` = sum(`Panic attacks`, na.rm = TRUE),
                `N_Panic\nAttacks` = n() - sum(is.na(`Panic attacks`)) - `Y_Panic\nAttacks`,
                Y_Tiredness = sum(Tiredness, na.rm = TRUE),
                N_Tiredness = n() - sum(is.na(Tiredness)) - Y_Tiredness) %>%
      pivot_longer(everything(),
                   names_to = c(".value", "mental_issue"),
                   names_sep= "_") %>%
      mutate(prevalence = round((Y / (Y + N)), digit = 2)) %>%
      mutate(mental_issue= factor(mental_issue, levels = mental_issue))
  })
  
  ### Render table
  output$table_2 <- DT::renderDT({
    formatted_data_2()
  }) 
  
  ### Render plot
  output$plot_2 <- plotly::renderPlotly({
    formatted_data_2() %>%
      ggplot(aes(mental_issue, prevalence)) +
      geom_col() +
      scale_y_continuous(labels = scales::percent_format(), lim = c(0, 1)) +
      theme_economist() +
      theme(axis.title = element_blank(),
            axis.text.x = element_text(size = 8, vjust = 0.5),
            axis.text.y = element_text(size = 10))
  })
  
}


# Build App---------------------------------------------------------------------
shinyApp(ui, server)
