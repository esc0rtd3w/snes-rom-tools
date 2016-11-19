Blockreator v1.0

How to use:

The design of this program was inspired by Game Maker's object editor.  If you know how to use that, this should be easy enough to figure out as well.

On the far left of the program's main window, select an event to put code into.  For example, if you want something to happen when Mario touches the bottom of your block, select "Mario below".  If you want something to happen when a sprite touches the side of your block, select "Sprite horizontal".  You add codes to as many events as you want by just selecting the event.

On the right, you'll see a list of possible actions.  For example, "Give the player a powerup (with animation)".  If you select an action and press the "Add" button, the action will be added to the list of actions that will execute during the selected event.  Many actions have properties that you can edit.  For example, the "Give Mario a powerup" actions let you select which powerup to give.

Certain actions will only let other actions execute if something is true.  For example, you can make a block that will make Mario fiery if he has a cape.  To do this, you'd use the "If the player has a certain powerup..." action.  Note that "query actions" such as these group all their actions together, and these groups must end with a "group end" action, which is one of the main buttons below Add, Delete, Move up, Move down, and Edit.  It is very important that you do not forget these group ends.  Note that you can use the "otherwise" action to do something if the original query action was false.  For example, "If A, then do this.  Otherwise, do this other thing."  "Otherwise" actions imply a group end action within them, so the action "list" should be "query action", "actions", "otherwise", "actions", "group end".  You can also use the "Or" action to string several query actions together.  For example, if Mario is spin jumping or he is on Yoshi, then do something.  Otherwise, do something else.

Within the action editing window, there will be a series of checkboxes.  What they do is as follows:

	- Relative: If this is checked, instead of assigning a value to something (such as setting Mario's x speed to 5), the value will be added (so you can increase Mario's x speed by 5).

	- Use hex input: If this is checked, the number you input will be treated as a hex value.

	- Not: If this is checked, what is true will become false and vice versa.

	- Is 16-bit: This is used to indicate that this action requires a 16-bit input.  You cannot change its state.

	- Is signed: This is used to indicate whether you can use negative numbers or not.  You cannot change its state.

	- Check variable: The most complicated setting. Normally you'll want to use constant numbers when doing things.  For example, setting Mario's x speed to 5.  But if you select this, then you can use values in RAM.  If you don't know what this means, then you can just ignore it.

Note that sprite actions can only be added if the "Sprite vertical" or "Sprite horizontal" events are selected.

So let's say you wanted to make a conveyor block.  You'd do the following:

1. Select the "Mario above" action.
2. Select the "Set the player's x position to a value." action.
3. Click the "add" button.
4. In the text box, type "1" (without the quotes) to make Mario move to the right, or "-1" to make him move to the left.  Using 2 or -2, 3 or -3, etc. would move him faster.
5. Check the "Relative" box, because we're moving him based on his current position, not to a position in the level.
6. Click OK.
7. Click the "Generate Code" button.  Either copy and paste, or save the file.
8. Insert the block using BTSD.
9. In Lunar Magic, set the "Acts Like" setting to whatever you think will work best.  Note that the block will execute its "Acts Like" code AFTER your code.



NOTE: Certain actions have long internal codes.  If the code within a query action's group is too long, an error may occur during assembly.  Normally, this should not cause issues, however.