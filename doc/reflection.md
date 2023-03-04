## Milestone 2 Reflection
Our group was able to accomplish all significant components outlined by our proposal and even added some logical extensions to the initial design that felt natural to include during development. We went above and beyond the minimum requirements despite only have 3 group members. Specifically, we implemented 4 distinct reactive visualizations as outlined by our proposal:
1. Category Boxplots
2. Top Channels Bar Chart
3. Popular Tags Bubble Chart
4. Polar Coordinates Bar Chart

Each element has at least one element-specific filter that is unique to that visualization, and we also have a global date range filter that applies across all plots.

We believe this dashboard meets its original purpose of being a useful tool for YouTube content creators to plan their future video projects. In general, our visualizations provide a high-level overview rather than a detailed breakdown of what's trending on YouTube. In the future, it would make sense to add perhaps another page with information on individual trending videos so users could dig deeper after evaluating the global big picture trends.

### Elements we did not implement from the original sketch
1. Bubbles in the bubble chart are not colored by category. This change keeps data processing time low and avoids duplicate bubbles appearing. Users who want to see the bubbles for a specific category can always just filter for it anyway.
2. The polar coordinates chart does not show the counts on mouseover. There is an open issue with the `plotly` ingeration of the `ggplot2` `coord_polar()` function, so it displayed as a regular `ggplot` plot instead.

### Elements we added beyond the scope of the original sketch
1. **Exclude Outliers** toggle option for the boxplots. This helps avoid the issue where one extreme outlier in one category hides the interesting variance across all the other categories.
2. The top channels bar chart is implemented in `plotly` and so the counts are visible when mousing over each bar.
3. Number of tags filter for the bubble chart that the user can adjust.
4. Total counts of videos and channels reported in the leftmost column.
5. **Dark Mode** toggle option added and integrated across all charts.
6. Using `card` elements to contain each plot and enable "Expand" actions on each.

### Current issues we are aware of
1. Dashboard load time is a bit slow; the data set is large so each filter change takes a few second.
2. Dynamic formatting works well on standard screen sizes, but using too small of a window can make some charts illegible.
3. There is no protection against illogical or overly narrow filters. For example, setting start date less than end date will raise errors and require a refresh.
4. With a narrow date range, it is possible to select categories which contain no videos, resulting in errors.
5. The date range filter is currently exclusive, which might be counter-intuitive to users.