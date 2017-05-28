#install.packages('gamlss')
#install.packages('Lahman')

library(gamlss)
library(dplyr)
library(tidyr)
library(Lahman)
library(ggplot2)
library(broom)

epl_goal_app <- read.csv(file.choose())
epl_shot_app <- read.csv(file.choose())

epl_goal_app <- epl_goal_app[c(-8)]
epl_shot_app <- epl_shot_app[c(-8)]

epl_goal_shot<-merge(epl_goal_app, epl_shot_app, c('name','info','season_rep','club','nation.','pos.','pass','app','avg_pass'),all.y=T)

epl_goal_shot[is.na(epl_goal_shot)] <- 0

epl_goal_shot$hit<-with(epl_goal_shot, goal/shot)
epl_goal_shot <- epl_goal_shot %>% filter(pos.!=c('GK'))
ggplot(subset(epl_goal_shot, app>=10), aes(factor(season_rep), hit, fill=pos.)) + geom_boxplot() + xlab('Season') + stat_summary(fun.y=mean, geom="line", aes(group=as.factor(pos.), colour=as.factor(pos.)))

# http://varianceexplained.org/r/ebbr-package/
# https://github.com/dgrtwo/ebbr
# devtools::install_github("dgrtwo/ebbr")

library(ebbr)
library(splines)

na.omit(epl_goal_shot) %>%
  filter(shot >= 20) %>%
  ggplot(aes(goal / shot)) +
  geom_histogram()

na.omit(epl_goal_shot) %>%
  filter(shot >= 20) %>%
  ebb_fit_prior(goal, shot)

na.omit(epl_goal_shot) %>%
  filter(shot >= 20) %>%
  ggplot(aes(goal / shot)) +
  geom_histogram(bins=30)

sim<- rbeta(1000, 6.423526, 59.91984)
qplot(sim, geom='histogram')

eb_epl_goal_shot <- na.omit(epl_goal_shot) %>%
  add_ebb_estimate(goal, shot, prior_subset = shot >= 20)

#prior <- na.omit(epl_goal_shot) %>% ebb_fit_prior(goal, shot)
#shrunken <- na.omit(epl_goal_shot) %>% add_ebb_estimate(goal, shot)

ggplot(eb_epl_goal_shot, aes(.raw, .fitted, color = log10(shot))) +
  geom_point() +
  geom_abline(color = "red") +
  geom_hline(yintercept = tidy(prior)$mean, color = "red", lty = 2)

eb_epl_goal_shot %>% arrange(-.fitted) %>% head(20) 

eb_epl_goal_shot %>%
  arrange(-.fitted) %>% head(10) %>% mutate(name = paste(name, season_rep)) %>%
  mutate(name = reorder(name, .fitted)) %>%
  ggplot(aes(.fitted, name)) +
  geom_point() +
  geom_errorbarh(aes(xmin = .low, xmax = .high)) +
  labs(x = "Estimated Goal/Shot average (w/ 95% confidence interval)",
       y = "Player")

na.omit(epl_goal_shot) %>%
  filter(shot >= 20) %>%
  ggplot(aes(shot, goal / shot)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_log10()
