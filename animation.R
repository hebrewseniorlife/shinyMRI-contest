raster3d_animation_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(4, tagList(
        actionButton(ns("zoom_m"), "", icon = icon("minus-square-o"), width = "40px", 
                     style = "border-radius: 25px; padding: 0px;"),
        actionButton(ns("zoom_p"), "", icon = icon("plus-square-o"), width = "40px", 
                     style = "border-radius: 25px; padding: 0px;")
      )),
      column(4, offset = 4, uiOutput(ns("time_slider_UI")))
    ),
    fluidRow(
      lapply(c("x", "y", "z"), function(x) {
        column(4, align = "center", uiOutput(ns(paste0(x, "_slider_UI"))))
      })
    ),
    fluidRow(
      lapply(c("x_plot", "y_plot", "z_plot"), function(x) {
        column(4, align = "center", plotOutput(ns(x)))
      })
    )
  )
}

raster3d_animation_Module <- function(input, output, session, im) {
  temp_dir <- file.path(tempdir(), "shinyMRI")
  dir.create(temp_dir, showWarnings = FALSE)
  img_slice <- function(x) {
    temp_img <- tempfile("", temp_dir, fileext = ".png")
    png(temp_img)
    par(oma = rep(0, 4), mar = rep(0, 4), bg = "black")
    graphics::image(1:dim(x)[1], 1:dim(x)[2], x,
                    col = gray(0:64/64), asp = 1,
                    xlab = "", ylab = "", axes = FALSE, 
                    useRaster = T)
    dev.off()
    return(temp_img)
  }
  
  ns <- session$ns
  rv <- reactiveValues(zoom = 1)
  
  observeEvent(im(), {
    im_dim <- dim(im())
    if (length(im_dim) == 3) {
      rv$is_4d <- FALSE
      rv$x_p <- list(lazyr(seq(im_dim[1]), function(x) {img_slice(im()[x,,])}))
      rv$y_p <- list(lazyr(seq(im_dim[2]), function(x) {img_slice(im()[,x,])}))
      rv$z_p <- list(lazyr(seq(im_dim[3]), function(x) {img_slice(im()[,,x])}))
    } else {
      rv$is_4d <- TRUE
      rv$x_p <- lapply(seq(im_dim[4]), function(t) {
        lazyr(seq(im_dim[1]), function(x) {img_slice(im()[x,,,t])})
      })
      rv$y_p <- lapply(seq(im_dim[4]), function(t) {
        lazyr(seq(im_dim[2]), function(x) {img_slice(im()[,x,,t])})
      })
      rv$z_p <- lapply(seq(im_dim[4]), function(t) {
        lazyr(seq(im_dim[3]), function(x) {img_slice(im()[,,x,t])})
      })
    }
  })
  
  time_slot <- reactive({
    if (is.null(input$time_slider)) return(1)
    input$time_slider
  })
  
  output$x_plot <- renderImage({
    req(input$x_slider)
    index_buff <- min(input$x_slider, dim(im())[1])
    if (index_buff > dim(im())[1]) index_buff <- ceiling(dim(im())[1]/2)
    list(
      src = rv$x_p[[time_slot()]][index_buff],
      width = dim(im())[2] * rv$zoom,
      height = dim(im())[3] * rv$zoom
    )
  }, deleteFile = F)
  
  output$y_plot <- renderImage({
    req(input$y_slider)
    index_buff <- input$y_slider
    if (index_buff > dim(im())[2]) index_buff <- ceiling(dim(im())[2]/2)
    list(
      src = rv$y_p[[time_slot()]][index_buff],
      width = dim(im())[1] * rv$zoom,
      height = dim(im())[3] * rv$zoom
    )
  }, deleteFile = F)
  
  output$z_plot <- renderImage({
    req(input$z_slider)
    index_buff <- input$z_slider
    if (index_buff > dim(im())[3]) index_buff <- ceiling(dim(im())[3]/2)
    list(
      src = rv$z_p[[time_slot()]][input$z_slider],
      width = dim(im())[1] * rv$zoom,
      height = dim(im())[2] * rv$zoom
    )
  }, deleteFile = F)
  
  output$x_slider_UI <- renderUI({
    req(im())
    sliderInput(
      ns("x_slider"), label = NULL, min = 1, max = dim(im())[1], step = 1,
      value = ceiling(dim(im())[1] / 2), 
      animate = animationOptions(interval = 100, loop = TRUE)
    )
  })
  
  output$y_slider_UI <- renderUI({
    req(im())
    sliderInput(
      ns("y_slider"), label = NULL, min = 1, max = dim(im())[2], step = 1,
      value = ceiling(dim(im())[2] / 2), 
      animate = animationOptions(interval = 100, loop = TRUE)
    )
  })
  
  output$z_slider_UI <- renderUI({
    req(im())
    sliderInput(
      ns("z_slider"), label = NULL, min = 1, max = dim(im())[3], step = 1,
      value = ceiling(dim(im())[3] / 2), 
      animate = animationOptions(interval = 100, loop = TRUE)
    )
  })
  
  output$time_slider_UI <- renderUI({
    req(im())
    if (length(dim(im())) == 3) return(NULL)
    sliderInput(ns("time_slider"), NULL, min = 1, max = dim(im())[4],
                value = 1, step = 1, 
                animate = animationOptions(interval = 100, loop = TRUE))
  })
  
  observeEvent(input$zoom_p, {
    if (rv$zoom < 1.5) rv$zoom <- rv$zoom + 0.05
  })
  observeEvent(input$zoom_m, {
    if (rv$zoom > 0.5) rv$zoom <- rv$zoom - 0.05
  })
  
  session$onSessionEnded(function() {
    unlink(temp_dir, recursive = T)
  })
}