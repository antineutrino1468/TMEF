library(quanteda)
library(ggrepel)
library(textclean)
library(tidyverse)
library(glmnet)
library(sentimentr) 
library(stm) 
library(wordcloud)
library(igraph)
library(dbplyr)
library(tidytext)
library(tidyr)
library(purrr)
library(ggplot2)
library(knitr)
library(RColorBrewer)
library(quanteda.textstats)


source("TMEF_dfm.R")
source("kendall_acc.R")

user_df <- read.csv("user_df_filtered_nplus.csv")
media_df <- read.csv("media_df_filtered_nplus.csv")
df <- user_df %>%
  left_join(media_df, by = c("Game.Name" = "Game"))

df_genres <- media_df %>% filter(!is.na(Genres)) %>% 
  group_by(Genres)

df_genres %>%
  summarise(count = n())


# Type of games
df_genre_words <- df_genres %>%
  unnest_tokens(word, Genres) %>%  
  count(word, sort = TRUE)  
print(df_genre_words,n=15)
## on media
###divide into 6 main times based on the frequency of vocabulary and my own knowledge
### 1 Action & Fighting; 2 Adventure & RPG; 3 FPS & TPS; 4 Platformer; 5 Horror Game; 6 Strategy (7 Puzzle 8 Simulation )

genre_mapping <- list(
  "Action & Fighting"   = c("action", "fighting"),
  "Adventure & RPG"     = c("adventure", "rpg", "story", "interactive"),
  "FPS & TPS"           = c("shooter", "person", "first", "third"),
  "Platformer"          = c("platformer", "puzzle"),
  "Horror Game"         = c("horror"),
  "Strategy"            = c("strategy", "simulation", "turn", "based")
)


df_genre_words <- media_df %>%
  filter(!is.na(Genres)) %>%
  unnest_tokens(word, Genres) %>%
  count(Game, word) # 


df_game_types <- df_genre_words %>%
  mutate(Type = map(word, function(w) {
    types <- names(genre_mapping)[sapply(genre_mapping, function(x) w %in% x)]
    if (length(types) > 0) return(types) else return("Others")
  })) %>%
  unnest(Type) %>%
  select(Game, Type) %>%
  distinct()

head(df_game_types)

### Analyse the performance of different kinds of games (based on media)

df_game_info_media <- media_df %>%
  select(Game,Median.Score, Percent.Recommended,Description) %>%
  distinct()

df_type_media <- df_game_types %>%
  left_join(df_game_info_media, by = "Game")

head(df_type_media)

df_summary_media <- df_type_media %>%
  group_by(Type) %>%
  summarise(
    avg_median_score = mean(Median.Score, na.rm = TRUE),
    avg_percent_recommend = mean(Percent.Recommended, na.rm = TRUE)
  ) %>%
  arrange(desc(avg_median_score))  

kable(df_summary_media, digits = 2, format = "simple")

colors_gradient_blues <- colorRampPalette(brewer.pal(9, "Blues"))(9)

ggplot(df_type_media, aes(x = Type, y = Median.Score, fill = Type)) +
  geom_violin(trim = TRUE, alpha = 0.7,width=1.5) +  
  geom_point(data = df_summary_media, aes(x = Type, y = avg_median_score), 
             color = "darkblue", size = 3) +  
  scale_fill_manual(values = colors_gradient_blues) + 
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),  
    axis.title.x = element_blank(),  
    panel.grid.major.x = element_blank(),  
    panel.grid.minor.x = element_blank(),
    legend.position = 'none') +
  labs(title = "Median Score Distribution Across Game Types", y = "Median Score")

###visualise the most frequently occurring words in game descriptions
df_filtered_media_type <- df_type_media %>%
  filter(Type %in% c("Action & Fighting", "Adventure & RPG", "FPS & TPS", 
                     "Platformer", "Horror Game", "Strategy"))
par(mfrow = c(2, 3),mar=c(1,1,2,1))  
colors_gradient <- colorRampPalette(brewer.pal(9, "Blues")[4:9])(50)  

game_types <- unique(df_filtered_media_type$Type)

for (game_type in game_types) {
  df_type_subset <- df_filtered_media_type %>%
    filter(Type == game_type)
  
  dfm_words <- TMEF_dfm(df_type_subset$Description, ngrams = 1)
  
  word_freq <- as.data.frame(textstat_frequency(dfm_words)) %>%
    filter(!feature %in% c('game',"new","world",'play',"player")) %>% 
    arrange(desc(frequency)) %>%
    head(100)
  
  wordcloud(words = word_freq$feature, 
            freq = word_freq$frequency, 
            min.freq = 3,  
            max.words = 100,  
            colors = colors_gradient,  
            scale = c(2, 0.3),  
            random.order = FALSE, 
            rot.per = 0.1)  

  title(main = game_type, cex.main = 1.5, font.main = 2)
}

## on user
df_user_game_types <- user_df %>%
  left_join(df_game_types, by = c("Game.Name" = "Game"))%>%
  mutate(Type = ifelse(is.na(Type), "Others", Type)) %>% 
  mutate(sentiment_score = sentiment_by(get_sentences(Review)) %>%
           pull(ave_sentiment))
head(df_user_game_types)

df_summary_user <- df_user_game_types %>% 
  group_by(Type) %>% 
  summarise(
    avg_rating = round(mean(Rating, na.rm = TRUE), 2),
    avg_sentiment_score = round(mean(sentiment_score, na.rm = TRUE), 2) 
  ) %>% 
  arrange(desc(avg_rating))

kable(df_summary_user, format = "simple", digits = 2)


df_filtered_user_type <- df_user_game_types %>%
  filter(Type %in% c("Action & Fighting", "Adventure & RPG", "FPS & TPS", 
                     "Platformer", "Horror Game", "Strategy"))

par(mfrow = c(2, 3), mar = c(1, 1, 2, 1))  

colors_gradient_red <- colorRampPalette(brewer.pal(9, "Reds")[4:9])(50)  

game_types2 <- unique(df_filtered_user_type$Type)

for (game_type in game_types2) {
  df_type_subset <- df_filtered_user_type %>%
    filter(Type == game_type)
  dfm_words2 <- TMEF_dfm(df_type_subset$Review, ngrams = 1)
  
  word_freq2 <- as.data.frame(textstat_frequency(dfm_words)) %>%
    filter(!feature %in% c('game', 'play',"player","world","war","new")) %>% 
    arrange(desc(frequency)) %>%
    head(100)
  wordcloud(words = word_freq2$feature, 
            freq = word_freq2$frequency, 
            min.freq = 3,  
            max.words = 180,  
            colors = colors_gradient_red,  
            scale = c(2, 0.3),  
            random.order = FALSE, 
            rot.per = 0.1)  
  title(main = game_type, cex.main = 1.5, font.main = 2)
}

#platform difference
##since we have 456 games, just calculate media/platform has over 400 game reviews-representive
df_rvoutlets<- media_df %>% 
  filter(!is.na(Reviewer..Outlet.)) %>% 
  group_by(Reviewer..Outlet.) %>% 
  summarise(count = n()) %>% 
  filter(count>400)
print(df_rvoutlets)

df_rvoutlets_score <- media_df %>%
  filter(Reviewer..Outlet. %in% df_rvoutlets$Reviewer..Outlet.) %>%
  group_by(Reviewer..Outlet.) %>%
  summarise(avg_score = mean(Score, na.rm = TRUE)) %>%
  arrange(desc(avg_score))
print(df_rvoutlets_score)

colors_gradient_blues <- colorRampPalette(brewer.pal(9, "Blues"))(9)

ggplot(media_df %>% filter(Reviewer..Outlet. %in% df_rvoutlets$Reviewer..Outlet.), 
       aes(x = factor(Reviewer..Outlet.), y = Score, fill = Reviewer..Outlet.)) +
  geom_violin(trim = TRUE, alpha = 0.7) +
  geom_point(data = df_rvoutlets_score, aes(x = Reviewer..Outlet., y = avg_score), 
             color = "darkblue", size = 2) + 
  scale_fill_manual(values = colors_gradient_blues) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),  
    axis.title.x = element_blank(),  
    panel.grid.major.x = element_blank(),  
    panel.grid.minor.x = element_blank()
  ) +
  labs(title = "Score Distribution Across Review Outlets (Violin Plot)", y = "Score")+
  theme(legend.position = "none")
