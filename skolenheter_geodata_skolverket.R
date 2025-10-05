# Skript som hämtar data från Skolverket och laddar in i en databas, default är databasen "geodata", schemat
# "malpunkter" och tabellen "skolenheter". Vill man ha andra namn så kan de skickas med som parameter
# 1, 2 respektive 3 för databas, schema och tabell. Alltså tex: "Rscript.exe ek_bistand_hushall_socialstyrelsen.R databasnamn schemanamn tabellnamn"
#
# Skriptet sparar datasetet till en postgres-databas, uppkopplingen görs med uppkoppling_adm(), där inloggningsuppgifter
# till databasen (med skrivrättigheter) läggs in med keyringpaketet med service-namnet "databas_adm"
#
# Skapat av: Peter Möller, Region Dalarna

source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_GIS.R", encoding = "utf-8", echo = FALSE)
source("https://raw.githubusercontent.com/Analytikernatverket/hamta_data/main/skolenheter_api_skolverket.R")

if (!exists("args")) args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 1 && args == "inga_parametrar") args <- character(0)      # ett sätt att hantera parametrar på olika nivåer
databas <- if (length(args) < 1) "geodata" else args[1]             # sparar data till databasen "oppna_data" om inte användaren skickar med ett annat databasnamn som argument till skriptet, i så fall används det istället
schema_db <- if (length(args) < 2) "malpunkter" else args[2]      # sparar till schema "socialstyrelsen" om det inte finns ett andra argument medskickat
tabell_db <- if (length(args) < 3) "skolenheter" else args[3]   # sparar till schema "ek_bistand_hushall" om det inte finns ett tredje argument medskickat

skolenheter_sf <- hamta_skolenheter_api_skolverket()

postgis_databas_uppdatera_med_metadata(
  con = uppkoppling_adm(databas),
  inlas_sf = skolenheter_sf,
  schema = schema_db,
  tabell = tabell_db,
  postgistabell_geo_kol = "geom",
  postgistabell_id_kol = "Skolenhetskod"
)
