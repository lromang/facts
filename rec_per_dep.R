library(data.table)
library(plyr)
library(dplyr)
library(stringr)
##---------------------------
## Lectura de datos
facts <- read.csv("facts.csv", stringsAsFactors = FALSE)
## Estructuración de datos
facts <- facts[,-8]
facts$slug <- tolower(facts$organization)
facts <- facts[,c(1,8,2,3,4,5,6,7)]
facts$url <- rep(NA, nrow(facts))

##
data <- read.csv("MAT.csv", stringsAsFactors = FALSE)
data <- dplyr::filter(data, dep != "grupos")
data <- data.table(data)

## Conteo de recursos por dependencia
rec_per_dep <- data[,.N, by = slug]

## Fact adicional
public_dep  <- length(unique(data$slug))
ad_fact <- data.frame(organization = "PRESIDENCIA",
                     slug = "presidencia",
                     dataset = "Número de dependencias publicando",
                     resource = "Número de dependencias publicando",
                     url = "http://busca.datos.gob.mx/#/instituciones/presidencia",
                     operations = "Rutina de R",
                     columns = NA,
                     fact = paste0(public_dep,
                                   " dependencias están publicando en datos.gob.mx")
                     )
facts <- rbind(facts, ad_fact)

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
    url      <- paste0("http://busca.datos.gob.mx/#/instituciones/", slug)
    operations <- "Rutina de R"
    columns    <- NA
    fact       <- paste0(dep$N, " Es el número de bases de datos que la dependencia ",
                        organization, " ha publicado. ")
    new_data   <- data.frame(organization = organization,
                            slug = slug,
                            dataset = dataset,
                            resource = resource,
                            url = url,
                            operations = operations,
                            columns = columns,
                            fact = fact)
    facts      <- rbind(facts, new_data)
}


id_conj <- tolower(str_replace_all(facts$dataset," ","-"))
id_conj <- str_replace_all(id_conj,"á","a")
id_conj <- str_replace_all(id_conj,"é","e")
id_conj <- str_replace_all(id_conj,"í","i")
id_conj <- str_replace_all(id_conj,"ó","o")
id_conj <- str_replace_all(id_conj,"ú","u")
con_url     <- dataset_url <- paste0("https://busca.datos.gob.mx/#/conjuntos/",id_conj)
for(i in 1:nrow(facts)){
    if(is.na(facts$url[i])){
        facts$url[i] <- con_url[i]
    }
}

write.csv(facts, "facts_datos_gob_mx.csv", row.names = FALSE)
