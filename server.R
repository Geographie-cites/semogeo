##############################
# Shiny App: MOGO
# Server
##############################


shinyServer(function(input, output, session) {
  
  # load data ----
  
  # load database
  listOfGraphs <- readRDS(file = "BDGraphs.Rds")
  
  # select year and other variables
  SelectYearRes <- reactive({
    fullGraph <- listOfGraphs[[input$editionres]]
    return(fullGraph)
  })
  
  # select year and other variables
  SelectYearCom <- reactive({
    fullGraph <- listOfGraphs[[input$editioncom]]
    commId <- sort(unique(V(fullGraph)$clus))
    updateSelectInput(session = session, inputId = "commid", choices = commId)
    return(fullGraph)
  })
  
  # select year and other variables
  SelectYearEgo <- reactive({
    fullGraph <- listOfGraphs[[input$editionego]]
    kwId <- sort(unique(V(fullGraph)$name))
    updateSelectInput(session = session, inputId = "kwid1", choices = kwId)
    updateSelectInput(session = session, inputId = "kwid2", choices = kwId)
    return(fullGraph)
  })
  
  # select year and other variables
  SelectYearSem <- reactive({
    fullGraph <- listOfGraphs[[input$editionsem]]
    kwId <- sort(unique(V(fullGraph)$name))
    updateSelectInput(session = session, inputId = "kwid2", choices = kwId)
    return(fullGraph)
  })
  

  
  # create information table for nodes
  InfoTableNodes <- reactive({
    g <- SelectYearRes()
    infoNodes <- data.frame(MOTS = V(g)$name, NB_AUTH = V(g)$nbauth, DEGRE = V(g)$degbeg)
    return(infoNodes)
  })
  
  # create information table for edges
  InfoTableEdges <- reactive({
    g <- SelectYearRes()
    infoEdges <- get.data.frame(g)
    tabEdges <- data.frame(MOT1 = infoEdges[ , 1],
                           MOT2 = infoEdges[ , 2],
                           P_OBSERVE = infoEdges[ , 3],
                           P_THEORIQUE = round(infoEdges[ , 4], 2),
                           RESIDU = round(infoEdges[ , 5], 2))
    return(tabEdges)
  })
  
  # select community
  SelectComm <- reactive({
    fullGraph <- SelectYearCom()
    commSubgraph <- induced.subgraph(fullGraph, vids=as.vector(V(fullGraph)[V(fullGraph)$clus == input$commid]))
  })
  
  # create ego network
  SelectEgo <- reactive({
    fullGraph <- SelectYearEgo()
    egoId <- V(fullGraph)[V(fullGraph)$name == input$kwid1]
    egoSubgraph <- induced.subgraph(fullGraph, vids=c(egoId, neighbors(fullGraph, v=egoId)))
    egoWithCol <- GetColPal(egoSubgraph)
  })
  
  # create semantic field
  SelectSemField <- reactive({
    fullGraph <- SelectYearSem()
    SemSubgraph <- SemanticField(fullGraph, kw=input$kwid2)
  })

  
  # outputs ----
  
  # panel "Réseau complet"
  
  output$textfull <- renderText({
    summarytext <- paste("<strong>Description :</strong> le réseau de mots-clefs comporte <strong>",
                         vcount(SelectYearRes()), 
                         " noeuds</strong> (nombre de mots-clefs) et <strong>",
                         ecount(SelectYearRes()),
                         " arcs</strong> (nombre de liens entre mots-clefs).",
                         sep = "")
  })
  
  output$contentsnodes <- renderDataTable(options = list(pageLength = 10), expr = {
    InfoTableNodes()
  })

  output$contentsedges <- renderDataTable(options = list(pageLength = 10), expr = {
    InfoTableEdges()
  })
  
  
  # panel "Communautés"
  
  output$plotcomm <- renderPlot({
    if(input$vsizecom == "uni" && input$esizecom == "rel"){
      vertsize <- 1
      edgesize <- E(SelectComm())$relresid
    } else if(input$vsizecom == "uni" && input$esizecom == "nbl"){
      vertsize <- 1
      edgesize <- E(SelectComm())$obsfreq
    } else if(input$vsizecom == "poi" && input$esizecom == "rel"){
      vertsize <- V(SelectComm())$nbauth
      edgesize <- E(SelectComm())$relresid
    } else if(input$vsizecom == "poi" && input$esizecom == "nbl"){
      vertsize <- V(SelectComm())$nbauth
      edgesize <- E(SelectComm())$obsfreq
    } else if(input$vsizecom == "deg" && input$esizecom == "rel"){
      vertsize <- V(SelectComm())$degbeg
      edgesize <- E(SelectComm())$relresid
    } else if(input$vsizecom == "deg" && input$esizecom == "nbl"){
      vertsize <- V(SelectComm())$degbeg
      edgesize <- E(SelectComm())$obsfreq
    }
      
    VisuComm(SelectComm(), 
             year = input$editioncom, 
             comm = input$commid, 
             vertcol = "grey50", 
             vertsize = vertsize, 
             vfacsize = input$vfacsizecom,
             edgesize = edgesize,
             efacsize = input$efacsizecom, 
             textsize = input$tsizecom)
    
  })
  
  output$downcomm <- downloadHandler(
    filename = "Communautes.svg",
    content = function(file) {
      if(input$vsizecom == "uni" && input$esizecom == "rel"){
        vertsize <- 30
        edgesize <- E(SelectComm())$relresid
      } else if(input$vsizecom == "uni" && input$esizecom == "nbl"){
        vertsize <- 30
        edgesize <- E(SelectComm())$obsfreq
      } else if(input$vsizecom == "poi" && input$esizecom == "rel"){
        vertsize <- V(SelectComm())$nbauth
        edgesize <- E(SelectComm())$relresid
      } else if(input$vsizecom == "poi" && input$esizecom == "nbl"){
        vertsize <- V(SelectComm())$nbauth
        edgesize <- E(SelectComm())$obsfreq
      } else if(input$vsizecom == "deg" && input$esizecom == "rel"){
        vertsize <- V(SelectComm())$degbeg
        edgesize <- E(SelectComm())$relresid
      } else if(input$vsizecom == "deg" && input$esizecom == "nbl"){
        vertsize <- V(SelectComm())$degbeg
        edgesize <- E(SelectComm())$obsfreq
      }
      
      svg(file, width = 20 / 2.54, height = 20 / 2.54, pointsize = 8)
      VisuComm(SelectComm(), 
               year = input$editioncom, 
               comm = input$commid, 
               vertcol = "grey30", 
               vertsize = vertsize, 
               vfacsize = input$vfacsizecom,
               edgesize = edgesize,
               efacsize = input$efacsizecom, 
               textsize = input$tsizecom)
      dev.off()
    })
  
  
  # panel "Réseau d'ego"

  output$plotego <- renderPlot({
    if(input$vsizeego == "uni"){
    VisuEgo(SelectEgo(), 
            year = input$editionego, 
            kw = input$kwid1, 
            vertcol = NA, 
            vertlabcol = V(SelectEgo())$clus,
            vertsize = 1, 
            vfacsize = 1,
            edgesize = input$esizeego, 
            textsize = input$tsizeego)
    } else if(input$vsizeego == "poi") {
      VisuEgo(SelectEgo(), 
              year = input$editionego, 
              kw = input$kwid1, 
              vertcol = V(SelectEgo())$clus, 
              vertlabcol = "grey14", 
              vertsize = V(SelectEgo())$nbauth, 
              vfacsize = input$vfacsizeego,
              edgesize = input$esizeego, 
              textsize = input$tsizeego)
    } else {
      VisuEgo(SelectEgo(), 
              year = input$editionego, 
              kw = input$kwid1, 
              vertcol = V(SelectEgo())$clus, 
              vertlabcol = "grey14", 
              vertsize = V(SelectEgo())$degbeg, 
              vfacsize = input$vfacsizeego,
              edgesize = input$esizeego, 
              textsize = input$tsizeego)
    }
  })
  
  output$downego <- downloadHandler(
    filename = "EgoReso.svg",
    content = function(file) {
      svg(file, width = 20 / 2.54, height = 20 / 2.54, pointsize = 8)
      if(input$vsizeego == "uni"){
        VisuEgo(SelectEgo(), 
                year = input$editionego, 
                kw = input$kwid1, 
                vertcol = NA, 
                vertlabcol = V(SelectEgo())$clus,
                vertsize = 1, 
                vfacsize = 1,
                edgesize = input$esizeego, 
                textsize = input$tsizeego)
      } else if(input$vsizeego == "poi") {
        VisuEgo(SelectEgo(), 
                year = input$editionego, 
                kw = input$kwid1, 
                vertcol = V(SelectEgo())$clus, 
                vertlabcol = "grey14", 
                vertsize = V(SelectEgo())$nbauth, 
                vfacsize = input$vfacsizeego,
                edgesize = input$esizeego, 
                textsize = input$tsizeego)
      } else {
        VisuEgo(SelectEgo(), 
                year = input$editionego, 
                kw = input$kwid1, 
                vertcol = V(SelectEgo())$clus, 
                vertlabcol = "grey14", 
                vertsize = V(SelectEgo())$degbeg, 
                vfacsize = input$vfacsizeego,
                edgesize = input$esizeego, 
                textsize = input$tsizeego)
      }
      dev.off()
    })
  
  
  # panel "Aire sémantique"
  
  output$plotsem <- renderPlot({
      VisuSem(SelectSemField(), year = input$editionsem, kw = input$kwid2, textsizemin = input$tsizesemmin, textsizemax = input$tsizesemmax)
  })
  
  output$downsem <- downloadHandler(
    filename = "AireSemantique.svg",
    content = function(file) {
      svg(file, width = 20 / 2.54, height = 20 / 2.54, pointsize = 8)
        VisuSem(SelectSemField(), year = input$editionsem, kw = input$kwid2, textsizemin = input$tsizesemmin, textsizemax = input$tsizesemmax)
      dev.off()
    })
  
  
})
