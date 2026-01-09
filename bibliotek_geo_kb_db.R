# Skript som hämtar geodata för Bibliotek och laddar in i en databas, default är databasen "geodata", schemat
# "malpunkter" och tabellen "laddstationer". Vill man ha andra namn så kan de skickas med som parameter
# 1, 2 respektive 3 för databas, schema och tabell. Alltså tex: 
#                               "Rscript.exe bibliotek_geo_kb_db.R databasnamn schemanamn tabellnamn"
#
# Källa: https://bibdb.libris.kb.se/api
#
# Skriptet sparar datasetet till en postgres-databas, uppkopplingen görs med uppkoppling_adm(), där inloggningsuppgifter
# till databasen (med skrivrättigheter) läggs in med keyringpaketet med service-namnet "databas_adm"
#
# Skapat av: Peter Möller, Region Dalarna

if (!require("pacman")) install.packages("pacman")
p_load(tidyverse,
       sf)

source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_GIS.R", encoding = "utf-8", echo = FALSE)
source("https://raw.githubusercontent.com/Analytikernatverket/hamta_data/main/bibliotek_geo_kb.R")

if (!exists("argv", inherits = FALSE)) argv <- commandArgs(trailingOnly = TRUE)
if (length(argv) == 1 && argv == "inga_parametrar") argv <- character(0)      # ett sätt att hantera parametrar på olika nivåer
databas <- if (length(argv) < 1) "geodata" else argv[1]             # sparar data till databasen "oppna_data" om inte användaren skickar med ett annat databasnamn som argument till skriptet, i så fall används det istället
schema_db <- if (length(argv) < 2) "malpunkter" else argv[2]      # sparar till schema "socialstyrelsen" om det inte finns ett andra argument medskickat
tabell_db <- if (length(argv) < 3) "bibliotek" else argv[3]   # sparar till schema "ek_bistand_hushall" om det inte finns ett tredje argument medskickat


bibliotek_sf <- skriptrader_upprepa_om_fel({
  hamta_bibliotek_geo_kb()
}) 

postgis_databas_uppdatera_med_metadata(con = uppkoppling_adm(databas),
                              inlas_sf = bibliotek_sf,
                              schema = schema_db,
                              tabell = tabell_db,
                              postgistabell_geo_kol = "geometry",
                              postgistabell_id_kol = "sigel")

