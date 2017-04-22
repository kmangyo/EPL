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

# Avg pass box-plot by season and position
ggplot(subset(epl_pst, app>=10), aes(factor(season_rep), avg_pass, fill=pos.)) + geom_boxplot() + xlab('Season') + ylab('Pass') + ggtitle("EPL average number of pass by position")
