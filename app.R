rm(list = ls())


####Read in Libraries####
library(shiny)
library(tidyverse)
library(shinythemes)
library(rsconnect)
library(shinyWidgets)
library(lubridate)
library(scales)
library(shinyjs)
library(shinyalert)
library(shiny.i18n)
library(googleLanguageR)
library(here)


####Initialize Translator for Automatic Translation####
i18n <- Translator$new(translation_json_path = here("json", "translation.json"))

##Set default language
i18n$set_translation_language("en")


####Write Decision Tree####
decision_tree <- 
  list(
    list(
      intro = TRUE, 
      content_above_buttons = 
        tags$div(
          tags$p(strong("Welcome to REFORM Alliance's Illinois Early Termination Tool.")), 
          tags$p("This tool is designed to help users navigate the process for early termination of mandatory supervised release or parole in Illinois."), 
          tags$p("This tool can be used by anyone, but is specifically designed to be used by people on mandatory supervised release or parole. To begin using the tool, please click the START button below. The answers that you provide in response to each question will help the tool determine what you are legally entitled to under Illinois law.")
        ), 
      next_question = "initial_question",
      question_id = "intro_page"
    ), 
    list(
      question = 
        tags$div(
          tags$p("Are you currently on mandatory supervised release or parole?")
        ),
      choices = c("Yes", "No"),
      question_id = "initial_question", 
      next_question = list(
        "Yes" = "supervision_length_question",
        "No" = "ineligible_response"
      )
    ), 
    list(
      result = 
        tags$div(
          tags$p("This tool is designed only for those on mandatory supervised release or parole. It is not intended for individuals on probation. Please reach out to an attorney with any questions about issues unrelated to mandatory supervised release or parole.")
        ), 
      question_id = "ineligible_response"
    ),
    list(
      question = 
        tags$div(
          tags$p("Have you been on mandatory supervised release or parole for at least 6 months?")
        ), 
      choices = c("Yes", "No"),
      question_id = "supervision_length_question",
      next_question = list(
        "Yes" = "written_report_question", 
        "No" = "pre-6_month_response"
      )
    ),
    list(
      question = 
        tags$div(
          tags$p("The law requires your supervision officer to review your case for early termination at least once every 6 months. This law is available ",
                 tags$a(href='https://www.ilga.gov/Documents/legislation/ilcs/documents/073000050K3-14-2.htm', target='_blank', class='external-link', "here"), "."),
          tags$p("Your officer must recommend that either your supervision be terminated early or that you continue on mandatory supervised release or parole. They must provide you a written report within 30 days of this recommendation, and if you are not recommended for termination then they must list the steps or requirements you must complete in order to be granted early termination."),
          tags$p("Have you received this report?")
        ),
      choices = c("Yes", "No"),
      question_id = "written_report_question",
      next_question = list(
        "Yes" = "early_termination_question", 
        "No" = "early_termination_result_1"
      )
    ),
    list(
      result = 
        tags$div(
          tags$p("Illinois law allows the Prisoner Review Board to terminate a period of mandatory supervised release or parole at any time. (Please see the relevant section of law ", 
                 tags$a(href='https://www.ilga.gov/Documents/legislation/ilcs/documents/073000050K3-3-8.htm', target='_blank', class='external-link', "here"), ".) ",
                 "Illinois law also requires the Prisoner Review Board to review people on mandatory supervised release or parole for early termination every 6 months. It is unlikely that the Prisoner Review Board will grant early termination until you have served at least 6 months of supervision, but you should contact your attorney to discuss your options.")
        ),
      question_id = "pre-6_month_response"
    ),
    list(
      result = 
        tags$div(
          tags$p("Your supervision officer is legally required to review you for early termination at least once every 6 months and provide you with a report on this review within 30 days. This law is available ",
                 tags$a(href='https://www.ilga.gov/Documents/legislation/ilcs/documents/073000050K3-14-2.htm', target='_blank', class='external-link', "here"), ". ", 
                 "If they have not done so, please talk to your lawyer or your supervision officer immediately to address this.")
        ),
      question_id = "early_termination_result_1"
    ),
    list(
      question = 
        tags$div(
          tags$p("Did this report recommend early termination?")
        ),
      choices = c("Yes", "No"),
      question_id = "early_termination_question", 
      next_question = list(
        "Yes" = "board_approval_question", 
        "No" = "steps_and_requirements_question"
      )
    ),
    list(
      question = 
        tags$div(
          tags$p("Your officer is required to provide you a list of steps or requirements that must be completed in order to be granted early termination. Have you completed those steps or requirements?")
        ),
      choices = c("Yes", "No"),
      question_id = "steps_and_requirements_question", 
      next_question = list(
        "Yes" = "board_approval_question2", 
        "No" = "steps_and_requirements_result"
      )
    ),
    list(
      question = 
        tags$div(
          tags$p("Regardless of what your officer recommends, the decision to grant or deny early termination is made by the Prisoner Review Board. Did the Board approve your supervision officer’s recommendation to terminate your supervision early?")
        ),
      choices = c("Yes", "No"),
      question_id = "board_approval_question",
      next_question = list(
        "Yes" = "successful_early_termination_result", 
        "No" = "steps_and_requirements_question2"
      )
    ),
    list(
      question = 
        tags$div(
          tags$p("The Prisoner Review Board is required to provide you a list of steps or requirements that must be completed in order to be granted early termination. Have you completed those steps or requirements?")
        ),
      choices = c("Yes", "No"),
      question_id = "steps_and_requirements_question2",
      next_question = list(
        "Yes" = "board_approval_question2", 
        "No" = "steps_and_requirements_result"
      )
    ),
    list(
      question = 
        tags$div(
          tags$p("You are permitted to apply for early termination once you have completed the steps or requirements assigned to you. You must apply to the Prisoner Review Board which has the final authority to approve or deny early termination. They are required to review your application and make a determination within 30 days."),
          tags$p("Did the Board approve your request for early termination?")
        ),
      choices = c("Yes", "No"),
      question_id = "board_approval_question2",
      next_question = list(
        "Yes" = "successful_early_termination_result", 
        "No" = "steps_and_requirements_question2"
      )
    ),
    list(
      result = 
        tags$div(
          tags$p("Legally, the Prisoner Review Board has the discretion to terminate your probation early at any time. However, it is very unlikely that they would do so until you complete the steps or requirements you were given. Please consult your attorney or your supervision officer with any questions about your options.")
        ),
      question_id = "steps_and_requirements_result"
    ),
    list(
      result = 
        tags$div(
          tags$p("Congratulations, your supervision has been terminated early!")
        ),
      question_id = "successful_early_termination_result"
    )
  )
  
  
####Create App####
ui <- fluidPage(
  usei18n(i18n),
  # title = uiOutput("app_title"),
  title = "Illinois Early Termination Tool",
  useShinyjs(),
  theme = shinytheme("flatly"),
  tags$head(
    tags$style(HTML(
      "
      .question-text{ font-size: 20px; margin-bottom: 30px; margin-top: 30px}
      .result-text{ font-size: 20px; font-weight: bold; color: #28a745; margin-top: 20px; }
      .shiny-input-container{ margin-bottom: 10px; }
      .btn-container{ margin-top: 20px; }
      .logo-container{ text-align: center; margin-bottom: 40px; margin-top: 10px;}
      .logo{ max-width: 200px; height: auto; }
      
      .language-picker-container {
        min-height: 90px;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
      }
      .language-picker-container .bootstrap-select .dropdown-toggle {
        white-space: nowrap;
        min-height: 34px;
      }
      /* Custom button styling */
      #violation-buttons .btn{
        margin-right: 10px;
        margin-bottom: 10px; /* Add bottom margin for spacing */
        border: 1px solid #ccc;
        padding: 10px 15px;
        font-size: 16px;
        min-width: 200px; /* Adjust as needed */
        text-align: center;
      }
      #violation-buttons .btn.active{
        border-color: #007bff;
        box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
      }
      #violation-buttons .btn-danger{
        background-color: #dc3545;
        color: white;
      }
      #violation-buttons .btn-success{
        background-color: #28a745;
        color: white;
        min-width: 250px;
        height: 60px;
        padding: 0 20px;     /* Horizontal padding only */
        font-size: 18px;
        line-height: 60px;
        text-align: center;
      }

      #start_button{
        font-size: 24px; /* Increase font size */
        padding: 15px 30px; /* Increase padding */
        min-width: 280px; /* Adjust width as needed */
        height: 70px;    /* Adjust height as needed */
        display: flex;        /* Enable flexbox */
        justify-content: center; /* Center horizontally */
        align-items: center;    /* Center vertically */
      }
      "
    )),
    
    tags$script(HTML("
    $(document).on('click', 'a.external-link', function(e){
      e.preventDefault();
      var $this = $(this);
      var href = $this.attr('href');
      $this.data('href-backup', href); // Backup the href
      Shiny.setInputValue('js_href', href);
    });
    Shiny.addCustomMessageHandler('open_url', function(message){
      window.open(message, '_blank');
      // No need to restore here, navigation happens
    });
    Shiny.addCustomMessageHandler('remove_href', function(href){
      $('a.external-link[data-href-backup=\"' + href + '\"]').each(function(){
        $(this).removeAttr('href'); // Temporarily remove href
      });
    });
    Shiny.addCustomMessageHandler('restore_href', function(href){
      $('a.external-link[data-href-backup=\"' + href + '\"]').each(function(){
        $(this).attr('href', $(this).data('href-backup'));
        $(this).removeData('href-backup');
      });
    });
    ")),
    
    tags$script(HTML("
    Shiny.addCustomMessageHandler('update-title', function(message){
      document.title = message;
    });
    "))
  ),
  
  div(class = "logo-container",
      img(src = "reform-logo-charcoal.png", class = "logo")
  ),
  
  div(strong(uiOutput("main_app_title")),
      style = "font-size: 40px; margin-top: 60px; margin-bottom: 40px; text-align: center;"
  ),
  
  div(
    class = "language-picker-container",
    pickerInput(
      inputId = "selected_language",
      label = "Change Language",
      choices = c("en", "es"),
      selected = i18n$get_translation_language(),
      choicesOpt = list(
        content = c(
          paste0("<i class='flag-icon flag-icon-us'></i> ", i18n$t("English")),
          paste0("<i class='flag-icon flag-icon-es'></i> ", i18n$t("Español"))
        )
      ),
      options = list(
        style = "btn-primary", 
        `live-search` = FALSE, 
        `selected-text-format` = "count > 2", 
        width = "180px"
      )
    )
  ),
  
  uiOutput("quiz_ui"),
  div(class = "btn-container",
      uiOutput("button_ui")
  )
)


####Server####
server <- function(input, output, session){
  i18n_r <- reactive({
    selected <- input$selected_language
    if(length(selected) > 0 && selected %in% i18n$get_languages()){
      i18n$set_translation_language(selected)
    }
    i18n
  })
  
  get_english_key <- function(translated_answer_from_input, current_lang_code){
    if(is.null(translated_answer_from_input) ||
       length(translated_answer_from_input) == 0 ||
       nchar(translated_answer_from_input) == 0){
      return(NULL)
    }
    
    if(current_lang_code == "en"){
      return(translated_answer_from_input)
    }else if(current_lang_code == "es"){
      translation <- 
        as.data.frame(i18n_r()$get_translations()) %>% 
        rownames_to_column("en") %>% 
        filter(es == translated_answer_from_input) %>% 
        pull(en)
      if(length(translation) == 0) return(NULL)
      return(translation[1])
    }
  }
  
  output$app_title <- renderText({
    i18n_r()$t("Illinois Early Termination Tool")
  })
  
  output$main_app_title <- renderText({
    i18n_r()$t("Illinois Early Termination Tool")
  })
  
  history <- reactiveVal(c(1))
  selected_answer <- reactiveVal(NULL)
  answer_selected <- reactiveVal(FALSE)
  stored_answers <- reactiveValues()
  
  observeEvent(input$js_href, {
    href <- input$js_href
    
    shinyalert(
      title = i18n_r()$t("Leaving Application"),
      text = i18n_r()$t("This will take you to a new website."),
      type = "info",
      showCancelButton = TRUE,
      confirmButtonText = i18n_r()$t("Continue"),
      callbackR = function(x){
        if(isTRUE(x)){
          session$sendCustomMessage("open_url", href)
          session$sendCustomMessage("remove_href", href)
        }else{
          session$sendCustomMessage("restore_href", href)
        }
      }
    )
  }, ignoreInit = TRUE)
  
  translate_ui_recursive <- function(element, translator_reactive){
    
    if(is.character(element)){
      return(translator_reactive()$t(element))
    }
    
    if(inherits(element, "shiny.tag") || inherits(element, "htmltools.tag")){
      
      if(!is.null(element$children)){
        element$children <- lapply(
          element$children,
          function(child){
            translate_ui_recursive(child, translator_reactive)
          }
        )
      }
      
      return(element)
    }
    
    if(is.list(element)){
      return(
        lapply(
          element,
          function(child){
            translate_ui_recursive(child, translator_reactive)
          }
        )
      )
    }
    
    return(element)
  }
  
  ##Quiz UI
  output$quiz_ui <- renderUI({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    if(length(current_question$intro) > 0){
      tagList(
        translate_ui_recursive(current_question$content_above_buttons, i18n_r),
        uiOutput("intro_buttons"),
        translate_ui_recursive(current_question$content_below_buttons, i18n_r)
      )
    }else if("question" %in% names(current_question) &&
             length(current_question$question_list) == 0){
      tagList(
        translate_ui_recursive(current_question$question, i18n_r),
        if("choices" %in% names(current_question) &&
           length(current_question$choices) > 0){
          stored <- isolate(stored_answers[[current_question$question_id]])
          radioButtons("answer", NULL,
                       selected = if(!is.null(stored)) i18n_r()$t(stored) else character(0),
                       choices = lapply(current_question$choices, function(x) i18n_r()$t(x)))
        }
      )
    }else if("question" %in% names(current_question) &&
             length(current_question$question_list) > 0){
      tagList(
        translate_ui_recursive(current_question$question, i18n_r),
        current_question %>%
          pluck("question_list") %>%
          enframe() %>%
          pmap(
            ~tagList(
              div(tags$div(tags$p(translate_ui_recursive(.y, i18n_r)))), 
              radioButtons(
                inputId = paste0("answer_", .x),
                selected = {
                  stored <- isolate(stored_answers[[paste0(current_question$question_id, "___answer_", .x)]])
                  if(!is.null(stored)) i18n_r()$t(stored) else character(0)
                },
                label = NULL,
                choices = lapply(c("Yes", "No"), function(x) i18n_r()$t(x)) 
              )
            )
          ),
        if(!is.null(current_question$note_text)){
          translate_ui_recursive(current_question$note_text, i18n_r)
        }
      )
    }else if("result" %in% names(current_question)){
      translate_ui_recursive(current_question$result, i18n_r)
    }
  })
  
  output$intro_buttons <- renderUI({
    div(
      actionButton("start_button", i18n_r()$t("Start"), class = "btn btn-success")
    )
  })
  
  output$button_ui <- renderUI({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    buttons <- list()
    
    if(current_question$question_id == "resource_question"){
      buttons <- list(actionButton("back_button", i18n_r()$t("Go Back to Previous Question"), class = "btn btn-warning"))
    }else{
      if(length(history()) > 1 & current_question$question_id != "intro_page"){
        buttons <- append(buttons, list(actionButton("back_button", i18n_r()$t("Back"), class = "btn btn-warning")))
      }
      
      if(current_question$question_id == "finished_page"){
        buttons <- append(buttons, list(actionButton("start_over_button", i18n_r()$t("Start Over"), class = "btn btn-success")))
      }else if(is.null(current_question$next_question)){
        # buttons <- append(buttons, list(actionButton("finish_button", i18n_r()$t("Finish"), class = "btn btn-danger")))
        buttons <- append(buttons, list(actionButton("start_over_button", i18n_r()$t("Start Over"), class = "btn btn-success")))
      }else if(length(current_question$intro) == 0){
        buttons <- append(buttons, list(actionButton("next_button", i18n_r()$t("Next"), class = "btn btn-primary")))
      }
    }
    
    do.call(fluidRow, buttons)
  })
  
  observeEvent(input$answer, {
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    # list-style questions are handled by the observe() in FIX 4
    req(length(current_question$question_list) == 0,
        "choices" %in% names(current_question))
    
    english_key <- get_english_key(input$answer, input$selected_language)
    
    # only accept answers that are actually a route out of this question
    if(!is.null(english_key) && english_key %in% names(current_question$next_question)){
      answer_selected(TRUE)
      selected_answer(english_key)
      stored_answers[[current_question$question_id]] <- english_key
    }else{
      answer_selected(FALSE)
      selected_answer(NULL)
    }
  })
  observe({
    answer_selected_val = answer_selected()
    if(!is.null(answer_selected_val) & answer_selected_val == TRUE){
      shinyjs::enable("next_button")
    }else{
      shinyjs::disable("next_button")
    }
  })
  
  observe({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    req(length(current_question$question_list) > 0)
    
    current_lang_code <- input$selected_language
    answer_ids <- paste0("answer_", names(current_question$question_list))
    
    # "Yes"/"No" in English, or NULL if unanswered / not a recognised answer
    get_yes_no <- function(id){
      val <- get_english_key(input[[id]], current_lang_code)
      if(length(val) == 1 && val %in% c("Yes", "No")) val else NULL
    }
    
    responses <- lapply(answer_ids, get_yes_no)
    names(responses) <- answer_ids
    
    # remember what has been answered so far (restored if the person goes Back)
    for(id in answer_ids){
      if(!is.null(responses[[id]])){
        stored_answers[[paste0(current_question$question_id, "___", id)]] <- responses[[id]]
      }
    }
    
    if(any(vapply(responses, is.null, logical(1)))){
      # not every sub-question answered yet
      answer_selected(FALSE)
      selected_answer(NULL)
    }else{
      responses <- unlist(responses)
      answer_selected(TRUE)
      
      selected_answer(if("Yes" %in% responses) "Yes" else "No")
    }
  })
  
  observeEvent(input$go_to_resource, {
    resource_index <- which(map_chr(decision_tree, "question_id") == "resource_question")
    history(c(history(), resource_index))
  })
  
  observeEvent(input$start_button, {
    current_question <- decision_tree[[1]]
    next_id <- current_question$next_question
    next_index <- which(map_chr(decision_tree, "question_id") == next_id)
    history(c(history(), next_index))
  })
  
  observeEvent(input$next_button, {
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    answer_selected_val <- answer_selected()
    if(answer_selected_val == FALSE && !("result" %in% names(current_question)) && !(length(current_question$next_question) == 1 && !("choices" %in% names(current_question)))){
      shinyalert(
        title = i18n_r()$t("Missing answer"),
        text = i18n_r()$t("Please select an answer before clicking Next"),
        type = "warning"
      )
      return()
    }
    
    if("choices" %in% names(current_question)){
      req(selected_answer())
      next_id <- current_question$next_question[[selected_answer()]]
    }else{
      next_id <- current_question$next_question
    }
    
    req(next_id)
    
    next_index <- which(map_chr(decision_tree, "question_id") == next_id)
    history(c(history(), next_index))
    answer_selected(FALSE) 
    selected_answer(NULL) 
  })
  
  observeEvent(input$back_button, {
    answer_selected(FALSE)
    selected_answer(NULL)
    if(length(history()) > 1){
      history(history()[1:(length(history()) - 1)])
      answer_selected(FALSE)
      selected_answer(NULL)
    }
  })
  
  observeEvent(input$start_over_button, {
    history(c(1))
    answer_selected(FALSE)
    selected_answer(NULL)
    for(nm in names(reactiveValuesToList(stored_answers))){
      stored_answers[[nm]] <- NULL
    }
  })
  
  # observeEvent(input$finish_button, {
  #   finished_page_index <- which(map_chr(decision_tree, "question_id") == "finished_page")
  #   history(c(history(), finished_page_index))
  # })
  
  observeEvent(input$selected_language, {
    current_i18n <- i18n_r()
    
    updatePickerInput(
      session,
      inputId = "selected_language",
      label = current_i18n$t("Change Language"),
      choices = c("en", "es"),
      selected = input$selected_language,
      choicesOpt = list(
        content = c(
          paste0("<i class='flag-icon flag-icon-us'></i> ", current_i18n$t("English")),
          paste0("<i class='flag-icon flag-icon-es'></i> ", current_i18n$t("Español"))
        )
      )
    )
  }, ignoreInit = FALSE)
}

##Deploy App
shinyApp(ui = ui, server = server)




  
  
 