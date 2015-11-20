library(data.table)
library(plyr)
library(dplyr)
##---------------------------
## Lectura de datos
facts <- read.csv("facts_datos_gob_mx.csv", stringsAsFactors = FALSE)
data <- read.csv("MAT.csv", stringsAsFactors = FALSE)
data <- data.table(data)
## Conteo de recursos por dependencia
rec_per_dep <- data[,.N, by = slug]
## Slugs
slugs <- unique(facts$slug)
## Hacer match
for(i in 1:length(slugs)){
    dep <- filter(rec_per_dep, slug == slugs[i])
    ## Crear matriz
    organization <- subset(facts, select = "organization",
                          slug == slugs[i])[1,1]
    slug     <- dep$slug
    dataset  <- "Número de bases de datos"
    resource <- dataset
    url      <- NA
    operations <- "Rutina de R"
    columns    <- NA
    fact       <- paste0(organization, " tiene ",
                        dep$N, " bases de datos. ")
    status     <- "1"
    new_data   <- data.frame(organization = organization,
                            slug = slug,
                            dataset = dataset,
                            resource = resource,
                            url = url,
                            operations = operations,
                            columns = columns,
                            fact = fact,
                            status = status)
    facts      <- rbind(facts, new_data)
}

write.csv(facts, "facts_datos_gob_mx.csv", row.names = FALSE)
