CREATE TABLE `tweet` (
`tweet_id` MEDIUMINT NOT NULL PRIMARY KEY UNIQUE,
`user_id` TEXT NOT NULL,
`user_screen_name` TEXT NOT NULL,
`text` TEXT NOT NULL,
`tweet_datetime` DATETIME NOT NULL,
`favorite_count` MEDIUMINT,
`retweet_count` MEDIUMINT
) ENGINE=InnoDB;
