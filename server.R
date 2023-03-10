###################
# server.R
# 
# For all your server needs 
###################
expand.grid.unique <<- function(x, y, include.equals=FALSE){
  x <- unique(x)
  y <- unique(y)
  g <- function(i)
  {
    z <- setdiff(y, x[seq_len(i-include.equals)])
    if(length(z)) cbind(x[i], z, deparse.level=0)
  }
  do.call(rbind, lapply(seq_along(x), g))
}

server <- function(input, output, session) {
    #Submit files
    observeEvent(input$run, {

    files <- input$upload$datapath
    comp <- compOr <- expand.grid.unique(x= files, y =files)
    comp2 <- expand.grid.unique(x = input$upload$name, y = input$upload$name)

    differences <- sapply(1:nrow(comp), function(x){
    length(diffobj::ses(readLines(comp[x,1]), readLines(comp[x,2])))
    })

    updateSelectizeInput(session, 
       "compare", 
       label = "Select",
       choices = input$upload$name,
       options = list(maxItems = 2)
       )

    comp <- cbind.data.frame(comp2, differences)
    comp <- comp[order(differences, decreasing = FALSE),] 
    colnames(comp) <- c("Submission 1", "Submission 2", "Differences (lines)")

    output$comparison <- DT::renderDataTable(comp,
                      selection = 'single')

  output$diffobj_element <- diffr::renderDiffr({
    x = input$comparison_rows_selected
    x <- if(is.null(x)){1}else{x}
    diffr::diffr(compOr[x,1], compOr[x,2],
    before = comp2[x,1], after = comp2[x,1]
      )
    
  })
  })
}
