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

calcIncr <- function(price, rate) {
  newPrice = price * (1+(rate + 3.9)/100)
  return(newPrice)
}

# external variables
rateCPI23 = 10
dateCPI23 = as.Date('2023-03-31')
rateCPI24 = 3
dateCPI24 = as.Date('2024-03-31')
startDate = as.Date('2022-12-01')



# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title = "Mobile CPI Calculator"),
  dashboardSidebar(
    sliderInput('contractLength', "Length of Contract", 0,36,24, step = 6),
    textInput('startPrice', "Initial Monthly Cost (£)", 37.99),
    textInput('upfront', "Upfront Cost (£)", 99)

  ),
  dashboardBody(
    fluidRow(
      infoBoxOutput("finalCost")
    ),
    fluidRow(
      box(plotOutput('costPlot'))
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  dataInput <- reactive({
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
          Month > dateCPI23 ~ calcIncr(Price, rateCPI23),
          TRUE ~ as.numeric(Price)
        )
      ) %>%
      # calc 2024 increase
      mutate(
        Price = case_when(
          Month > dateCPI24 ~ calcIncr(Price, rateCPI24),
          TRUE ~ as.numeric(Price)
        )
      )
    
    
    df = df %>%
      mutate(Diff = Price - as.numeric(input$startPrice))
    return(df)
  })

  output$finalCost <- renderInfoBox({
    df <- dataInput()
    # calc total cost
    total = sum(df$Price) + as.numeric(input$upfront)
    
    infoBox("Total Cost", sprintf("£%.2f", total))
    
  })
  
  output$costPlot <- renderPlot({
    df <- dataInput()
    ggplot(df, aes(x = Month, y = Price)) +
      geom_col() +
        geom_richtext(label = sprintf("+%.2f", df$Diff), size = 2, angle =45) +
        scale_x_date(date_labels = "%b %y", date_breaks = '1 month') +
        theme(axis.text.x = element_text(angle = 90),
        )
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
