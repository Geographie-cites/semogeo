##############################
# Shiny App: MOGO
# Server
##############################


shinyServer(function(input, output, session) {
  
  # load data ----
  
  # load database
  load("BDGraphs.RData")
  
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
  
  # update ID for plate construction
  UpdatePlateId <- reactive({

    fullGraph1 <- listOfGraphs[[input$plateedition1]]
    commId1 <- sort(unique(V(fullGraph1)$clus))
    kwId1 <- sort(unique(V(fullGraph1)$name))
    updateSelectInput(session = session, inputId = "platecommid1", choices = commId1)
    updateSelectInput(session = session, inputId = "platekwid1", choices = kwId1)
    
    fullGraph2 <- listOfGraphs[[input$plateedition2]]
    commId2 <- sort(unique(V(fullGraph2)$clus))
    kwId2 <- sort(unique(V(fullGraph2)$name))
    updateSelectInput(session = session, inputId = "platecommid2", choices = commId2)
    updateSelectInput(session = session, inputId = "platekwid2", choices = kwId2)
    
    fullGraph3 <- listOfGraphs[[input$plateedition3]]
    commId3 <- sort(unique(V(fullGraph3)$clus))
    kwId3 <- sort(unique(V(fullGraph3)$name))
    updateSelectInput(session = session, inputId = "platecommid3", choices = commId3)
    updateSelectInput(session = session, inputId = "platekwid3", choices = kwId3)
    
    return()
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
    commSubgraph <- induced.subgraph(fullGraph, vids=V(fullGraph)[V(fullGraph)$clus == input$commid])
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
  
  output$contentsnodes <- renderDataTable({
    InfoTableNodes()
  })

  output$contentsedges <- renderDataTable({
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
             vertcol = "grey40", 
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
  
  
  # panel "Créer une planche"
  
  # ui Outputs
  
  output$interactiveplate1 <- renderUI({
    fullGraph1 <- listOfGraphs[[input$plateedition1]]
    commId1 <- sort(unique(V(fullGraph1)$clus))
    kwId1 <- sort(unique(V(fullGraph1)$name))
    
    if(input$choicecomego1 == "com"){
      selectInput(inputId = "platecommid1",  label = "Choisir communauté ou mot-clef", choices = commId1, selected = "", multiple = FALSE)
    } else {
      selectInput(inputId = "platekwid1",  label = "Choisir communauté ou mot-clef", choices = kwId1, selected = "", multiple = FALSE)
    }
  })
  
  output$interactiveplate2 <- renderUI({
    fullGraph2 <- listOfGraphs[[input$plateedition2]]
    commId2 <- sort(unique(V(fullGraph2)$clus))
    kwId2 <- sort(unique(V(fullGraph2)$name))
    
    if(input$choicecomego2 == "com"){
      selectInput(inputId = "platecommid2",  label = "Choisir communauté ou mot-clef", choices = commId2, selected = "", multiple = FALSE)
    } else {
      selectInput(inputId = "platekwid2",  label = "Choisir communauté ou mot-clef", choices = kwId2, selected = "", multiple = FALSE)
    }
  })
  
  output$interactiveplate3 <- renderUI({
    fullGraph3 <- listOfGraphs[[input$plateedition3]]
    commId3 <- sort(unique(V(fullGraph3)$clus))
    kwId3 <- sort(unique(V(fullGraph3)$name))
    
    if(input$choicecomego3 == "com"){
      selectInput(inputId = "platecommid3",  label = "Choisir communauté ou mot-clef", choices = commId3, selected = "", multiple = FALSE)
    } else {
      selectInput(inputId = "platekwid3",  label = "Choisir communauté ou mot-clef", choices = kwId3, selected = "", multiple = FALSE)
    }
  })
  
  output$textscale <- renderText({
    scaletext <- "La visualisation des communautés et des réseaux d'ego est strictement exploratoire. 
    Les tailles des noeuds et des liens ne sont pas comparables d'une graphe à l'autre (cf. Guide d'utilisation). 
    Créer une planche est nécessaire pour faire une comparaison en visualisant les graphes avec une même échelle."
  })
  
  GetListGraphs <- reactive({
    fullGraph1 <- listOfGraphs[[input$plateedition1]]
    fullGraph2 <- listOfGraphs[[input$plateedition2]]
    fullGraph3 <- listOfGraphs[[input$plateedition3]]
    plateList <- list()
    
    if(!is.null(input$platecommid1)){
      gCom1 <- induced.subgraph(fullGraph1, vids=V(fullGraph1)[V(fullGraph1)$clus == input$platecommid1])
      plateList[[length(plateList) + 1]] <- gCom1
    } else {
      egoId1 <- V(fullGraph1)[V(fullGraph1)$name == input$platekwid1]
      egoSubgraph1 <- induced.subgraph(fullGraph1, vids=c(egoId1, neighbors(fullGraph1, v=egoId1)))
      egoWithCol1 <- GetColPal(egoSubgraph1)
      plateList[[length(plateList) + 1]] <- egoWithCol1
    }
    if(!is.null(input$platecommid2)){
      gCom2 <- induced.subgraph(fullGraph2, vids=V(fullGraph2)[V(fullGraph2)$clus == input$platecommid2])
      plateList[[length(plateList) + 1]] <- gCom2
    } else {
      egoId2 <- V(fullGraph2)[V(fullGraph2)$name == input$platekwid2]
      egoSubgraph2 <- induced.subgraph(fullGraph2, vids=c(egoId2, neighbors(fullGraph2, v=egoId2)))
      egoWithCol2 <- GetColPal(egoSubgraph2)
      plateList[[length(plateList) + 1]] <- egoWithCol2
    }
    if(!is.null(input$platecommid3)){
      gCom3 <- induced.subgraph(fullGraph3, vids=V(fullGraph3)[V(fullGraph3)$clus == input$platecommid3])
      plateList[[length(plateList) + 1]] <- gCom3
    } else {
      egoId3 <- V(fullGraph3)[V(fullGraph3)$name == input$platekwid3]
      egoSubgraph3 <- induced.subgraph(fullGraph3, vids=c(egoId3, neighbors(fullGraph3, v=egoId3)))
      egoWithCol3 <- GetColPal(egoSubgraph3)
      plateList[[length(plateList) + 1]] <- egoWithCol3
    }
    return(plateList)
  })
  
  output$plate <- renderPlot({
    VisuPlate(GetListGraphs(), 
              sizefacnode = input$sizefacnode, 
              sizefacedge = input$sizefacedge, 
              sizefactext = input$sizefactext)
  })
  
})
