# Load required libraries
library(dplyr)
library(readr)
library(lubridate)
library(stringr)
library(skimr)
library(ggplot2)


# Business Question #1:
 # What are our top 5 best-performing product categories by total sales revenue, and what percentage of our   # total revenue does each represent?

unique(superstore$Sub_Category)

sum(is.na(superstore$Sales))
total_sales <- sum(superstore$Sales, na.rm = T)

question1 <- superstore |>
  group_by(Sub_Category) |>
  summarise(
    Revenue = sum(Sales),
    Per_Revenue = round((sum(Sales) / total_sales) * 100, 2)  # Shows as 15.23% instead of 0.1523
  ) |>
  slice_max(Revenue, n = 5)

# visualize Question 1
ggplot(question1, aes(x = Revenue, y = reorder(Sub_Category, Revenue), fill = Sub_Category)) +
  geom_bar(
    stat = "identity"
  ) +
  labs(
    title = "Top 5 Sub-Categories by Revenue Performance",
    x = "Revenue",
    y = "",
    fill = "Sub-Category"
  ) + 
  geom_text(aes(label = paste0("$", round(Revenue/1000, 0), "K (", Per_Revenue, "%)")),               hjust = -0.1, size = 3) +
  scale_x_continuous(labels = scales::dollar_format(scale = 1e-3, suffix = "K"),
                     limits = c(0, max(question1$Revenue) * 1.2) # Adds 20% more space
                     ) +
  theme_minimal() + 
  guides(fill = "none")

# Business Question #2?
# Which customer segment (Consumer, Corporate, Home Office) generates the highest 
# average order value, and how does their purchasing behavior differ across our three 
# main product categories?

unique(superstore$Segment)

question2 <- superstore |>
  group_by(Category, Segment) |>
  summarise(
    Count = n(),
    Average_Order_Value = mean(Sales),
    .groups = "drop"
  ) |>
  arrange(desc(Average_Order_Value))

# visualization of question 2

ggplot(question2, aes(x = Category, y = Segment, fill = Average_Order_Value)) +
  geom_tile() +
  geom_text(aes(label = paste0("$", round(Average_Order_Value, 0))), color = "white", size = 4) +
  labs(
    title = "Average Order Value Heatmap: Category vs Customer Segment",
    x = "Product Category",
    y = "Customer Segment",
    fill = "Avg Order Value"
  ) +
  scale_fill_gradient(low = "lightblue", high = "darkred", labels = scales::dollar_format()) +
  theme_minimal()


# Business Question #3?
# What is our monthly sales trend over the years, and which months consistently perform # best or worst for our business?

superstore <- superstore |>
  mutate(
    month = month(Order_Date),
    year = year(Order_Date),
    month_name = month(Order_Date, label = TRUE)  # Jan, Feb, Mar...
  )
# month over all years
superstore |>
  group_by(month_name) |>
  summarize(
    total_Sales = sum(Sales)
  ) |>
  arrange(total_Sales)
# month and year
monthly_trends <- superstore |>
  group_by(month_name,year) |>
  summarize(
    total_Sales = sum(Sales),
    .groups = "drop"
  )


# visualization of question 3

ggplot(monthly_trends, aes(x = month_name, y = total_Sales, color = factor(year), group = year)) +
  geom_line(linewidth = 0.9) +
  geom_point() +
  labs(
    title = "Monthly Sales Trends (2014-2017)",
    subtitle = "Clear seasonal patterns with year-over-year growth",
    x = "Month",
    y = "Sales Revenue",
    color = "Year"
  ) +
  scale_color_manual(values = c("2014" = "#1f77b4", "2015" = "#ff7f0e", 
                                  "2016" = "#2ca02c", "2017" = "#d62728")) +
  scale_y_continuous(labels = scales::dollar_format(scale = 1e-3, suffix = "K")) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray50"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )

# Business Question #4?
# Which geographic regions and states are our top performers by profit margin, and are 
# there any regions where we're consistently losing money?

# Region-only analysis 
region_summary <- superstore |>
  group_by(Region) |>
  summarize(
    Total_Sales = sum(Sales),
    Total_Profit = sum(Profit),
    Profit_Margin = (sum(Profit) / sum(Sales)) * 100
  )

# State-only analysis 
state_summary <- superstore |>
  group_by(State) |>
  summarize(
    Total_Sales = sum(Sales),
    Total_Profit = sum(Profit),
    Profit_Margin = (sum(Profit) / sum(Sales)) * 100
  ) |>
  filter(Profit_Margin < 0)


# visualize Question 4
ggplot(state_summary, aes(x = Profit_Margin, y = reorder(State, Profit_Margin), fill = ifelse(Profit_Margin < -15, "Critical", "Concerning"))) +
  geom_bar(
    stat = "identity"
  ) +
  labs(
    title = "States with Negative Profit Margins - Crisis Areas",
    x = "Profit Margin (%)",
    y = ""
  ) + 
  geom_text(aes(label = paste0(round(Profit_Margin,1), "%"),
                color = ifelse(Profit_Margin < -15, "white", "black")),
            hjust = -0.1, size = 3) +
  scale_color_identity() +
  scale_fill_manual(values = c("Critical" = "darkred", "Concerning" = "darkorange")) +
  theme_minimal() + 
  guides(fill = "none") + xlim(min(state_summary$Profit_Margin) * 1.1, 5)


# Final Business Question #5?
# What is the relationship between discount levels and profitability across different 
# product categories, and what discount strategy should we implement to maximize profits


# first create Discount ranges
Discount_Range <- superstore |>
  mutate(
    Discount_Range = case_when(
      Discount == 0 ~ "No Discount",
      Discount > 0 & Discount <= 0.2 ~ "Low (1-20%)",
      Discount > 0.2 & Discount <= 0.4 ~ "Medium (21-40%)",
      Discount > 0.4 ~ "High (40%+)"
    )
  )

question5 <- Discount_Range |>
  group_by(Category, Discount_Range) |>
  summarize(
    Profit_Margin = (sum(Profit) / sum(Sales)) * 100,
    .groups = "drop"
  )


# visualization of question 5

ggplot(question5, aes(x = Category, y = Discount_Range, fill = Profit_Margin)) +
  geom_tile() +
  geom_text(aes(label = paste0(round(Profit_Margin, 0), "%"), 
                color = ifelse(abs(Profit_Margin) > 20, "white", "black")), 
            size = 4) +
  scale_color_identity() +
  labs(
    title = "Discount Strategy Crisis: High Discounts Destroying Profits",
    subtitle = "Profit margins by product category and discount level",
    x = "Product Category",
    y = "Discount Range",
    fill = "Profit Margin"
  ) +
  scale_fill_gradient2(low = "darkred", mid = "white", high = "darkgreen", 
                       midpoint = 0, name = "Profit\nMargin (%)") +
  theme_minimal() 










































































