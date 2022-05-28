CREATE TABLE `users_torrents` (                        
  `uid` int NOT NULL,                                     
  `fid` int NOT NULL,                                     
  `seedtime` bigint NOT NULL DEFAULT '0',                    
  `downloaded` bigint NOT NULL DEFAULT '0',               
  `uploaded` bigint NOT NULL DEFAULT '0', 
  `real_downloaded` bigint NOT NULL DEFAULT '0',               
  `real_uploaded` bigint NOT NULL DEFAULT '0',
  `snatched` int NOT NULL DEFAULT '0',                 
  PRIMARY KEY (`fid`,`uid`) USING BTREE                   
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC

ALTER TABLE `users_torrents` ADD `start_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `snatched`;
ALTER TABLE `users_torrents` ADD `end_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `start_time`;
