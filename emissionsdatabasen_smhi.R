# Skript som hämtar data från emissionsdatabasen hos SMHI och laddar in i en databas, default är databasen "oppna_data", schemat
# "smhi" och tabellen "emissionsdata". Vill man ha andra namn så kan de skickas med som parameter
# 1, 2 respektive 3 för databas, schema och tabell. Alltså tex: "Rscript.exe emissionsdatabasen_smhi.R databasnamn schemanamn tabellnamn"
# 
# För att kunna hämta data med detta skript måste man ha Python installerat på datorn med Playwright-biblioteket.
#
# Skriptet sparar datasetet till en postgres-databas, uppkopplingen görs med uppkoppling_adm(), där inloggningsuppgifter
# till databasen (med skrivrättigheter) läggs in med keyringpaketet med service-namnet "databas_adm"
#
# Skapat av: Peter Möller, Region Dalarna

source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_GIS.R", encoding = "utf-8", echo = FALSE)
source("https://raw.githubusercontent.com/Analytikernatverket/hamta_data_playwright/main/hamta_emissionsdatabasen_smhi.R")

if (!exists("argv", inherits = FALSE)) argv <- commandArgs(trailingOnly = TRUE)
if (length(argv) == 1 && argv == "inga_parametrar") argv <- character(0)      # ett sätt att hantera parametrar på olika nivåer
databas <- if (length(argv) < 1) "oppna_data" else argv[1]             # sparar data till databasen "oppna_data" om inte användaren skickar med ett annat databasnamn som argument till skriptet, i så fall används det istället
schema_db <- if (length(argv) < 2) "smhi" else argv[2]      # sparar till schema "socialstyrelsen" om det inte finns ett andra argument medskickat
tabell_db <- if (length(argv) < 3) "emissionsdata" else argv[3]   # sparar till schema "ek_bistand_hushall" om det inte finns ett tredje argument medskickat

emissionsdata <- hamta_nationella_emissionsdatabasen()

postgres_databas_skriv_med_metadata(
  con = uppkoppling_adm(databas),
  inlas_df = emissionsdata,
  schema = schema_db,
  tabell = tabell_db
)
