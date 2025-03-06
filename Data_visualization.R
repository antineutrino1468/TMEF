
library(quanteda)
library(ggrepel)
library(textclean)
library(tidyverse)
library(glmnet)
library(sentimentr)
library(doc2concrete)
library(ggplot2)
library(stringr)
library(wordcloud)


library(quanteda.textplots)
library(wordcloud)
library(RColorBrewer)



source("vectorFunctions.R") # a new one!
source("TMEF_dfm.R")
source("kendall_acc.R")

media <- read.csv("media_df_filtered_nplus.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
user <- read.csv("user_df_filtered_nplus.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
names(media)
names(user)



user <- user[!is.na(user$Review), ]
user$Word_Count <- str_count(user$Review, "[[:alpha:]]+")





# define category for ploting text distribution
user$Word_Category <- cut(user$Word_Count, 
                          breaks = c(0, 50, 100, 200, 500, Inf), 
                          labels = c("0-50", "51-100", "101-200", "201-500", "500+"),
                          include.lowest = TRUE, right = FALSE)

# define theme
custom_theme <- theme_minimal(base_size = 16) +
  theme(panel.grid.major = element_line(color = "gray85", size = 0.5),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18))

# Distribution of text of the word
if("Word_Category" %in% names(user)) {
  ggplot(user, aes(x = Word_Category)) +
    geom_bar(fill = "#4E79A7", color = "black", alpha = 0.8) +
    labs(title = "User Review Word Count Distribution", 
         x = "Word Count Category", 
         y = "Count") +
    custom_theme
}

# Distribution of User Rating
if("Rating" %in% names(user)) {
  ggplot(user, aes(x = as.factor(Rating))) +
    geom_bar(fill = "#4E79A7", color = "black", alpha = 0.8) +
    labs(title = "User Rating Distribution", 
         x = "User Rating (Discrete)", 
         y = "Count") +
    custom_theme
}

# Distribution of score Rating
if("Score" %in% names(media)) {
  ggplot(media, aes(x = Score)) +
    geom_histogram(binwidth = 1, fill = "#4E79A7", color = "black", alpha = 0.8) +
    labs(title = "Media Score Distribution", 
         x = "Media Score (Continuous)", 
         y = "Count") +
    custom_theme
}








n_gram<-TMEF_dfm(user$Review,ngrams=1)
n_gram

#calculate word frequrncy
word_freq <- textstat_frequency(n_gram)

#cloude of text
set.seed(1234)
wordcloud(words = word_freq$feature, freq = word_freq$frequency, 
          min.freq = 5, max.words = 200, random.order = FALSE, 
          rot.per = 0.05, scale = c(3, 1), colors = brewer.pal(9, "Set2"), 
          family = "sans")

names(user)
names(media)
