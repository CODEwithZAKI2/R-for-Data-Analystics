
# Business Question 1
#What is the overall attrition rate in the company?
  # calculate the percentage of employees who have left (Attrition = "Yes") out of the total   # employees.

total_employees <- hr_data |>
  nrow()



question1 <- hr_data |>
  group_by(Attrition) |>
  summarise(
    Count = n(),
    Percentage = (n() / total_employees) * 100
  )
# alternative way

question1 <- hr_data %>%
  count(Attrition) %>%
  mutate(Percentage = n / sum(n) * 100)

# Question 1 Visualization.

ggplot(question1, aes(x = "", y = Percentage, fill = Attrition)) +
  geom_col(width = 1) +
  coord_polar("y", start = 0) +
  geom_text(aes(
    label = paste0(round(Percentage, 1), "%")
  ), position = position_stack(vjust = 0.5), 
  size = 4, fontface = "bold", color = "white") +
  labs(
    title = "Employee Attrition Rate",
    subtitle = "16.1% of employees left the company",
    fill = "Attrition Status"
  ) +
  scale_fill_manual(
    values = c("No" = "#2E8B57", "Yes" = "#DC143C"),
    labels = c("No" = "Retained", "Yes" = "Left")
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "bottom"
  )


# Business Question 2
# Which department has the highest attrition rate, and how does it compare across all     departments?

unique(hr_data$Department)

question2 <- hr_data |>
  group_by(Department) |>
  summarise(
    Total = n(),
    Left = sum(Attrition == "Yes"), 
    Percentage = (Left / Total) * 100,
    .groups = "drop"
  )

#Visualization question 2

ggplot(question2, aes(x = reorder(Department, Percentage), y = Percentage, fill = Percentage)) +
  geom_col(width = 0.7) +
  coord_flip() +
  geom_text(aes(
    label = paste0(round(Percentage, 1), "%")
  ),
  size = 4, color = "white", fontface = "bold", hjust = 1.1
  ) +
  scale_y_continuous(
    limits = c(0, max(question2$Percentage) * 1.15),
    expand = c(0, 0)
  ) +
  scale_fill_gradient(
    low = "#FFA518", high = "#8B0000",
    name = "Attrition Rate"
  ) +
  labs(
    title = "Attrition Rate by Department",
    subtitle = "Sales department shows highest employee turnover at 20.6%",
    x = "Department",
    y = "Attrition Rate (%)",
    caption = "Based on 1,470 employees"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
    axis.text = element_text(size = 11),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "none",  # Remove legend since colors are obvious
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

# Business Question 3
# How does monthly income relate to attrition? Do employees with lower salaries have      higher attrition rates?

question3 <- hr_data |>
  group_by(Attrition) |>
  summarize(
    average = mean(MonthlyIncome),
    median = median(MonthlyIncome),
    min_salary = min(MonthlyIncome),
    max_salary = max(MonthlyIncome)
  )

# Visualization question 3

ggplot(hr_data, aes(x = Attrition, y = MonthlyIncome, fill = Attrition)) +
  geom_boxplot(alpha = 0.7, outlier.color = "red") +
  scale_y_continuous(labels = scales::dollar_format()) +
  scale_fill_manual(
    values = c("No" = "#2E8B57", "Yes" = "#DC143C"),
    labels = c("No" = "Stayed", "Yes" = "Left")
  ) +
  labs(
    title = "Monthly Income Distribution by Attrition Status",
    subtitle = "Employees who left earned $2,046 less on average",
    x = "Employee Status",
    y = "Monthly Income",
    fill = "Attrition"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12)
  )

# Histogram

ggplot(hr_data, aes(x = MonthlyIncome, fill = Attrition)) +
  geom_histogram(alpha = 0.7, bins = 30, position = "identity") +
  scale_x_continuous(labels = scales::dollar_format()) +
  scale_fill_manual(
    values = c("No" = "#2E8B57", "Yes" = "#DC143C"),
    labels = c("No" = "Stayed", "Yes" = "Left")
  ) +
  labs(
    title = "Income Distribution: Employees Who Stayed vs. Left",
    subtitle = "Lower-paid employees show higher attrition rates",
    x = "Monthly Income",
    y = "Number of Employees",
    fill = "Employee Status"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "bottom"
  )


# Business Question 4
# Does overtime work correlate with attrition? Are employees who work overtime more       likely to leave?


question4 <- hr_data |>
  group_by(OverTime) |>
  summarise(
    Total = n(),
    Left = sum(Attrition == "Yes"), 
    Percentage = (Left / Total) * 100,
    .groups = "drop"
  )

ggplot(question4, aes(x = OverTime, y = Percentage, fill = OverTime)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_text(aes(label = paste0(round(Percentage,1), "%")),
            size = 5, vjust = -0.5, fontface = "bold", color = "black"
  ) +
  scale_y_continuous(
    limits = c(0, max(question4$Percentage) * 1.15),
    expand = c(0, 0),
    labels = scales::percent_format(scale = 1)  # This adds % to y-axis labels
  ) +
  scale_fill_manual(
    values = c("No" = "#2E8B57", "Yes" = "#DC143C"),
    labels = c("No" = "No Overtime", "Yes" = "Works Overtime")
  ) +
  scale_x_discrete(
    labels = c("No" = "No Overtime", "Yes" = "Works Overtime")
  ) +
  labs(
    title = "Attrition Rate by Overtime Status",
    subtitle = "Employees working overtime are 3x more likely to leave (30.5% vs 10.4%)",
    x = "Overtime Status",
    y = "Attrition Rate (%)",
    caption = "Based on 1,470 employees"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray40"),
    axis.text = element_text(size = 11),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "none",  # Remove legend since x-axis labels are clear
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )


# Business Question 5 (Final Question)
# How does job satisfaction relate to attrition across different job levels? Which        combination of job level and satisfaction shows the highest risk?

question5 <- hr_data |>
  group_by(JobSatisfaction, JobLevel) |>
  summarise(
    Total = n(),
    Left = sum(Attrition == "Yes"), 
    Percentage = (Left / Total) * 100,
    .groups = "drop"
  )

ggplot(question5, aes(x = JobLevel, y = JobSatisfaction, fill = Percentage)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = paste0(round(Percentage, 1), "%")), 
            color = "white", size = 4, fontface = "bold") +
  scale_fill_gradient(
    low = "#2E8B57", high = "#8B0000",
    name = "Attrition\nRate (%)",
    labels = function(x) paste0(x, "%")
  ) +
  scale_x_discrete(
    labels = c("1" = "Level 1\n(Entry)", "2" = "Level 2", "3" = "Level 3", 
               "4" = "Level 4", "5" = "Level 5\n(Senior)")
  ) +
  scale_y_discrete(
    labels = c("1" = "Very Low", "2" = "Low", "3" = "High", "4" = "Very High")
  ) +
  labs(
    title = "Employee Attrition Risk Heatmap",
    subtitle = "Job Level 1 + Low Satisfaction shows highest attrition (38.7%)",
    x = "Job Level",
    y = "Job Satisfaction",
    caption = "Darker red = Higher attrition risk | Based on 1,470 employees"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray40"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 12, face = "bold"),
    legend.title = element_text(size = 11, face = "bold"),
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )






























