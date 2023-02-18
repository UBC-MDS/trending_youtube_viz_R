# Proposal - Group 20

Lauren Zung, Daniel Cairns, Natalie Cho

## 1. Motivation and Purpose

*Our role*: Social Media Analysts

*Target audience*: YouTube content creators and enthusiasts

Why and how videos go viral on YouTube can seem random and unpredictable. For the growing number of content creators on the platform, understanding what makes a trending video is incredibly valuable. To support these creators, we propose to build a dashboard which highlights key information about trending YouTube videos over time. We hope this app can help users improve their content so it results in more trending videos more often.

## 2. Description of the Data

Of the videos that are posted to Youtube, each day Youtube places the most popular videos into its "trending" category. The dataset we will be visualizing is composed of approximately 40880 trending Youtube videos in Canada, with trending dates spanning from December 2017 to May 2018. Along with the trending date and title of each video (`trending_date, title`), each trending Youtube video has data on the title of the channel that uploaded the video (`channel_title`), category of video (`category_id`), time of day it was published (`publish_time`), tags used (`tags`), common user interaction statistics (`views`, `likes`, `dislikes`, `comment_count`), whether the video got removed (`video_error_or_removed`), the video description (`description`) and other upload options (`comments_disabled`, `ratings_disabled`).

## 3. Research Questions Being Explored

Larry is a full-time content creator on YouTube. He has had success with some of his videos, but others perform poorly and he's not sure why. To avoid another disappointment, while planning his next video, he visits our "trending youtube videos dashboard" to see what he can learn from recent trending videos on the platform. Specifically, Larry can...

1.  [Choose] a time interval (in days) to report on, from one day to the full extent of the dataset. Perhaps he is interested in creating a video for Valentine's Day, so he looks at the trending videos from February 14th in the previous year.

2.  [Explore] how views, likes, dislikes, and comment counts are distributed across categories for trending videos. He might notice that vlogging videos tend to receive more comments than music videos, and compare whether that pattern is also present in his own videos.

3.  [Visualize] at a glance which tags are popular in trending videos so he can add them to his own videos.

4.  [Identify] channels that produce a large number of trending videos. Suppose Larry visits the top 5 most popular channels and notices they share a particular layout or color scheme, he could choose to update his branding to follow these successful channels.
