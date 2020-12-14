```{r}
library (rtweet)
library (tidyverse)
library (lubridate)
library (gt)
library (skimr)
library (ggmap)
library (maps)
```


```{r}
get_token()

twitter_user <- "@nationaltrust"
tweets_raw <- get_timeline (twitter_user, n = 5000)
```


```{r}

tweets <- tweets_raw %>%
  filter (is_retweet == FALSE) %>%
  rename (
    likes = favorite_count,
    retweets = retweet_count,
    created = created_at
  ) %>%
  mutate (
    text = str_sub(text,1,60),
    created = as.Date(created),
    year = year(created)
  ) %>%
  rename(date = created) %>%
  select (text, date, year, likes, retweets)
```
```{r}
tweets %>%
  arrange (-likes, -retweets) %>%
  head (100) %>%
  rowid_to_column("rank") %>%
  select (-year) %>%
  relocate (rank) %>%
  gt () 
```

```{r}
tweets %>%
  arrange (-retweets, -likes) %>%
  head (100) %>%
  rowid_to_column("rank") %>%
  select (rank, text, date, retweets, likes) %>%
  gt ()
```

```{r}
tweets %>%
  group_by (date) %>%
  count () %>%
  ggplot (aes (x = date, y = n)) +
  geom_col () +
  geom_label (aes(label = n)) +
  theme_minimal() +
  labs (x="", y = "Number of tweets")
```

```{r}
followers <- twitter_user %>%
  get_followers() %>%
  head (600) %>%
  pull (user_id) %>%
  lookup_users () %>%
  select (screen_name, name, location, followers_count) %>%
  arrange (-followers_count) %>%
  rowid_to_column("rank")

skim (followers)
```

```{r}
followers %>%
  head (100) %>%
  select (rank, name, location, followers_count) %>%
  gt () %>%
  fmt_number (columns = vars(followers_count), use_seps = T, decimals = 0)
```