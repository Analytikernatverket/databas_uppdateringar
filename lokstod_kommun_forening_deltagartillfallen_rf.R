# Skript som hämtar data om lokstöd på kommun-/regsonivå per kön hos RF och laddar in i en databas, default är databasen "oppna_data", schemat
# "rf" och tabellen "lokstod_regso". Vill man ha andra namn så kan de skickas med som parameter
# 1, 2 respektive 3 för databas, schema och tabell. Alltså tex: "Rscript.exe lokstod_kommun_regso_kon_rf.R databasnamn schemanamn tabellnamn"
#
# Skriptet sparar datasetet till en postgres-databas, uppkopplingen görs med uppkoppling_adm(), där inloggningsuppgifter
# till databasen (med skrivrättigheter) läggs in med keyringpaketet med service-namnet "databas_adm"
#
# Skapat av: Peter Möller, Region Dalarna

source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_GIS.R", encoding = "utf-8", echo = FALSE)
source("https://raw.githubusercontent.com/Analytikernatverket/hamta_data/main/lokstod_kommun_forening_deltagare_aktiviteter.R")

script_args <- commandArgs(trailingOnly = TRUE)
if (length(script_args) == 1 && identical(script_args, "inga_parametrar")) script_args <- character(0)      # ett sätt att hantera parametrar på olika nivåer
databas   <- if (length(script_args) < 1) "oppna_data"    else script_args[1]             # sparar data till databasen "oppna_data" om inte användaren skickar med ett annat databasnamn som argument till skriptet, i så fall används det istället
schema_db <- if (length(script_args) < 2) "rf"            else script_args[2]                   # sparar till schema "rf" om det inte finns ett andra argument medskickat
tabell_db <- if (length(script_args) < 3) "lokstod_deltagartillfallen" else script_args[3]        # sparar till schema "lokstod_regso" om det inte finns ett tredje argument medskickat

lokstod_df <- hamta_lok_per_forening()

postgres_databas_skriv_med_metadata(
  con = uppkoppling_adm(databas),
  inlas_df = lokstod_df,
  schema = schema_db,
  tabell = tabell_db
)
