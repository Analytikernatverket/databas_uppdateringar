# Skript som hämtar data från socialstyrelsen och laddar in i en databas, default är databasen "oppna_data", schemat
# "socialstyrelsen" och tabellen "ek_bistand_hushall". Vill man ha andra namn så kan de skickas med som parameter
# 1, 2 respektive 3 för databas, schema och tabell. Alltså tex: "Rscript.exe ek_bistand_hushall_socialstyrelsen.R databasnamn schemanamn tabellnamn"
# 
# För att kunna hämta data från Socialstyrelsen måste man ha Python installerat på datorn med Playwright-biblioteket.
#
# Skriptet sparar datasetet till en postgres-databas, uppkopplingen görs med uppkoppling_adm(), där inloggningsuppgifter
# till databasen (med skrivrättigheter) läggs in med keyringpaketet med service-namnet "databas_adm"
#
# Skapat av: Peter Möller, Region Dalarna

source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_GIS.R", encoding = "utf-8", echo = FALSE)
source("https://raw.githubusercontent.com/Analytikernatverket/hamta_data_playwright/main/hamta_gastnatter_per_hemland_lan_tillvaxtverket.R")

# if (!exists("argv", inherits = FALSE)) argv <- commandArgs(trailingOnly = TRUE)
# if (length(argv) == 1 && argv == "inga_parametrar") argv <- character(0)      # ett sätt att hantera parametrar på olika nivåer



if (exists("argv", inherits = FALSE)) {                         # 1) Använd lokalt injicerad 'argv' om den finns (vid source(local=...))
  params <- argv
} else {                                                        # 2) Annars plocka via commandArgs (vid Rscript-körning)
  params <- commandArgs(trailingOnly = TRUE)
  if (length(params) > 0 && identical(params[1], "--args")) {   # VIKTIGT: Rensa bort "--args" om den råkar hänga kvar
    params <- params[-1]
  }
}
params <- params[nzchar(params)]                                # rensa tomma tokens



databas <- if (length(params) < 1) "oppna_data" else params[1]             # sparar data till databasen "oppna_data" om inte användaren skickar med ett annat databasnamn som argument till skriptet, i så fall används det istället
schema_db <- if (length(params) < 2) "tillvaxtverket" else params[2]      # sparar till schema "socialstyrelsen" om det inte finns ett andra argument medskickat
tabell_db <- if (length(params) < 3) "gastnatter_hemland_lan" else params[3]       # sparar till schema "ek_bistand_hushall" om det inte finns ett tredje argument medskickat

gastnatter_per_hemland_lan <- hamta_gastnatter_per_hemland_lan_tillvaxtverket()

postgres_databas_skriv_med_metadata(
  con = uppkoppling_adm(databas),
  inlas_df = gastnatter_per_hemland_lan,
  schema = schema_db,
  tabell = tabell_db
)
