library(ggplot2)

# After getting data
epl_fw_pass_app<-merge(epl_fw_pass, epl_fw_app, c('name','info','season_rep','club','nation.'),all.y=T)
epl_fw_pass_app$avg_pass<-with(epl_fw_pass_app, pass/app)

epl_mf_pass_app<-merge(epl_mf_pass, epl_mf_app, c('name','info','season_rep','club','nation.'),all.y=T)
epl_mf_pass_app$avg_pass<-with(epl_mf_pass_app, pass/app)

epl_df_pass_app<-merge(epl_df_pass, epl_df_app, c('name','info','season_rep','club','nation.'),all.y=T)
epl_df_pass_app$avg_pass<-with(epl_df_pass_app, pass/app)

epl_gk_pass_app<-merge(epl_gk_pass, epl_gk_app, c('name','info','season_rep','club','nation.'),all.y=T)
epl_gk_pass_app$avg_pass<-with(epl_gk_pass_app, pass/app)

epl_fw_pass_app$pos.<-'FW'
epl_mf_pass_app$pos.<-'MF'
epl_df_pass_app$pos.<-'DF'
epl_gk_pass_app$pos.<-'GK'

epl_pst<-rbind(epl_fw_pass_app, epl_mf_pass_app, epl_df_pass_app, epl_gk_pass_app)

# GK. Avg pass box-plot by season
ggplot(subset(epl_pst, app>=10 & pos.==c('GK')), aes(factor(season_rep), avg_pass)) + geom_boxplot() + xlab('Season') + ylab('Pass') + ggtitle("EPL GK average number of pass")

# Some GK players
gk_player<-subset(epl_pst,name==c(' Joe Hart')|name==c(' David de Gea')|name==c(' Kasper Schmeichel'))
ggplot(data = subset(gk_player, app>=10), aes(x = factor(season_rep), y = avg_pass, label=name, colour=name)) +geom_point()+geom_label()+ xlab('Season') + ylab('Pass')

# Avg pass box-plot by season and position
ggplot(subset(epl_pst, app>=10), aes(factor(season_rep), avg_pass, fill=pos.)) + geom_boxplot() + xlab('Season') + ylab('Pass') + ggtitle("EPL average number of pass by position")
