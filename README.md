# Clean Up - WoW 1.12 addOn 

This addOn automatically stacks and sorts your items.

![Alt text](http://i.imgur.com/DZgQPaa.png)

[Video demonstration](https://www.youtube.com/watch?v=DGjBcyg4cys) (The minimap button is from an older version)

### Commands
**/cleanupreverse** (Makes the sorting start at the top of your bags instead of the bottom)<br/>
**/cleanupbags** (starts button placement mode)<br/>
**/cleanupbank** (starts button placement mode)

#### Button placement mode
Use the mouse wheel to iterate through the visible frames to choose a parent for the button.
When holding down ctrl the mouse wheel will resize the button instead.
Finally click to place the button.

### Sort order

The highest priority are the custom assignments. The second highest is to fill special bags (e.g., herb bag).

Besides that, the primary sort order is:

**hearthstone**<br/>
**mounts**<br/>
**special items** (items of arbitrary categories that tend to be kept for a long time for some reason. e.g., cosmetic items like dartol's rod, items that give you some ability like cenarion beacon)<br/>
**key items** (keys that aren't actual keys. e.g., mara scepter, zf hammer, ubrs key)<br/>
**tools**<br/>
**other soulbound items**<br/>
**reagents**<br/>
**consumables**<br/>
**quest items**<br/>
**high quality items** (which aren't in any other category)<br/>
**common quality items** (which aren't in any other category)<br/>
**junk**<br/>
**conjured items**

The basic intuition for the primary sort order is how long items are expected to be kept around. The more "permanent" an item is the lower it is placed in your bags.

Within the primary groups items are further sorted by **itemclass**, **itemequiploc**, **itemsubclass**, **itemname** and **stacksize/charges** in this order of priority.
