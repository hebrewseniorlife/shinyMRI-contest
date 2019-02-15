image_render <- function(x, h, v) {
  par(oma = rep(0, 4), mar = rep(0, 4), bg = "black")
  graphics::image(1:dim(x)[1], 1:dim(x)[2], x,
                  col = gray(0:64/64), asp = 1,
                  xlab = "", ylab = "", axes = FALSE, 
                  useRaster = T)
  abline(h = h, v = v, col = "red")
}

raster3d_interactive_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(4, offset = 8, uiOutput(ns("time_slider_UI")))
    ),
    fluidRow(
      lapply(c("x", "y", "z"), function(x) {
        column(4, align = "center", uiOutput(ns(paste0(x, "_slider_UI"))))
      })
    ),
    fluidRow(
      lapply(c("x_plot", "y_plot", "z_plot"), function(x) {
        column(4, align = "center", 
               plotOutput(ns(x), click = ns(paste0(x, "_click"))))
      })
    )
  )
}

raster3d_interactive_Module <- function(input, output, session, im) {
  ns <- session$ns
  
  time_im <- reactive({
    req(im())
    if (length(dim(im())) == 3) return(im())
    return(im()[,,, input$time_slider])
  })
  
  output$x_plot <- renderPlot({
    req(im())
    image_render(time_im()[input$x_slider,,], input$z_slider, input$y_slider)
  })
  
  output$y_plot <- renderPlot({
    req(im())
    image_render(time_im()[, input$y_slider, ], input$z_slider, input$x_slider)
  })
  
  output$z_plot <- renderPlot({
    req(im())
    image_render(time_im()[,, input$z_slider], input$y_slider, input$x_slider)
  })
  
  output$x_slider_UI <- renderUI({
    req(im())
    sliderInput(
      ns("x_slider"), label = NULL, min = 1, max = dim(im())[1],
      value = ceiling(dim(im())[1] / 2)
    )
  })
  
  output$y_slider_UI <- renderUI({
    req(im())
    sliderInput(
      ns("y_slider"), label = NULL, min = 1, max = dim(im())[2],
      value = ceiling(dim(im())[2] / 2)
    )
  })
  
  output$z_slider_UI <- renderUI({
    req(im())
    sliderInput(
      ns("z_slider"), label = NULL, min = 1, max = dim(im())[3],
      value = ceiling(dim(im())[3] / 2)
    )
  })
  
  output$time_slider_UI <- renderUI({
    req(im())
    if (length(dim(im())) == 3) return(NULL)
    sliderInput(ns("time_slider"), label = "Time", min = 1, max = dim(im())[4],
                value = 1, step = 1)
  })
  
  observeEvent(input$y_plot_click, {
    updateSliderInput(session = session, "x_slider",
                      value = input$y_plot_click$x)
    updateSliderInput(session = session, "z_slider",
                      value = input$y_plot_click$y)
  })
  
  observeEvent(input$x_plot_click, {
    updateSliderInput(session = session, "y_slider",
                      value = input$x_plot_click$x)
    updateSliderInput(session = session, "z_slider",
                      value = input$x_plot_click$y)
  })
  
  observeEvent(input$z_plot_click, {
    updateSliderInput(session = session, "x_slider",
                      value = input$z_plot_click$x)
    updateSliderInput(session = session, "y_slider",
                      value = input$z_plot_click$y)
  })
}