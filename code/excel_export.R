#Export workbook using openxlsx package

#Create number formats
pct = createStyle(numFmt = '0.0%')
ppt = createStyle(numFmt = '0.0')
ppt2 = createStyle(numFmt = '0.00')
acct = createStyle(numFmt = '#,#0' )
currency = createStyle(numFmt = '$#,#0') 

#create headerstyle
hs1 <- createStyle(fgFill = "#bfbfbf", halign = "CENTER", textDecoration = "Bold",
                   border = "Bottom", fontColour = "black")

EARN_staterace_umemp <- createWorkbook()

addWorksheet(EARN_staterace_umemp, sheetName = 'State urates')
addWorksheet(EARN_staterace_umemp, sheetName = 'Change since 2020 Q1')
addWorksheet(EARN_staterace_umemp, sheetName = 'Ratios long')
addWorksheet(EARN_staterace_umemp, sheetName = 'Ratios wide')
addWorksheet(EARN_staterace_umemp, sheetName = 'All raw state data')
addWorksheet(EARN_staterace_umemp, sheetName = "LAUS Monthly")
addWorksheet(EARN_staterace_umemp, sheetName = "LAUS Qtrly")
addWorksheet(EARN_staterace_umemp, sheetName = "CPS Monthly")
addWorksheet(EARN_staterace_umemp, sheetName = "CPS Qtrly")

writeData(EARN_staterace_umemp, headerStyle = hs1, state_unemp_rates_final, sheet = 'State urates', startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, change_since_2020q1, sheet = 'Change since 2020 Q1', startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, all_ratios_long, sheet = 'Ratios long', startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, all_ratios_wide, sheet = 'Ratios wide', startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, state_unemp_rates_raw, sheet = 'All raw state data', startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, laus_monthly, sheet = "LAUS Monthly", startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, laus_qtrly, sheet = "LAUS Qtrly", startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, cps_qtrly, sheet = "CPS Qtrly", startCol = 1, startRow = 1, colNames = TRUE)
writeData(EARN_staterace_umemp, headerStyle = hs1, cps_monthly , sheet = "CPS Monthly", startCol = 1, startRow = 1, colNames = TRUE)

#add ppt format
addStyle(EARN_staterace_umemp, 'Change since 2020 Q1', style=ppt, cols=c(2:46), rows=2:(nrow(change_since_2020q1)+1), gridExpand=TRUE)
addStyle(EARN_staterace_umemp, 'Ratios wide', style=ppt2, cols=c(2:46), rows=2:(nrow(all_ratios_wide)+1), gridExpand=TRUE)
addStyle(EARN_staterace_umemp, 'Ratios long', style=ppt2, cols=c(3,4), rows=2:(nrow(all_ratios_long)+1), gridExpand=TRUE)

#add pct format
addStyle(EARN_staterace_umemp, 'State urates', style=pct, cols=c(3:ncol(state_unemp_rates_final)), rows=2:(nrow(state_unemp_rates_final)+1), gridExpand=TRUE)
addStyle(EARN_staterace_umemp, "LAUS Monthly", style=pct, cols=c(2:ncol(laus_monthly)), rows=2:(nrow(laus_monthly)+1), gridExpand=TRUE)
addStyle(EARN_staterace_umemp, "LAUS Qtrly", style=pct, cols=c(2:ncol(laus_qtrly)), rows=2:(nrow(laus_qtrly)+1), gridExpand=TRUE)
addStyle(EARN_staterace_umemp, "CPS Monthly", style=pct, cols=c(2:ncol(cps_qtrly)), rows=2:(nrow(cps_qtrly)+1), gridExpand=TRUE)
addStyle(EARN_staterace_umemp, "CPS Qtrly", style=pct, cols=c(2:ncol(cps_monthly)), rows=2:(nrow(cps_monthly)+1), gridExpand=TRUE)

#set column widths
setColWidths(EARN_staterace_umemp, 'State urates', cols = 2:ncol(state_unemp_rates_final), widths = "auto")


setColWidths(EARN_staterace_umemp, 'Change since 2020 Q1', cols = 2:ncol(change_since_2020q1), widths = "auto")
setColWidths(EARN_staterace_umemp, 'Ratios long', cols = 2:ncol(all_ratios_long), widths = "auto")
setColWidths(EARN_staterace_umemp, 'Ratios wide', cols = 2:ncol(all_ratios_wide), widths = "auto")
setColWidths(EARN_staterace_umemp, 'All raw state data', cols = 2:ncol(state_unemp_rates_raw), widths = "auto")
setColWidths(EARN_staterace_umemp, "LAUS Monthly", cols = 2:ncol(laus_monthly), widths = "auto")
setColWidths(EARN_staterace_umemp, "LAUS Qtrly", cols = 2:ncol(laus_qtrly), widths = "auto")
setColWidths(EARN_staterace_umemp, "CPS Qtrly", cols = 2:ncol(cps_qtrly), widths = "auto")
setColWidths(EARN_staterace_umemp, "CPS Monthly", cols = 2:ncol(cps_monthly), widths = "auto")

#export workbook
saveWorkbook(EARN_staterace_umemp,here(paste0("output/EARN_qtrly_st_race_unemp", format(Sys.time(), "%d-%b-%Y %H.%M"), ".xlsx")), overwrite = TRUE)
