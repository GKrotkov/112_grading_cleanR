# 112_grading_cleanR
# Gabriel Krotkov
# 7.9.19

# Functions to take a single 112 grading sheet and clean it to be in standard
# tidy data format.

# Assumptions about input: 
# From a start_row and start_col, I assume the data has this form: 
# section | graded? | question_name [s1] | question_name [s2] |  ... |  Total
#    A    | <score> |    <neg_score>     |     <neg_score>    |  ... | <score>


# Output: data frame of the form:
# section | (optional) version | question_1 | question_2 | ... | total 
# A       |        A/B         |    15      |     14     | ... |  80   
# etc.
# Most importantly: there *cannot* be a numeric variable before 
# the first question variable, and the questions must be uninterrupted!

library(readxl)

# Assumptions: 
#   1) Only 1 left bracket in the input string
#   2) 1 space between left bracket and question title
# Returns a list with two elements
#   1) title = the title of the question
#   2) value = the total credit that could be earned on the question
parse_col_title <- function(title){
  ind_lbracket <- which(strsplit(title, "")[[1]]=="[")
  ind_rbracket <- which(strsplit(title, "")[[1]]=="]")
  offset_ind <- 1 # one space between lbracket and question name
  question_value <- substr(title, ind_lbracket + 1, ind_rbracket - 1)
  question_value <- as.numeric(question_value)
  question_title <- gsub(paste("[", question_value, "]", sep = "")
                         , "", title, 
                         fixed = TRUE) 
  question_title <- trimws(question_title)
  substr(title, 1, ind_lbracket - offset_ind - 1)
  return(list(title = question_title, 
              value = question_value))
}

correct_data_types <- function(data){
  # if NAs are introduced by coercing a column to a numeric, then we know
  # that that column is not actually numeric. If it's not numeric, we
  # assume the column is a factor
  for(i in 1:ncol(data)){
    # attempt to cast the column to a numeric
    attempt <- as.numeric(data[, i][[1]])
    # If it's entirely NAs, call it a factor.
    if(all(is.na((attempt)))){
      data[, i] <- as.factor(data[, i][[1]])
    }
    # Otherwise, we are pretty sure it's a numeric
    else{
      data[, i] <- as.numeric(data[, i][[1]])
    }
  }
  return(data)
}

trim_grades <- function(data, start_row, start_col,
                        ignore_rows, ignore_cols){
  
  if(start_row > 1){
    data <- data[-(1:start_row - 1), ]
  }
  
  if(start_col > 1){
    data <- data[, -(1:start_col - 1)]
  }
  
  # now, remove any ignore rows and cols.
  if(!is.null(ignore_rows)){
    data <- data[-ignore_rows, ]
  }
  if(!is.null(ignore_cols)){
    data <- data[, -ignore_cols]
  }
  
  # move title row up into the actual column titles and remove the row
  names(data) <- data[1, ]
  data <- data[-1, ]
  
  return(data)
}

# inputs: 
#   1) path - the name of the dirty 112 file
#   2) start_row - the row index of the "section" title cell
#   3) start_col - the col index of the "section" title col
#   4) neg_scores - whether the scores are entered as deductions
#   5) ignore_rows - a vector of rows to be ignored - indexing from start_row!
#   6) ignore_cols - a vector of cols to be ignored - indexing from start_col!
# outputs: 
#   1) data - data frame in the correct output format
#   2) questions - questions vector describing the value
#                 of each question and its title

read_grades <- function(path, start_row, start_col, 
                        neg_scores = TRUE, 
                        ignore_rows = NULL, ignore_cols = NULL){
  data <- read_xlsx(path, col_names = FALSE)
  data <- trim_grades(data, start_row, start_col, 
                      ignore_rows, ignore_cols)
  # correct the data types of each column
  data <- correct_data_types(data)
  # find the max nonnumeric index
  offset_ind <- min(which(sapply(data, is.numeric))) - 1
  # ncol(data) - offset - 1 to account for nonnumeric cols and the total
  # questions will be the vector that holds the value of each question
  questions <- rep(0, ncol(data) - offset_ind - 1)
  # Loop through each question and adjust the title and number appropriately
  for(i in (offset_ind + 1):(ncol(data) - 1)){
    parsed <- parse_col_title(names(data)[i])
    names(data)[i] <- parsed$title
    # back-index the questions vector by offset since we start at offset + 1
    questions[i - offset_ind] <- parsed$value
    names(questions)[i - offset_ind] <- parsed$title
    # invert from negative to positive scores if appropriate
    if(neg_scores){
      data[, i] <- questions[i - offset_ind] - data[, i]
    }
  }
  
  return(list(grades = data, 
              questions = questions))
}
