format_sql_for_r <- function(sql_script, max_lines = 15) {
  # Split into lines and clean
  lines <- unlist(strsplit(sql_script, "\n"))
  lines <- trimws(lines)
  lines <- lines[lines != ""]   # drop blanks
  
  n <- length(lines)
  
  if (n > max_lines) {
    # Break into 15 groups
    group_idx <- ceiling(seq_along(lines) / (n / max_lines))
    lines <- tapply(lines, group_idx, paste, collapse = " ")
  }
  
  # Add formatting (note the extra space before the closing quote)
  formatted <- paste0('"', lines, ' " & _')
  
  # Fix last line (remove & _)
  formatted[length(formatted)] <- sub(' " & _$', ' "', formatted[length(formatted)])
  
  # Return as one string
  paste(formatted, collapse = "\n")
}


sql <- "
paste SQL Code here"


cat(format_sql_for_r(sql))
