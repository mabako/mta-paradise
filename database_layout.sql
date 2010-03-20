CREATE TABLE  `characters` (
  `characterID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `characterName` varchar(22) NOT NULL,
  `userID` int(10) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `interior` int(10) unsigned NOT NULL,
  `dimension` int(10) unsigned NOT NULL,
  `skin` int(10) unsigned NOT NULL,
  `rotation` int(10) unsigned NOT NULL,
  `health` tinyint(3) unsigned NOT NULL DEFAULT '100',
  `armor` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`characterID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE  `wcf1_user` (
  `userID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(40) NOT NULL,
  `salt` varchar(40) NOT NULL,
  `banned` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `activationCode` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`userID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;