# DougDoug Skyrim Mods

A reproduction of the various Elder Scrolls: Skyrim mods that [DougDoug](https://www.twitch.tv/dougdougw)
has used in his Twitch streams:

- [Skryim but every hit sends you flying](https://www.youtube.com/watch?v=g1QRpmNoGpo)
- [Skyrim but 10 cheese wheels spawn in every 10 seconds](https://www.youtube.com/watch?v=DjSu5UHOj8M)
- [Skyrim but everything I hit changes to a random creature](https://www.youtube.com/watch?v=BhqCvQawo0A)

## Requirements

- Skyrim **Special Edition** (this has not been tested on Oldrim).
- [**Skyrim Script Extender (SKSE)**](https://skse.silverlock.org/), latest version.

## Download & Install

Download it as a .zip file, then install it like you would for any other mods from sites such as Nexus Mods.
**(Use of a mod manager, such as [Mod Organizer 2](https://www.nexusmods.com/skyrimspecialedition/mods/6194),**
**is highly recommended.)**

(This mod is currently not published to other sites.)

## Usage

After installing the mod, you will find three spell tomes in your inventory:

- _Dovah-Claus:_ Spawn copies of a selected object every second;
- [_Icarus' Curses_](https://elderscrolls.fandom.com/wiki/Scroll_of_Icarian_Flight): Anyone hitting anyone else will
cause the target to fly away;
- _Chaos Conjuration_: Anyone hitting anyone else will cause the target to change to a random race or creature.

Each will teach you a spell that when used enables the respective effect for 1 hour.

### Dovah-Claus

> For 3600s, spawn a selected object at a rate of 10 items per second.

To use this spell, find an object you would like to spawn, such as a cheese wheel. Then, cast the spell while targeting
that object with the crosshair in the center of your screen (when the game prompts for interactions such as "pick up").
The object you were targeting will begin spawning in front of you.

The effect will expire in 1 real-life hour. To stop the object from spawning, cast the spell while not targeting any
object. A notification will say "No object selected" and the spawning will stop.

Note that the "object" that you can spawn can be anything that could be interacted with, including food, potions, weapons,
misc. items such as baskets and cups, ingredients, _critters (e.g. insects and flora), animals and creatures, NPCs, and_
_usable furnitures such as chairs, doors, and alchemy tables._

**Multipliers:** The amount of objects spawned each second is affected by perks, potions, clothings, and abilities
targeting your **Illusion** magic, such as dual casting and Fortify Illusion potions, _at the time you cast this spell:_

- For example, with the "Illusion Dual Casting" perk in the skill tree, dual-casting this spell will spawn an object 22
times per second instead of 10 times.
- This is compatible with other mods that modify the magic system, such as the Ordinator.

### Icarus' Curses

> For 3600s, any NPCs/animals/creatures hitting another will push the hit target away with a force proportional to the target's weight.

To use this spell, simply cast it anywhere. The effect will be applied to every NPCs, animals, and creatures in the world
(technically not everyone, see [details](#dynamically-applying-magic-effects) below).

The effect will expire in 1 real-life hour. To cancel it early, wait for at least 24 hours in game.

_Note that this spell works on dead bodies, but not objects, and does not affect fall damage._

**Base power:** Instead of applying the same force to every actors being hit, the script will scale the force
in proportion to the victim's weight. This is so that large "objects" such as Giants and Dwarven Centurions will have approximately
the same initial _acceleration_ as smaller ones such as humans.

**Multipliers:** Additionally, how fast the actor being hit will fly away is affected by the following:

- Perks, potions, clothings, and abilities affecting your **Alteration** magic _at the time you cast this spell._
- How the actor was hit:
    - A power attack using a weapon will multiply the applied force by 2;
    - A bashing attack using a shield will multiply the applied force by 1.5;
    - If the attack victim successfully blocked the attack, the force will be multiplied by 0.8.

### Chaos Conjuration

> For 3600s, any NPCs/animals/creatures hitting another will change the target into a random race/species.

To use this spell, simply cast it anywhere. The effect will be applied to every NPCs, animals, and creatures in the world.

The effect will expire in 1 real-life hour. To cancel it early, wait for at least 24 hours in game.

This spell does not work on dead bodies, nor does it affect fall damage.

**Races/species:** Currently this spell will choose from one of the following races/species:

Argonians, Bears, Bretons, Chaurus Reapers, Chauruses, Chickens, Cows, Dark Elves (Dunmer),
Draugrs, Dwarven Centurions, Dwarven Spheres, Frost Trolls, Giants, Hagravens, High Elves (Altmer),
Horkers, Horses, Ice Wraiths, Khajiits, Mudcrabs, Orcs (Orsimer), Sabre Cats, Skeevers, Skeletons

You can use Creation Kit to add/remove species from the `FormList` object `DWRaceList` to change what can be spawned.

**Maintaining stats/combat states:** When an actor changes race, their health/magicka/stamina will be restored to
the same **percentage** with respect to the new species' maximum stats (as opposed to the same absolute value which was how
Doug implemented it). Additionally, if the actor was in combat before race change, their combat status will be restored as
well.

## Known Issues

**This mod has not been rigorously tested. There is no guarantee that it will work or that it won't break your saves.**

- If you are using the item spawner spell, and your character is running and bumping into the objects that are spawned,
NPCs nearby will yell things like "Be careful!" at you. These are the standard NPC dialog
for when you are knocking over items and cannot be prevented.
- If you spawn objects in a room where taking anything counts as stealing, taking the objects spawned by the spell counts
as stealing too.
- Effects of the fly-away-when-hit spell and the race change spell may remain on some NPCs after the effects have expired
your character.
- When using the fly-away-when-hit spell and the race change spell a second time after the effects from the first use have
expired, the effects may not be applied to some NPCs.
- Some actors cannot be ragdolled by the fly-away-when-hit spell. These include horses (can only be staggered) and very
heavy actors such as mammoths and dragons.

## Implementation Details

### Dynamically applying magic effects

Skyrim does not have the ability to find/track every NPCs in a room/in the world (at least not without additional tools
such as [PapyrusUtil](https://www.nexusmods.com/skyrimspecialedition/mods/13048)). To be able to apply the spells to as
many actors as possible, the _Icarus' Curses_ spell and the _Chaos Conjuration_ spell are designed to self-replicate
like a virus (which may or may not be how Doug's scripts work).

For the most part it follows the "cloak spell" method described in the
[Dynamically Attaching Scripts](https://www.creationkit.com/index.php?title=Dynamically_Attaching_Scripts)
tutorial from the Creation Kit wiki:

1. When your character casts the spell, an invisible cloak is created around your character (using the same mechanism
as the Fire Cloak spell in the game).
2. When another actor (NPC/animal/creature) comes into contact with the cloak, two things happen:
    - A script will run which adds the desired effect (on hit fly away/race change) to the actor;
    - **The same invisible cloak effect from step 1. is added to the actor as well.**
3. This process then repeats whenever any actor comes into contact with any "cloaks" as long as they don't already
have the effect, spreading the effect farther and farther away.
