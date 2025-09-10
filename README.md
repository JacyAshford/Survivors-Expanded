# Survivors-Expanded
This is a repo for the Godot game tutorial from "Your First 2D GAME From Zero in Godot 4 **Vampire Survivor Style**" by GDScript at this link: https://www.youtube.com/watch?v=GwCiGixlqiU&t=164s

The tutorial took me a little over 4 hours to complete and the expansions took about 3-4 hours to complete. The final expansion is unfinished, but considering I already went way over my 6 hours alloted time to spend on this first project I decided I would leave it as is and just write about the successes and failures I met along the way. 

I made 3 expansions on the tutorial game: 
  1. I modified the environment spawning so that the trees would spawn randomly following a similar path to the enemies. This change was necessary because without it, the developer would need to hand place each individual environmental spite. No thanks.
  2. I realized that the game needed a pause state, so I added a pause screen and a signal that would toggle the pause state on/off when the player pressed the space bar
  3. I wanted to allow the player to level up, so I created a level-up condition where the player would need to kill 10 slimes to gain enough XP to level up. I created a signal from the slimes script that would tell the player script when a slime had died, and I create a label that would appear when the player leveled up. Somewhere along the way the level up feature is not registering and the label is not appearing, I unfortunately ran out of time to debug this.

I also want to add a few more things in the future: 
-player follower/helper (good-guy version of the slimes that eats enemy slimes)
-updated UI, environment, player assets
-upgrade player weapons upon successful level up
-increase enemy difficulty upon successful level up

overall, I feel like I did as much as I could within the 6 hours timeblock. I really enjoyed following this tutorial and I think it was very helpful. I would like to check out more resources from GDScript in the future when I make some further updates to this game or create a new game. 
