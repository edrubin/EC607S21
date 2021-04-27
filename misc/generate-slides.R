#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = T)


# Notes ----------------------------------------------------------------------------------
#   Goal:       Generate final HTML slides and PDF slides (with and without pauses)
#   Argument:   Pass the lecture number (e.g., "02")


# Setup: Find and load file --------------------------------------------------------------
  # Load packages
  library(pacman)
  p_load(stringr, magrittr)
  # Unlist args
  args %<>% unlist()
  # Navigate to the lecture directory
  setwd("../notes-lecture")
  # Find the target lectures' name
  name = dir(pattern = paste0("^", args))
  # Enter the directory
  setwd(name)
  # Load 'here'
  p_load(here)
  # Read in the lecture notes
  rmd_text = name %>% paste0(".Rmd") %>% readLines()
  # Find the beginning of the 'pauses' chunk
  line_pause = rmd_text %>% str_detect("@media print") %>% which() %>% subtract(1)
  # Find the beginning of the 'xaringanExtra' chunk
  line_xe = rmd_text %>% str_detect("xaringan-extra") %>% which()
  

# Step 1: No pauses ----------------------------------------------------------------------
  # Change the line to 'eval = F'
  rmd_text[line_pause] = "```{css, echo = F, eval = F}"
  # Change the xaringanExtra to 'eval = F'
  rmd_text[line_xe] = "```{r, xaringan-extra, include = F, eval = F}"
  # Save the updated RMD document
  con = file(paste0(name, ".Rmd"))
  writeLines(rmd_text, con)
  close(con)
  # Render updated file to HTML
  rmarkdown::render(
    paste0(name, ".Rmd"),
    "xaringan::moon_reader"
  )
  # Render the new HTML to PDF
  pagedown::chrome_print(
    paste0(name, ".html"),
    output = paste0(name, "-nopause.pdf"),
    timeout = 60
  )
  

# Step 2: With pauses --------------------------------------------------------------------
  # Change the line to 'eval = T'
  rmd_text[line_pause] = "```{css, echo = F, eval = T}"
  # Save the updated RMD document
  con = file(paste0(name, ".Rmd"))
  writeLines(rmd_text, con)
  close(con)
  # Render updated file to HTML
  rmarkdown::render(
    paste0(name, ".Rmd"),
    "xaringan::moon_reader"
  )
  # Render the new HTML to PDF
  pagedown::chrome_print(
    paste0(name, ".html"),
    output = paste0(name, ".pdf"),
    timeout = 60
  )
  # Change the xaringanExtra to 'eval = T'
  rmd_text[line_xe] = "```{r, xaringan-extra, include = F, eval = T}"
  # Save the updated RMD document
  con = file(paste0(name, ".Rmd"))
  writeLines(rmd_text, con)
  close(con)
  # Render updated file to HTML
  rmarkdown::render(
    paste0(name, ".Rmd"),
    "xaringan::moon_reader"
  )



# Done.