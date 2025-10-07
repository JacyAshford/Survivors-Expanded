Survivors-Expanded

This project started with the tutorial Your First 2D GAME From Zero in Godot 4 (Vampire Survivor Style) by GDScript:
https://www.youtube.com/watch?v=GwCiGixlqiU&t=164s

I used the tutorial as a foundation, then expanded the game with new features, systems, and UI. What began as a 6-hour experiment turned into a 35-hour project where I followed the tutorial, debugged and iterated on my own, and implemented new mechanics to see how far I could push the design.

⸻

Features Implemented

Tutorial Foundation
	•	Player movement and shooting system
	•	Enemy AI (slimes that chase the player)
	•	Spawning logic for enemies and the environment
	•	Health bar and game-over screen

Expansions I Added
	1.	Random Environment Spawning
Trees now spawn randomly along paths, similar to enemies. This removed the need to hand-place every tree.
This took about 30 minutes; I adapted the enemy spawning logic for environmental sprites.
	2.	Pause Menu
Added a pause screen UI that toggles on and off with the space bar.
I originally tried reusing the tutorial’s game-over logic, but that didn’t work correctly, so I combined different approaches and tutorials until it worked.
This took about 45 minutes. Reference: https://www.youtube.com/watch?v=JEQR4ALlwVU&t=166s
	3.	Level-Up System
The player now levels up every 10 slime kills. I created signals between the slime script and the player script, added a Level Up label, and wired in a timer so it only appears briefly.
Debugging this took more time than expected. I went through multiple iterations, including research and a ChatGPT session (https://chatgpt.com/share/68c0fe4d-e854-8001-9805-37fac5c9c5ae). After some back and forth, I eventually got it functional, though it wasn’t perfect at first.
	4.	Currency System
Each slime kill awards 10 coins. A coinUI label updates in real time.
	5.	Shop System
A shop UI appears at levels 10, 20, and 40.
I used a CanvasLayer with a background and Sprite2D art, with invisible buttons overlaid on top for interaction.
Purchases cost coins: 75 at level 10, 150 at level 20, and 300 at level 40.
	6.	Weapon Upgrade System
Shop upgrades increase the player’s fire rate. This is handled through signals between the Player, the Gun, and the Timer node that controls bullet firing. Each upgrade makes the weapon noticeably faster.
	7.	Objective System
Added an Objectives UI panel with checkmarks that toggle on when goals are reached:
	•	Kill 10 slimes
	•	Kill 100 slimes
	•	Buy a weapon upgrade
	•	Reach level 100
	8.	Sound Effects Improvements
Death, shop, and game-over sounds now use one-shot audio nodes that detach from the scene and play to completion, even when the game is paused or when the node that triggered the sound is freed.
	9. New environment and level design at level 10
	10. Win condition
	11. Updated UI using Figma. See those images attached here in the SurvivorsUI folder or here at this link: https://www.figma.com/design/2qX3BK6OtABaGCSvqX05ht/gamedev?node-id=0-1&t=hhGW72nyqhIc1nP5-1
	12. Added accessibility features. Users can now toggle global sounds on and off from a settings menu that is featured on the new Start page or on the pause menu.
⸻

Time Spent
	•	Tutorial (core game): ~4 hours
	•	Early expansions (spawning, pause, basic leveling): ~3–4 hours
	•	Debugging level-up and signals: ~6–8 hours
	•	Implementing shop, upgrades, objectives, and polish: ~15+ hours
	•	Level 10 design, environment, objective, win condition: ~6-8 hours
**	•	UI creation in Figma: 2 hours
	•	Accessibility feature planning: 1 hour
	•	Toggle mute setting for accessibility integration: 2-3 hours**
	
Total: ~50 hours

⸻

Future Plans
	•	Add a follower/helper character (a “good slime” that eats enemy slimes)
	•	Improve UI and create custom art for the environment and player
	•	Expand weapon upgrades beyond fire rate (damage, range, etc.)
	•	Scale enemy difficulty more aggressively as the player levels
	•	Add clearer “not enough coins” feedback in the shop
	•	Add more sound and visual polish (pitch variation, feedback animations, etc.)
