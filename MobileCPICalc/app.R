#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(lubridate)
library(dplyr)
library(ggplot2)
library(ggtext)
library(ggthemes)

calcIncr <- function(price, rate) {
  newPrice = price * (1+(rate + 3.9)/100)
  return(newPrice)
}

# external variables
dateCPI23 = as.Date('2023-03-31')
dateCPI24 = as.Date('2024-03-31')
version = 'v1.0'

# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title = "Mobile CPI Calculator"),
  dashboardSidebar(
    sliderInput('contractLength', "Length of Contract", 0,36,24, step = 6),
    dateInput("startDate", "Contract Start Date:", '2022-12-01'),
    textInput('startPrice', "Initial Monthly Cost (£)", 37.99),
    numericInput('upfront', "Upfront Cost (£)", 99),
    numericInput('rateCPI23', "CPI in 2023 (%)", 10),
    numericInput('rateCPI24', "CPI in 2024 (%)", 3),
    tags$head(tags$style(HTML('
      footer {
        position: absolute;
        bottom: 0px;
        left: 180px;
        text-align: right;
        padding: 0px 0px 5px 10px;
      }
    '))),
    tags$footer(version)
    
  ),
  dashboardBody(
    fluidRow(
      infoBoxOutput("finalCost"),
      infoBoxOutput("extraCost")
    ),
    fluidRow(
      box(plotOutput('costPlot'), width = 12)
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  dataInput <- reactive({
    # get start date
    startDate = as.Date(input$startDate)
    # calc end of contract
    endDate = startDate %m+% months(as.numeric(input$contractLength)) - days(1)
    # generate list of months over contract
    contractMonths = seq(startDate, endDate, "month")
    
    # create data from
    df = data.frame(Month = contractMonths, Price = as.numeric(input$startPrice))
    
    
    df = df %>% 
      # calc 2023 increase
      mutate(
        Price = case_when(
          Month > dateCPI23 ~ calcIncr(Price, input$rateCPI23),
          TRUE ~ as.numeric(Price)
        )
      ) %>%
      # calc 2024 increase
      mutate(
        Price = case_when(
          Month > dateCPI24 ~ calcIncr(Price, input$rateCPI24),
          TRUE ~ as.numeric(Price)
        )
      )
    
    
    df = df %>%
      mutate(Diff = Price - as.numeric(input$startPrice))
    return(df)
  })
  
  # calc total cost of contract incl. CPI increases
  output$finalCost <- renderInfoBox({
    df <- dataInput()
    # calc total cost
    total = sum(df$Price) + input$upfront
    
    infoBox("Total Cost", sprintf("£%.2f", total), 
            icon = icon('chart-bar'))
    
  })
  
  # calc addition cost incurred by CPI + 3.9% annual increase
  output$extraCost <- renderInfoBox({
    df <- dataInput()
    
    extra = sum(df$Price) - (as.numeric(input$startPrice) * input$contractLength)
    
    infoBox("Extra Cost Due CPI + 3.9% Increase", sprintf("£%.2f", extra), 
            icon = icon('money-bill'),
            color = 'orange')
    
  })
  
  output$costPlot <- renderPlot({
    df <- dataInput()
    ggplot(df, aes(x = Month, y = Price, fill = 'A')) +
      geom_col() +
      geom_richtext(aes(label = ifelse(Diff > 0, sprintf("+£%.2f", Diff), NA)), size = 5, angle = 45, nudge_y = 5, fill = 'white') +
      #geom_richtext(aes(label = ifelse(Diff > 0, sprintf("+£%.2f", Diff), NA)), size = 5, angle =90, nudge_y = -5, fill = NA, colour = 'white', label.colour = NA) +
      #geom_text(label = sprintf("+£%.2f", df$Diff), size = 4, nudge_y = -4, colour = 'white') +
      scale_x_date(date_labels = "%b %y", date_breaks = '1 month') +
      scale_y_continuous(breaks = seq(0,max(df$Price), 5), limits = c(0, max(df$Price)+8)) +
      scale_fill_economist() +
      #coord_flip() +
      labs(x = NULL,
           y = 'Monthly Cost (£)') +
      theme_economist() +
      theme(
            axis.text = element_text( size = 18),
            axis.text.x = element_text(angle = 90),
            axis.title = element_text(face = 'bold', size = 18),
            legend.position = 'NA'
            
      )
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
