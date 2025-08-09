
# Business Question 1
# What is the distribution of content types (Movies vs TV Shows) on Netflix, and how has      this changed over the years?

totals <- netflix |>
  nrow()

netflix |>
  group_by(type) |>
  summarise(
    total = n(),
    percentage = (n() / totals) * 100
  )

total_movies <- netflix |>
  filter(type == "Movie") |>
  nrow()

total_shows <- netflix |>
  filter(type == "TV Show") |>
  nrow()

# Time Trend Analysis
question1 <- netflix |>
  filter(release_year >=2010) |>
  group_by(release_year) |>
  summarise(
    total = n(),
    movies = sum(type == "Movie") / n() * 100,
    shows = sum(type == "TV Show") / n() * 100,
  )

# Question 1 Visualization

ggplot(question1, aes(x = release_year)) +
  geom_line(aes(y = movies), color = "blue", size = 1.2) +
  geom_line(aes(y = shows), color = "red", size = 1.2) +
  labs(
    title = "Netflix Content Strategy Shift (2010-2021)",
    subtitle = "TV Shows became majority of new releases by 2021",
    x = "Release Year",
    y = "Percentage of New Releases (%)"
  ) +
  scale_y_continuous(limits = c(0, 100)) +
  theme_minimal() +
  annotate("text", x = 2012, y = 75, label = "Movies", color = "blue", size = 4) +
  annotate("text", x = 2019, y = 40, label = "TV Shows", color = "red", size = 4) +
  theme(
    plot.title = element_text(
      hjust = 0.5
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    )
  )


# Business Question 2
# Which countries produce the most content on Netflix, and how does content rating        distribution vary by country?

netflix |>
  filter(!grepl(",", country), !is.na(country)) |>
  nrow()

netflix |>
  filter(is.na(country)) |>
  nrow()

netflix |>
  filter(country == "Not Available") |>
  nrow()


netflix |>
  group_by(country) |>
  summarise(
    total = sum(!grepl(",", country))
  )

netflix |>
  filter(!grepl(",", country), !is.na(country)) |>
  group_by(country) |>
  summarise(
    total = n()
  ) |>
  arrange(desc(total))

question2 <- netflix %>%
  filter(!grepl(",", country), !is.na(country)) %>%
  filter(country %in% c("United States", "India", "United Kingdom", "Japan", "South Korea")) %>%
  group_by(country, rating) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(country) %>%
  mutate(
    total_country = sum(count),
    percentage = (count / total_country) * 100
  ) %>%
  slice_max(n = 3, order_by = percentage) |>
  arrange(country, desc(percentage))

# Visualization of question 2

ggplot(question2, aes(x = country, y = percentage, fill = rating)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  geom_text(aes(label = paste0(round(percentage, 1), "%")), 
            position = position_dodge(width = 0.8), 
            vjust = -0.3, size = 3.5, fontface = "bold") +
  scale_fill_manual(
    values = c("TV-14" = "#1f77b4", "TV-MA" = "#d62728", "TV-PG" = "#2ca02c", "R" = "#ff7f0e"),
    name = "Content Rating"
  ) +
  scale_y_continuous(
    limits = c(0, max(question2$percentage) * 1.1),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Netflix Content Rating Strategies by Country",
    subtitle = "India focuses on teen content (TV-14) while South Korea emphasizes mature content (TV-MA)",
    x = "Country",
    y = "Percentage of Content",
    caption = "Based on single-country Netflix titles"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "bottom"
  )

# Handling multi-value countries

# Step 1: Handle multi-value countries by creating separate rows
netflix_countries_expanded <- netflix %>%
  # Remove rows with NA countries first
  filter(!is.na(country)) %>%
  # Separate countries into individual rows
  separate_rows(country, sep = ", ") %>%
  # Clean any extra whitespace
  mutate(country = str_trim(country))

# Step 2: Count total content by country (including multi-country titles)
country_analysis_full <- netflix_countries_expanded %>%
  group_by(country) %>%
  summarise(
    total = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(total))

# Step 3: Rating analysis with multi-country data
question2_multi <- netflix_countries_expanded %>%
  filter(country %in% c("United States", "India", "United Kingdom", "Canada", "France")) %>%
  group_by(country, rating) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(country) %>%
  mutate(
    total_country = sum(count),
    percentage = (count / total_country) * 100
  ) %>%
  slice_max(n = 3, order_by = percentage) %>%
  arrange(country, desc(percentage))

ggplot(question2_multi, aes(x = country, y = percentage, fill = rating)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.8) +
  geom_text(aes(label = paste0(round(percentage, 1), "%")), 
            position = position_dodge(width = 0.8), 
            vjust = -0.3, size = 3.5, fontface = "bold") +
  scale_fill_manual(
    values = c("TV-14" = "#1f77b4", "TV-MA" = "#d62728", "TV-PG" = "#2ca02c", "R" = "#ff7f0e"),
    name = "Content Rating"
  ) +
  scale_y_continuous(
    limits = c(0, max(question2_multi$percentage) * 1.1),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Global Netflix Content Rating Strategies (Including Co-Productions)",
    subtitle = "India maintains teen focus (54.7% TV-14) while France leads in mature content (41.5% TV-MA)",
    x = "Country",
    y = "Percentage of Content",
    caption = "Based on all Netflix titles including international co-productions"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "bottom"
  )



# Business Question 3
# How do Netflix's content ratings correlate with content duration, and are there         significant differences between Movies and TV Shows in terms of runtime patterns?

netflix |>
  group_by(type) |>
  summarise(
    average = mean(duration_value, na.rm = TRUE),
    summ = sum(duration_value, na.rm = TRUE)
  )

str(netflix$duration_value)

netflix %>%
  filter(type == "Movie") %>%
  summarise(
    total_movies = n(),
    na_count = sum(is.na(duration_value))
  )


question3_movie_data <- netflix |>
  filter(type == "Movie") |>
  group_by(rating) |>
  summarise(
    average = mean(duration_value, na.rm = TRUE)
  ) |>
  arrange(desc(average))

question3_tv_data <- netflix |>
  filter(type == "TV Show") |>
  group_by(rating) |>
  summarise(
    average = mean(duration_value, na.rm = TRUE)
  ) |>
  arrange(desc(average))


# Clean the data first - remove NA and data errors
question3_movie_clean <- question3_movie_data %>%
  filter(!is.na(rating),
         !rating %in% c("66 min", "74 min", "84 min"))

question3_tv_clean <- question3_tv_data %>%
  filter(!is.na(rating))

# Chart 1: Movies (Improved)
chart1 <- ggplot(question3_movie_clean, aes(x = reorder(rating, average), y = average, fill = average)) +
  geom_col(width = 0.7) +
  coord_flip() +
  scale_y_continuous(
    limits = c(0, max(question3_movie_clean$average) * 1.15),
    expand = c(0, 0)
  ) +
  geom_text(aes(label = paste0(round(average, 0), " min")),
            hjust = -0.1, size = 3.5, fontface = "bold") +
  scale_fill_gradient(
    low = "#87CEEB", high = "#1e3a8a",
    name = "Minutes"
  ) +
  labs(
    title = "Movie Duration by Content Rating",
    subtitle = "Mature content averages longer runtime",
    x = "Content Rating",
    y = "Average Duration (Minutes)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40", size = 11),
    axis.title = element_text(face = "bold"),
    legend.position = "none",
    panel.grid.major.y = element_blank()
  )

# Chart 2: TV Shows (Improved)
chart2 <- ggplot(question3_tv_clean, aes(x = reorder(rating, average), y = average, fill = average)) +
  geom_col(width = 0.7) +
  coord_flip() +
  scale_y_continuous(
    limits = c(0, max(question3_tv_clean$average) * 1.15),
    expand = c(0, 0)
  ) +
  geom_text(aes(label = paste0(round(average, 1), " seasons")),
            hjust = -0.1, size = 3.5, fontface = "bold") +
  scale_fill_gradient(
    low = "#fca5a5", high = "#dc2626",
    name = "Seasons"
  ) +
  labs(
    title = "TV Show Duration by Content Rating",
    subtitle = "Family content gets more seasons",
    x = "Content Rating", 
    y = "Average Seasons"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40", size = 11),
    axis.title = element_text(face = "bold"),
    legend.position = "none",
    panel.grid.major.y = element_blank()
  )

# Combine charts
library(patchwork)
chart1 | chart2

# Combine side-by-side
library(patchwork)
chart1 | chart2

# Business Question 4
# What are the most popular genres on Netflix, and how has genre popularity evolved over   the years? Additionally, which genres tend to have higher content ratings (more mature   content)?


netflix |>
  filter(grepl(",", listed_in), !is.na(listed_in)) |>
  nrow()

# Step 1: Handle multi-value genre by creating separate rows
netflix_genre_expanded <- netflix %>%
  # Remove rows with NA Genre first
  filter(!is.na(listed_in)) %>%
  # Separate Genre into individual rows
  separate_rows(listed_in, sep = ", ") %>%
  # Clean any extra whitespace
  mutate(listed_in = str_trim(listed_in))



netflix_genre_expanded %>%
  group_by(listed_in) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  head(15)

# Define top genres to track
top_genres <- c("International Movies", "Dramas", "Comedies", 
                "International TV Shows", "Documentaries", "Action & Adventure")

# Analyze trends for top genres only
question4 <- netflix_genre_expanded %>%
  filter(release_year >= 2015, 
         listed_in %in% top_genres) %>%
  group_by(release_year, listed_in) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(release_year, desc(count))

# question 4 visualization

ggplot(question4, aes(x = release_year, y = count, color = listed_in)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 2.5, alpha = 0.9) +
  scale_x_continuous(
    breaks = 2015:2021,
    labels = 2015:2021
  ) +
  scale_y_continuous(
    labels = scales::comma_format(),
    breaks = seq(0, 350, 50)
  ) +
  scale_color_manual(
    values = c(
      "International Movies" = "#1f77b4",
      "Dramas" = "#ff7f0e", 
      "Comedies" = "#2ca02c",
      "International TV Shows" = "#d62728",
      "Documentaries" = "#9467bd",
      "Action & Adventure" = "#8c564b"
    ),
    name = "Genre"
  ) +
  labs(
    title = "Netflix Genre Strategy Evolution (2015-2021)",
    subtitle = "Strategic shift from International Movies to International TV Shows",
    x = "Release Year",
    y = "Number of Titles",
    caption = "Based on Netflix content with release years 2015-2021"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40", size = 12),
    axis.title = element_text(face = "bold", size = 12),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = 10)
  ) +
  guides(color = guide_legend(nrow = 2))


# Business Question 5 (Final)
# How do Netflix's content characteristics (genre, rating, duration) vary between         different countries' content, and what does this reveal about cultural preferences and   Netflix's localization strategy?


# Step 1: Handle multi-value genre by creating separate rows
netflix_genre_country_expanded <- netflix_countries_expanded %>%
  # Remove rows with NA Genre first
  filter(!is.na(listed_in)) %>%
  # Separate Genre into individual rows
  separate_rows(listed_in, sep = ", ") %>%
  # Clean any extra whitespace
  mutate(listed_in = str_trim(listed_in))



netflix_genre_country_expanded %>%
  filter(country %in% c("United States", "India", "France")) %>%
  group_by(country, listed_in)
  summarise(count = n(), .groups = "drop") %>%
  arrange(country, desc(count))

# Get top 5 genres per country
netflix_genre_country_expanded %>%
  filter(country %in% c("United States", "India", "France")) %>%
  group_by(country, listed_in) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(country) %>%
  slice_max(n = 5, order_by = count) %>%
  arrange(country, desc(count))

# Duration Analysis by Country
netflix_countries_expanded %>%
  filter(country %in% c("United States", "India", "France")) %>%
  group_by(country, type) %>%
  summarise(count = n(), avg_duration = mean(duration_value, na.rm = TRUE),
            .groups = "drop") %>%
  arrange(country, desc(count))


library(patchwork)

# Panel 1: Duration Comparison
p1 <- netflix_countries_expanded %>%
  filter(country %in% c("United States", "India", "France")) %>%
  group_by(country, type) %>%
  summarise(avg_duration = mean(duration_value, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = country, y = avg_duration, fill = type)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_text(aes(label = round(avg_duration, 0)), 
            position = position_dodge(width = 0.7), vjust = -0.3) +
  facet_wrap(~type, scales = "free_y") +
  labs(title = "Duration Strategies", y = "Avg Duration") +
  theme_minimal() +
  theme(legend.position = "none")

p1

# Panel 2: Content Type Distribution  
p2 <- netflix_countries_expanded %>%
  filter(country %in% c("United States", "India", "France")) %>%
  count(country, type) %>%
  group_by(country) %>%
  mutate(percentage = n/sum(n)*100) %>%
  ggplot(aes(x = country, y = percentage, fill = type)) +
  geom_col() +
  geom_text(aes(label = paste0(round(percentage,0), "%")), 
            position = position_stack(vjust = 0.5)) +
  labs(title = "Content Type Focus", y = "Percentage") +
  theme_minimal()

p2

# Panel 3: Top Genres (simplified)
p3 <- netflix_genre_country_expanded %>%
  filter(country %in% c("United States", "India", "France"),
         listed_in %in% c("Dramas", "Comedies", "International Movies", "Documentaries")) %>%
  count(country, listed_in) %>%
  ggplot(aes(x = listed_in, y = n, fill = country)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(title = "Genre Preferences", x = "Genre", y = "Count") +
  theme_minimal()

p3

# Combine all panels
(p1 / p2 / p3) +
  plot_annotation(
    title = "Netflix Cultural Content Strategies",
    subtitle = "India: Long movies, short series | France: Quality focus | USA: Efficient movies, extended series"
  )








































