# Proposal - Group 20

Lauren Zung, Daniel Cairns, Natalie Cho

## 1. Motivation and Purpose

*Our role*: Social Media Analysts

*Target audience*: YouTube content creators and enthusiasts

Why and how videos go viral on YouTube can seem random and unpredictable. For the growing number of content creators on the platform, understanding what makes a trending video is incredibly valuable. To support these creators, we propose to build a dashboard which highlights key information about trending YouTube videos over time. The social media video sharing platform combines multiple factors in their assessment of the top trending videos each calendar year; they are not just ranking videos based on their total number of views. By analyzing these metrics, creators can better understand trends within their category group(s) and strategically plan how to market and direct their channel accordingly to produce more trending videos.

## 2. Description of the Data

Of the videos that are posted to Youtube, each day Youtube places the most popular videos into its "trending" category. The dataset we will be visualizing is composed of approximately 83400 trending Youtube videos in Canada, with trending dates spanning from August 2020 to November 2021. There are 200 video entries for each calendar date. YouTube [removed the dislike feature](https://github.com/UBC-MDS/trending_youtube_viz_R/pull/5#:~:text=https%3A//variety.com/2022/digital/news/youtube%2Dceo%2Ddefends%2Dhide%2Ddislikes%2D1235162153/) on videos on November 10th 2021, therefore we have only included dates where this information is captured for consistency purposes. Along with the trending date and title of each video (`trending_date, title`), each trending Youtube video has data on the title of the channel that uploaded the video (`channelTitle`), category of video (`categoryId`), time of day it was published (`publishedAt`), tags used (`taglist`), common user interaction statistics (`view_count`, `likes`, `dislikes`, `comment_count`) and other upload options (`comments_disabled`, `ratings_disabled`).

## 3. Research Questions Being Explored

Our project answers the primary research questions:
- What are common themes across trending Youtube videos from each category?
- What were the top channels with the most trending Youtube videos between two dates?
- What are popular tags/upload times for trending Youtube videos?

Larry is a full-time content creator on YouTube. He has had success with some of his videos, but others perform poorly and he's not sure why. To avoid another disappointment, while planning his next video, he visits our "trending youtube videos dashboard" to see what he can learn from recent trending videos on the platform. Specifically, Larry can...

1.  [Choose] a time interval (in days) to report on, from one day to the full extent of the dataset. Perhaps he is interested in creating a video for Valentine's Day, so he looks at the trending videos from February 14th in the previous year.

2.  [Explore] how views, likes, dislikes, and comment counts are distributed across categories for trending videos. He might notice that vlogging videos tend to receive more comments than music videos, and compare whether that pattern is also present in his own videos.

3.  [Visualize] at a glance which tags are popular in trending videos so he can add them to his own videos.

4.  [Identify] channels that produce a large number of trending videos. Suppose Larry visits the top 5 most popular channels and notices they share a particular layout or color scheme, he could choose to update his branding to follow these successful channels.

5.  [Decide] what time of the day and/or day of the week he should publish his videos. Larry can, for example, look at the publish times of trending videos in the music category. If most of the trending videos tend to be published in the evening, he can schedule his next uploads to follow suit.
