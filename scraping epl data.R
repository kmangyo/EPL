# Example

library(rvest)
library(httr)
library(RSelenium)
library(dplyr)
# docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.0 # Terminal
# vignette("RSelenium-docker", package = "RSelenium") 
# vignette("RSelenium-basics", package = "RSelenium")

rD <- rsDriver(port=4444L,browser="chrome")
remDr <- rD$client

# https://www.premierleague.com/stats/top/players/total_pass
# https://www.premierleague.com/stats/top/players/appearances

remDr$navigate('https://www.premierleague.com/stats/top/players/appearances')

position <- remDr$findElement(using = 'xpath', value = "//*[@data-dropdown-block='Position']")
position$clickElement()

position <- remDr$findElement(using = 'xpath', value = "//*[@data-option-name='Goalkeeper']")
position$clickElement()

season<-paste0(c(2006:2015),'/',c('07','08','09',10:16))
move<- data.frame(seq=rep(c('class name'),5),value=rep(c('paginationNextContainer'),5))
home <- remDr$findElement("css", "body")

webSeason<-list()
for (i in 1:length(season)) {
  webSeason[[i]] <- remDr$findElement(using = 'xpath', value = paste0("//*[@data-option-name='",season[i],"']"))
}

html<- list(list(),list(),list(),list(),list(),list(),list(),list(),list(),list())

for (i in 1:length(webSeason)) {
  select <- remDr$findElement(using = 'xpath', value = "//*[@data-dropdown-block='FOOTBALL_COMPSEASON']")
  select$clickElement()
  Sys.sleep(2)
  webSeason[[i]]$clickElement()
  Sys.sleep(5)
  getsource<-list()
  
  for (j in 1:nrow(move)){
    getsource[j] <-remDr$getPageSource()
    html[[i]][[j]]<-getsource[j][[1]]
    page <- remDr$findElement(using = as.character(move[j,1]), value =  as.character(move[j,2]))
    page$clickElement()
    home$sendKeysToElement(list(key = "home"))
    Sys.sleep(5)
  }
  home$sendKeysToElement(list(key = "home"))
  Sys.sleep(2)
}

name<- list()
stat<- list()
info<- list()
team<- list()
season_list<- list()
ij<-data.frame(i=rep(1:10,each=5),j=rep(1:5,10))

for(i in 1:nrow(ij)){
  name[[i]]<- read_html(html[[ij[i,1]]][[ij[i,2]]]) %>% html_nodes(".playerName") %>% html_text()
  stat[[i]]<- read_html(html[[ij[i,1]]][[ij[i,2]]]) %>% html_nodes(".mainStat") %>% html_text()
  info[[i]]<- read_html(html[[ij[i,1]]][[ij[i,2]]]) %>% html_nodes(".playerCountry") %>% html_text()
  team[[i]]<- read_html(html[[ij[i,1]]][[ij[i,2]]]) %>% html_nodes(".hide-s") %>% html_text()
  season_list[[i]]<- read_html(html[[ij[i,1]]][[ij[i,2]]]) %>% html_nodes(".current") %>% html_text()
}

season_rep<-list()

for (i in 1:length(name)){
  season_rep[[i]]<- rep(season_list[[i]][3], length(name[[i]]))
}

name<- unlist(name)
stat<- unlist(stat)
team<-data.frame(matrix(unlist(team), ncol = 2, byrow = TRUE))
info<- unlist(info)
season_rep<- unlist(season_rep)
stat<-subset(stat, nchar(stat)<max(nchar(stat)))

team<-subset(team, X1!=c('Club'))
names(team)<-c('club','nation.')

epl_app<-data.frame(name,stat,info, season_rep)
epl_app<-cbind(epl_app, team)
epl_app<-epl_app[!duplicated(epl_app), ]

epl_app$stat<-gsub(",", "", epl_app$stat)
epl_app$stat<-as.numeric(as.character(epl_app$stat))
