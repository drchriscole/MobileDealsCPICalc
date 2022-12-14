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
contractLength = 24
startPrice = 37.99
upfrontCost = 99
rateCPI23 = 10
dateCPI23 = as.Date('2023-03-31')
rateCPI24 = 3
dateCPI24 = as.Date('2024-03-31')
startDate = as.Date('2022-12-01')

# calc end of contract
endDate = startDate %m+% months(contractLength) - days(1)
# generate list of months over contract
contractMonths = seq(startDate, endDate, "month")

# create data from
df = data.frame(Month = contractMonths, Price = startPrice)


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

# calc total cost
sum(df$Price) + upfrontCost

df = df %>%
  mutate(Diff = Price - startPrice)

ggplot(df, aes(x = Month, y = Price, fill = 'A')) +
  geom_col() +
  geom_richtext(label = sprintf("+£%.2f", df$Diff), size = 6, angle =45, nudge_y = 1, fill = 'white') +
  scale_x_date(date_labels = "%b %y", date_breaks = '1 month') +
  scale_fill_economist() +
  labs(x = '',
       y = 'Monthly Cost (£)') +
  theme_economist() +
  theme(axis.text = element_text( size = 18),
        axis.text.x = element_text(angle = 90),
        axis.title = element_text(face = 'bold', size = 18),
        legend.position = 'NA'
  )
