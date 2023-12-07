library(rvest)
library(dplyr)
library(DBI)
library(RMariaDB)
library(lubridate)

logfile <- "C:\\Users\\Administrator\\Documents\\dal\\log\\log.txt"
sink(file = logfile, append = TRUE)

dbcon <- dbConnect(MariaDB(),
                   host = "localhost",
                   db = "deauto",
                   user = "root",
                   password = "1234")

url <- "https://www.autoscout24.de/lst/bmw/3er-(alle)?adage=1&atype=C&cy=D&damaged_listing=exclude&desc=0&ocs_listing=include&powertype=kw&priceto=20000&search_id=1r2b3eom0vv&sort=standard&source=listpage_pagination&page=1"

deuatopage <- read_html(url)
box_tag <- ".ListItem_wrapper__J_a_C"
car_nodes <- deuatopage %>% html_nodes(box_tag)

data_list <- list()

cat("Scraper fra", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

for (i in 1:length(car_nodes)) {
  deautocar <- car_nodes[[i]]
  carname <- deautocar %>% html_node("h2") %>% html_text()
  priceid <- deautocar %>% html_node(".PriceAndSeals_current_price__XscDn") %>% html_text()
  priceid <- gsub("[^0-9]", "", priceid)
  priceid <- as.numeric(priceid)
  
  Scrapedate <- Sys.Date()
  
  element_data <- list(
    carname = carname,
    priceid = priceid,
    Scrapedate = Scrapedate
  )
  
  data_list[[i]] <- element_data
}

AutoScout23_df <- bind_rows(data_list)

cat("Scraper fra", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Data hentet:", nrow(AutoScout23_df), "observationer\n")

if (nrow(AutoScout23_df) > 0) {
  dbWriteTable(dbcon, name = "AutoScout23", value = AutoScout23_df, append = TRUE)
}

sink()




