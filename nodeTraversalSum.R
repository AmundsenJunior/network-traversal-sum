library(algorithmia)
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(jsonlite))
library(magrittr)

# TODO: make use of multicore processing to traverse network asynchronously
#install.packages('future')
#library(future)
#plan(multiprocess)

# Make request of a url for JSON data
getJSON <- function(url) {
  json <- tryCatch(
    {
      return(fromJSON(url))
    },
    error=function(err) {
      stop(paste0("Attempted to retrieve URL ", url, ", but received ", err), call. = FALSE)
    },
    silent=TRUE
  )    
}

# Create new rows into data frame of latest retrieved JSON
updateDataFrame <- function(df, url, json) {
  reward <- json$reward
  
  if(url %in% df$Url) {
    df$Reward[df$Url == url] <- reward
    df$Traversed[df$Url == url] <- TRUE
  }
  
  newdf <- data.frame(Url=character(), Reward=double(), Traversed=logical(), stringsAsFactors=FALSE)
  
  if(!is.null(json$children)) {
    for(i in 1:length(json$children)) {
      child <- json$children[i]
      if(!child %in% df$Url) {
        newrow <- data.frame(Url=child, Reward=0, Traversed=FALSE, stringsAsFactors=FALSE)
        newdf <- rbind(newdf, newrow)
      }
    }
  }
  df <- appendDataFrame(df, newdf)
  
  return(df)
}

# Add new rows of newdf into existing df
appendDataFrame <- function(df, newdf) {
  return(
    newdf %>%
      distinct(Url, .keep_all = TRUE) %>%
      bind_rows(df, .)
  )
}

# Recursively traverse network for all nodes from input starting point
traverseNetwork <- function(input, nodes) {
  json <- getJSON(input)
  nodes <- updateDataFrame(nodes, input, json)
 
  untraversed <- nodes[which(nodes$Traversed == FALSE), ]
  
  if(nrow(untraversed) > 0) {
    nodes <- traverseNetwork(untraversed$Url[1], nodes)
  } 
  return(nodes)
}

# Algorithm for traversing and summing the rewards of the algo.work/interview network
# Each node provides JSON responses of type {children[], reward}, with expectation of nulls
algorithm <- function(input) {
  json <- getJSON(input)
  
  nodes <- data.frame(Url=input, Reward=json$reward, Traversed=FALSE, stringsAsFactors=FALSE)
  nodes <- traverseNetwork(input, nodes)    
  
  return(sum(nodes$Reward))
}
