# MTA: Paradise
... is a roleplay mode for [Multi Theft Auto: San Andreas](http://mtasa.com).

## Features

### Characters
Everyone can create multiple characters per account, giving you the chances to roleplay different personalities within multiple ethnical groups on the same server and with the same account.

### Chat
There are two kinds of chats available, in character (IC) chat for once based all around the character you are playing. This includes whatever your character says or does (/me), or whatever you need to describe your character's environment (/do). All of in character chat is ranged, opposed to that being out of character chat (OOC). In OOC, it's all about the person behind the screen, not the character you're playing. There's both ranged (/b) and global (/o) chat available, though keep in mind one should keep out of character chat during a roleplay close to the absolute minimum.

### Vehicles
As soon as you've reached a certain amount of wealth, it's possible for you to buy vehicles. These will stay wherever the last occupant left them. Since your vehicle may end up in the water/blown up, there's global vehicle respawns - teleporting them back to the position you used /park at -  once within a while as seemed necessary by the server administration.

### Houses and Business
For a small amount of money it's possible to rent or buy your own houses and business from a variety of interiors, giving you a place to live or work in and do whatever you want.

## Behind the Scenes
### Lua
The mode is completely scripted in Lua, giving everyone the chance to easily adopt and modify parts of it. Of course everyone is welcome to improve MTA: Paradise, and as a good start is to [fork the project](http://github.com/marcusbauer/mta-paradise/fork) at GitHub.

### MySQL
All dynamic data is saved within a MySQL database, this includes characters, vehicles, houses and so on. This database is tied tightly with our forums and although it's possible to run the mode without it, certain features - such as registration - will only be possible over the forums in the current state of development. Retrieved from the database are all admin rights as well, making it possible to use MTA's Access Control List (ACL) in conjunction with our accounts from the database.