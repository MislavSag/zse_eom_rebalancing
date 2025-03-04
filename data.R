library(httr)
library(fastverse)


# Function to clean data
clean = function(res, symbol = "crobex") {
  dt = lapply(res$rows, as.data.table)
  dt = rbindlist(dt)
  dt[, date := as.Date(date, format = "%d.%m.%Y")]
  cols = c("open_value", "high_value", "low_value", "last_value", "turnover")
  dt[, (cols) := lapply(.SD, function(x) gsub("\\.", "", x)), .SDcols = cols]
  dt[, (cols) := lapply(.SD, function(x) gsub(",", ".", x)), .SDcols = cols]
  dt[, (cols) := lapply(.SD, as.numeric), .SDcols = cols]
  dt[, change_prev_close_percentage := NULL]
  dt[, symbol := symbol]
  setorder(dt, date)
  return(dt)
}

# CROBEX
url = "https://zse.hr/json/indexHistory/HRZB00ICBEX6/2010-02-01/2025-02-05/hr?restAPI=https://rest.zse.hr/web/Bvt9fe2peQ7pwpyYqODM/"
p = GET(
  url,
  add_headers(
    "accept-encoding" = "gzip, deflate, br, zstd",
    "user-agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36 Edg/133.0.0.0",
    "Referer" = "https://zse.hr/hr/indeks/365?isin=HRZB00ICBEX6&tab=index_history&date_from=2010-02-01&date_to=2025-02-05"
  )
)
res = content(p)
crobex = clean(res)

# CROBIS
url = "https://zse.hr/json/indexHistory/HRZB00ICRBS8/2010-02-02/2025-02-05/hr?restAPI=https://rest.zse.hr/web/Bvt9fe2peQ7pwpyYqODM/"
p = GET(
  url,
  add_headers(
    "accept-encoding" = "gzip, deflate, br, zstd",
    "user-agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36 Edg/133.0.0.0",
    "Referer" = "https://zse.hr/hr/indeks/365?isin=HRZB00ICRBS8&tab=index_history&date_from=2010-02-02&date_to=2025-02-05"
  )
)
res = content(p)
crobis = clean(res, "crobis")

# Merge CROBEX and CROBIS
dt = rbind(crobex, crobis)

# Save data
fwrite(dt, "data/data.csv")
