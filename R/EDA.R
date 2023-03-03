# Imports
library(tidyverse)
library(lubridate)
library(funModeling)
library(corrplot)

# Loading in the data
setwd("~/dsci_532/trending_youtube_viz_R") # edit this path to wherever you have trending_youtube_viz_R repo
yt_data_ca <- read.csv("data/raw/CAvideos.csv") # raw data has not been uploaded to github to conserve memory
yt_data_ca$trending_date <- ydm(yt_data_ca$trending_date)
yt_data_ca$publish_time <- ymd_hms(yt_data_ca$publish_time)
yt_data_ca$comments_disabled <- as.logical(yt_data_ca$comments_disabled)
yt_data_ca$ratings_disabled <- as.logical(yt_data_ca$ratings_disabled)
yt_data_ca$video_error_or_removed <- as.logical(yt_data_ca$video_error_or_removed)

# Looking at the variable data types
str(yt_data_ca)

# Plotting the numerical variables
# install.packages("funModeling")
plot_num(yt_data_ca)

# Looking at possible correlations
# install.packages("corrplot")
numerical_yt_data <- select_if(yt_data_ca, is.numeric)
corrplot(cor(numerical_yt_data))
