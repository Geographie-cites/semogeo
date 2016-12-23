##############################
# Shiny App: MOGO
# User interface
##############################

shinyUI(fluidPage(
  titlePanel("mogéo : Les mots-clés des géographes en réseaux",
              tags$head(tags$link(rel = "icon", type = "image/png", href = "favicon.png"),
                        tags$title("mogéo : Les mots-clés des géographes en réseaux"),
                        includeScript('www/analytics.js'))
  ),
  

    tabsetPanel(
      
      tabPanel("Guide d'utilisation",
               withMathJax(), 
               includeMarkdown("README.md")),
      
      tabPanel("Résumé de l'information",
               fluidRow(
                 column(3, selectInput(inputId = "editionres", 
                                       label = "Choisir une édition du RG", 
                                       choices = c("RG1973", "RG1980", "RG1989", "RG1998", "RG2007"), 
                                       selected = "RG2007", 
                                       multiple = FALSE))),
               tags$hr(),
               htmlOutput("textfull"),
               tags$hr(),
               dataTableOutput("contentsnodes"),
               dataTableOutput("contentsedges")
      ),
      
      tabPanel("Communautés",
               fluidRow(
                 column(4, selectInput(inputId = "editioncom",
                           label = "Choisir une édition du RG",
                           choices = c("RG1973", "RG1980", "RG1989", "RG1998", "RG2007"),
                           selected = "RG2007",
                           multiple = FALSE)),
                 column(4, selectInput(inputId = "commid", 
                                       label = "Choisir une communauté", 
                                       choices = "",
                                       selected = "",
                                       multiple = FALSE))),
               fluidRow(
                 column(12, 
                        fluidRow(
                          column(3, wellPanel(
                            tags$strong("Réglages graphiques"),
                            radioButtons("vsizecom", "Proportionnalité des noeuds",
                                         list("Uniforme" = "uni",
                                              "Nombre d'auteurs" = "poi",
                                              "Degré des noeuds" = "deg")),
                            radioButtons("esizecom", "Proportionnalité des liens",
                                         list("Résidus relatifs" = "rel",
                                              "Nombre de liens" = "nbl")),
                            sliderInput(inputId = "vfacsizecom", 
                                        label = "Taille des noeuds", 
                                        min = 0, 
                                        max = 1, 
                                        value = 0.5, 
                                        step = 0.05),
                            sliderInput(inputId = "efacsizecom", 
                                        label = "Taille des liens", 
                                        min = 0, 
                                        max = 2, 
                                        value = 1, 
                                        step = 0.1),
                            sliderInput(inputId = "tsizecom",
                                        label = "Taille de police", 
                                        min = 1, 
                                        max = 15, 
                                        value = 10, 
                                        step = 1),
                            downloadButton("downcomm", "Download plot"))),
                          
                          column(9, plotOutput("plotcomm", width = "100%", height = "800px")))))
      ),
      
      tabPanel("Réseau d'ego",
               fluidRow(
                 column(4, selectInput(inputId = "editionego",
                                       label = "Choisir une édition du RG",
                                       choices = c("RG1973", "RG1980", "RG1989", "RG1998", "RG2007"),
                                       selected = "RG2007",
                                       multiple = FALSE)),
                 column(4, selectInput(inputId = "kwid1", 
                                       label = "Choisir un mot-clef", 
                                       choices = "", 
                                       selected = "", 
                                       multiple = FALSE))),
               fluidRow(
                 column(12, 
                        fluidRow(
                          column(3, wellPanel(
                            tags$strong("Réglages graphiques"),
                            radioButtons("vsizeego", "Proportionnalité des noeuds",
                                         list("Uniforme" = "uni",
                                              "Nombre d'auteurs" = "poi",
                                              "Degré des noeuds" = "deg")),
                            sliderInput(inputId = "vfacsizeego", 
                                        label = "Taille des noeuds", 
                                        min = 0, 
                                        max = 1, 
                                        value = 0.5, 
                                        step = 0.05),
                            sliderInput(inputId = "tsizeego",
                                        label = "Taille de police", 
                                        min = 1, 
                                        max = 15, 
                                        value = 10, 
                                        step = 1),
                            sliderInput(inputId = "esizeego", 
                                        label = "Taille des liens", 
                                        min = 0, 
                                        max = 2, 
                                        value = 1, 
                                        step = 0.1),
                            downloadButton("downego", "Download plot"))),
                          
                          column(9, plotOutput("plotego", width = "100%", height = "800px")))))
      ),
      
      tabPanel("Aire sémantique",
               fluidRow(
                 column(4, selectInput(inputId = "editionsem", 
                                       label = "Choisir une édition du RG", 
                                       choices = c("RG1973", "RG1980", "RG1989", "RG1998", "RG2007"), 
                                       selected = "RG2007", 
                                       multiple = FALSE)),
                 column(4, selectInput(inputId = "kwid2", 
                                       label = "Choisir un mot-clef", 
                                       choices = "", 
                                       selected = "", 
                                       multiple = FALSE))),
               fluidRow(
                 column(12, 
                        fluidRow(
                          column(3, wellPanel(
                            tags$strong("Réglages graphiques"),
                            sliderInput(inputId = "tsizesemmin", 
                                        label = "Taille de police (min)", 
                                        min = 1, 
                                        max = 10, 
                                        value = 4, 
                                        step = 0.5),
                            sliderInput(inputId = "tsizesemmax", 
                                        label = "Taille de police (max)", 
                                        min = 1, 
                                        max = 10, 
                                        value = 6, 
                                        step = 0.5),
                            downloadButton("downsem", "Download plot"))),
                          
                          column(9, plotOutput("plotsem", width = "100%", height = "800px")))))
      )
    )
  )
)

