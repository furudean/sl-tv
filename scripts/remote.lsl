integer CHANNEL = -333;
string PROMPT = "\nenter youtube/soundcloud url\n\n'skip' to skip current video\n'pause' to pause playback\n'resume' to resume paused playback\n'seek <timestamp>' to seek to timestamp\n'stop' to stop playback\n'sync' to sync all listeners\n";


integer listener;

default {
    touch_end(integer total_number) {
        key user = llDetectedKey(0);

        // clear any previous listener
        llListenRemove(listener);

        // Listen to any reply from that user only, and only on the same channel to be used by llDialog
        // It's best to set up the listener before issuing the dialog
        listener = llListen(-99, "", user, "");

        // send a dialog
        llTextBox(user, PROMPT, -99);

        // start a timer, after which we will stop listening for responses
        llSetTimerEvent(60.0);
    }

    listen(integer chan, string name, key id, string msg) {
        if (msg != "") {
            llSay(CHANNEL, (string)id + "," + msg);
        }
    }

    timer() {
        // Stop listening. It's wise to do this to reduce lag
        llListenRemove(listener);
        // Stop the timer now that its job is done
        llSetTimerEvent(0.0);
    }
}