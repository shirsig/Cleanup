# Clean Up - WoW 1.12 addOn 

This addOn automatically stacks and sorts your items.

![Alt text](http://i.imgur.com/DZgQPaa.png)

[Video demonstration](https://www.youtube.com/watch?v=DGjBcyg4cys) (The minimap button is from an older version)

### Commands
**/cleanupreverse** (Makes the sorting start at the top of your bags instead of the bottom)<br/>
**/cleanupbags** (starts button placement mode)<br/>
**/cleanupbank** (starts button placement mode)

#### Button placement mode
**Right-click** to iterate through the frames below the cursor to choose a parent for the button.
**Scroll** to resize the button.
**Left-click** to place the button.

**Alt-left-click** on a bag item will permanently assign its slot to that item.<br/>
**Alt-right-click** on a bag slot will clear its assignment.

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
