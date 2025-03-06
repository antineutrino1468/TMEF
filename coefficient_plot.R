library(ggplot2)
library(dplyr)
library(spacyr)
library(ggrepel)

# load the words-coefficient-frequency data

df_user = read.csv("freq_coef_user.csv")
df_media = read.csv("freq_coef_media.csv")


# coefficient plot of users

df_user %>%
  ggplot(aes(x=importance,y=frequency,label=word,color=importance)) +
  scale_color_gradient2(low="navyblue",
                        mid = "grey",
                        high="forestgreen",
                        midpoint = 0)+
  geom_vline(xintercept=0)+
  geom_point() +
  geom_label_repel(max.overlaps =50)+  
  scale_x_continuous(limits = c(-.016,.011),
                     breaks = seq(-.2,.2,.005)) +
  scale_y_continuous(trans="log2",
                     breaks=c(.01,.05,.1,.2,.5))+
  theme_bw() +
  labs(x="Importance in Users Model",y="Uses per Review")+
  theme(legend.position = "none",
        axis.title=element_text(size=20),
        axis.text=element_text(size=16))

# coefficient plot of medium

df_media %>%
  ggplot(aes(x=importance,y=frequency,label=word,color=importance)) +
  scale_color_gradient2(low="navyblue",
                        mid = "grey",
                        high="forestgreen",
                        midpoint = 0)+
  geom_vline(xintercept=0)+
  geom_point() +
  geom_label_repel(max.overlaps =50)+  
  scale_x_continuous(limits = c(-.007,.006),
                     breaks = seq(-.2,.2,.002)) +
  scale_y_continuous(trans="log2",
                     breaks=c(.01,.05,.1,.2,.5))+
  theme_bw() +
  labs(x="Importance in Media Model",y="Uses per Review")+
  theme(legend.position = "none",
        axis.title=element_text(size=20),
        axis.text=element_text(size=16))

# Find out words with opposing coefficients in two models
df_u = df_user %>%
  select(word, immportance_in_users = importance)  
df_m = df_media %>%
  select(word, immportance_in_medium = importance)  
df = df_u %>% 
  left_join(df_m, by = "word") %>% 
  filter(immportance_in_users*immportance_in_medium<0)

# Select interesting words to analysis
df = df %>%
  filter(word %in% c("good", "halo", "overwatch", "medium", "faith", "buy", "hour", "nobodi")) %>%
  distinct(word, .keep_all = TRUE)  

