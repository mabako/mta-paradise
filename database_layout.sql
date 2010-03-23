-- Copyright (c) 2010 MTA: Paradise
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

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
  `rotation` float NOT NULL,
  `health` tinyint(3) unsigned NOT NULL DEFAULT '100',
  `armor` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`characterID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE  `interiors` (
  `interiorID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `outsideX` float NOT NULL,
  `outsideY` float NOT NULL,
  `outsideZ` float NOT NULL,
  `outsideInterior` int(10) unsigned NOT NULL,
  `outsideDimension` int(10) unsigned NOT NULL,
  `insideX` float NOT NULL,
  `insideY` float NOT NULL,
  `insideZ` float NOT NULL,
  `insideInterior` int(10) unsigned NOT NULL,
  `interiorName` varchar(255) NOT NULL,
  PRIMARY KEY (`interiorID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE  `wcf1_user` (
  `userID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(40) NOT NULL,
  `salt` varchar(40) NOT NULL,
  `banned` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `activationCode` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`userID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `wcf1_group` (
 `groupID` int(10) unsigned NOT NULL auto_increment,
 `groupName` varchar(255) NOT NULL default '',
 PRIMARY KEY  (`groupID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
INSERT INTO `wcf1_group` (`groupID`, `groupName`) VALUES (1, 'MTA Administrators');

CREATE TABLE `wcf1_user_to_groups` (
 `userID` int(10) unsigned NOT NULL default '0',
 `groupID` int(10) unsigned NOT NULL default '0',
 PRIMARY KEY  (`userID`,`groupID`),
 KEY `groupID` (`groupID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO `wcf1_user_to_groups` (`userID`, `groupID`) VALUES (1, 1); -- first user is admin

CREATE TABLE  `vehicles` (
  `vehicleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `model` int(10) unsigned NOT NULL,
  `posX` float NOT NULL,
  `posY` float NOT NULL,
  `posZ` float NOT NULL,
  `rotX` float NOT NULL,
  `rotY` float NOT NULL,
  `rotZ` float NOT NULL,
  `interior` int(10) unsigned NOT NULL DEFAULT '0',
  `dimension` int(10) unsigned NOT NULL DEFAULT '0',
  `respawnPosX` float NOT NULL,
  `respawnPosY` float NOT NULL,
  `respawnPosZ` float NOT NULL,
  `respawnRotX` float NOT NULL,
  `respawnRotY` float NOT NULL,
  `respawnRotZ` float NOT NULL,
  `respawnInterior` int(10) unsigned NOT NULL DEFAULT '0',
  `respawnDimension` int(10) unsigned NOT NULL DEFAULT '0',
  `numberplate` varchar(8) NOT NULL,
  `health` int(10) unsigned NOT NULL DEFAULT '1000',
  `color1` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `color2` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `characterID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`vehicleID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;