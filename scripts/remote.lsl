integer TV_LISTEN_CHANNEL = -1312;

// this is a very simple script that shows a prompt with the features of the
// script, and the textbox sends the message on that channel.

// it is not necessary to use this script to send messages to the TV, you can
// just writing this in the chat is equivalent:
// /-333 https://youtu.be/tN-C8-YZy24

default
{
    state_entry() {
        llSay(0, "pushing to channel " + (string)TV_LISTEN_CHANNEL + " and waiting for touch");
    }

    touch_end(integer total_number)
    {
        key user = llDetectedKey(0);

        string PROMPT = "\nenter youtube/soundcloud url\n\n" +
                        "or one of the following commands\n---\n" +
                        "'playskip <url>' to play without queue\n" +
                        "'np' to show what's on\n" +
                        "'queue' to show what's up next\n" +
                        "'history' to what has played before\n" +
                        "'skip' to skip current playback\n" +
                        "'pause' to pause playback\n" +
                        "'resume' to resume paused playback\n" +
                        "'seek <timestamp>' to seek to timestamp\n" +
                        "'sync' to sync all listeners\n" +
                        "'stop' to stop playback and clear queue\n" +
                        "'info' to show web documentation\n\n";

        llTextBox(user, PROMPT, TV_LISTEN_CHANNEL);
    }
}
