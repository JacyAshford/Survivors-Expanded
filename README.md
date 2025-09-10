# Survivors-Expanded
This is a repo for the Godot game tutorial from "Your First 2D GAME From Zero in Godot 4 **Vampire Survivor Style**" by GDScript at this link: https://www.youtube.com/watch?v=GwCiGixlqiU&t=164s

The tutorial took me a little over 4 hours to complete and the expansions took about 3-4 hours to complete. The final expansion is unfinished, but considering I already went way over my 6 hours alloted time to spend on this first project I decided I would leave it as is and just write about the successes and failures I met along the way. 

I made 3 expansions on the tutorial game: 
  1. I modified the environment spawning so that the trees would spawn randomly following a similar path to the enemies. This change was necessary because without it, the developer would need to hand place each individual environmental spite. No thanks.

-This addition took about 30 minutes, I needed to rewatch the section of the tutorial that introduced enemy spawning and then modify/adapt it for the environmental sprites instead
       
  2. I realized that the game needed a pause state, so I added a pause screen and a signal that would toggle the pause state on/off when the player pressed the space bar

-This addition took about 30-45 minutes. I thought I was on the right track by trying to emulate what we did in the tutorial to create the game over screen, but it wasn't quite right. So I researched online and ended up taking a few bits and pieces from this tutorial which finally got it working. Tutorial here: https://www.youtube.com/watch?v=JEQR4ALlwVU&t=166s

  3. I wanted to allow the player to level up, so I created a level-up condition where the player would need to kill 10 slimes to gain enough XP to level up. I created a signal from the slimes script that would tell the player script when a slime had died, and I create a label that would appear when the player leveled up. Somewhere along the way the level up feature is not registering and the label is not appearing, I unfortunately ran out of time to debug this.

-This one definitely took up more time than I anticipated. I probably worked on it for about 2 hours before I decided that I would need further help and more time than I could allot to it at the moment. I tried multiple routes including rewatching some of the tutorial, researching online and asking chat GPT (I'll link that here: https://chatgpt.com/share/68c0fe4d-e854-8001-9805-37fac5c9c5ae), but none of the things I tried quite made sense to me and I think I ended up confusing myself more. I think what I really need is some time away from this project and then to return to it with some fresh ideas, if I continue with this game for future assignments, then this feature is definitely something that I want to get right eventually.



I also want to add a few more things in the future: 
-player follower/helper (good-guy version of the slimes that eats enemy slimes)
-updated UI, environment, player assets
-upgrade player weapons upon successful level up
-increase enemy difficulty upon successful level up

overall, I feel like I did as much as I could within the 6 hours timeblock. I really enjoyed following this tutorial and I think it was very helpful. I would like to check out more resources from GDScript in the future when I make some further updates to this game or create a new game. 
