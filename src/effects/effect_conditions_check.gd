extends Node
""" 
This is going to be where I check should an effect actually run.
At this point we have indentified that the event the card is listning for has been triggred.

So here we need to check are the condtitions to run this condition met, 
e.g. plus 1 attack if a woods card is on the board, well, is there even a woods card on the board ?
because if not we dont run this.

the issue is this needs to be a common class, ideally i could use items from the json to check this 
but I'll have to see checks might have to be done within the effects due to the nature of them

Also what about the is valid check and is there away to check howmany times the same effect on the same card has ran.
"""
