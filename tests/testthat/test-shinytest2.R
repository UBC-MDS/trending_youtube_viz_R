library(shinytest2)

test_that("{shinytest2} recording: all_widgets", {
  app <- AppDriver$new(variant = platform_variant(), name = "all_widgets", height = 990, 
      width = 1409, load_timeout = 8e+05)
  app$set_inputs(daterange = c("2020-08-12", "2020-08-29"))
  app$set_inputs(boxplotdist = "view_count")
  app$set_inputs(rm_outliers = TRUE)
  app$set_inputs(barplotcat = "Education")
  app$set_inputs(bubbleCats = c("Autos & Vehicles", "Comedy", "Education", "Entertainment", 
      "Gaming", "Howto & Style", "Music", "News & Politics", "Nonprofits & Activism", 
      "People & Blogs", "Pets & Animals", "Science & Technology", "Sports", "Travel & Events"))
  app$set_inputs(bubbleCats = c("Autos & Vehicles", "Comedy", "Education", "Entertainment", 
      "Gaming", "Howto & Style", "Music", "News & Politics", "Nonprofits & Activism", 
      "Pets & Animals", "Science & Technology", "Sports", "Travel & Events"))
  app$set_inputs(bubbleCats = c("Autos & Vehicles", "Comedy", "Education", "Entertainment", 
      "Gaming", "Howto & Style", "News & Politics", "Nonprofits & Activism", "Pets & Animals", 
      "Science & Technology", "Sports", "Travel & Events"))
  app$set_inputs(bubbleCats = c("Autos & Vehicles", "Education", "Entertainment", 
      "Gaming", "Howto & Style", "News & Politics", "Nonprofits & Activism", "Pets & Animals", 
      "Science & Technology", "Sports", "Travel & Events"))
  app$set_inputs(bubbleCats = c("Autos & Vehicles", "Education", "Entertainment", 
      "Gaming", "Howto & Style", "News & Politics", "Nonprofits & Activism", "Pets & Animals", 
      "Science & Technology", "Travel & Events"))
  app$set_inputs(num_tags = 15)
  app$set_inputs(representation_format = "publish_hour")
  app$set_inputs(vid_category = "People & Blogs")
  app$expect_values()
  app$expect_screenshot()
})


test_that("{shinytest2} recording: dark_mode", {
  app <- AppDriver$new(variant = platform_variant(), name = "dark_mode", height = 990, 
      width = 1409, load_timeout = 8e+05)
  app$set_inputs(toggle_theme = TRUE)
  app$set_inputs(representation_format = "publish_hour")
  app$set_inputs(vid_category = "Gaming")
  app$set_inputs(num_tags = 15)
  app$set_inputs(rm_outliers = TRUE)
  app$expect_screenshot(delay = 10)
})


test_that("{shinytest2} recording: error_handling", {
  app <- AppDriver$new(variant = platform_variant(), name = "error_handling", height = 990, 
      width = 1409, load_timeout = 8e+05)
  app$set_inputs(daterange = c("2020-08-12", "2020-08-13"))
  app$set_inputs(barplotcat = "Nonprofits & Activism")
  app$set_inputs(bubbleCats = character(0))
  app$expect_screenshot(delay = 10)
  app$set_inputs(bubbleCats = "Nonprofits & Activism")
  app$set_inputs(vid_category = "Nonprofits & Activism")
  app$expect_screenshot(delay = 10)
})
