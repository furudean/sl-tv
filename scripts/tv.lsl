// sl-tv - audio/video streaming player system for second life
//
// this script is meant to be placed in a prim that will act as a TV screen.
// read the manual at https://tv.himawari.fun for more information on how to use
// this script.
//
// redistribute or whatever. public domain desu
//
// https://tv.himawari.fun
// https://github.com/furudean/sl-tv
//

// CONFIGURATION - change these to suit your needs

integer MEDIA_FACE = 3; // the face we're using for media. this is usually the front face
integer LISTEN_CHANNEL = -1312; // the channel the TV will listen to commands from
string API_BASE_URL = "https://tv.himawari.fun"; // leave this as is, unless you're running your own server
integer INIT_DELAY = -10; // how many seconds to wait on first play before moving to next track
integer HISTORY_MAX = 25; // how many tracks to keep in history
float IDLE_TIMEOUT = 90.0; // how many seconds to wait on queue end before ending media

// END CONFIGURATION

string VERSION = "1.0.0";

// this is a strided list
// [string player_url, string source_url, string title, integer duration, key requested_by, ...]
list queue = [];
list history = []; // same as queue
integer LIST_STRIDE = 5;

integer is_playing = FALSE;
integer playback_seconds = 0;
integer idle_timeout_on_timer = FALSE;

// currently playing
string np_player_url;
string np_source_url;
string np_title;
integer np_duration;
key np_requested_by;

string hyperlink(string text, string url) {
    return "[" + url + " " + text + "]";
}

string user_link(key uuid) {
    return "secondlife:///app/agent/" + (string)uuid + "/about";
}

string fmt_timestamp(integer total_seconds) {
    integer total_minutes = llFloor(total_seconds / 60);

    integer seconds = total_seconds % 60;
    integer minutes = total_minutes % 60;
    integer hours = llFloor(total_minutes / 60);

    string value = "";

    if (hours > 0) value += (string)hours + ":";

    if (hours > 0) value += "0";
    value += (string)minutes + ":";

    if (seconds < 10) value += "0";
    value += (string)seconds;

    return value;
}

integer parse_timestamp(string timestamp) {
    list hh_mm_ss = llParseString2List(timestamp, [":"], []); // ["1", "30", "00"]

    integer offset = llGetListLength(hh_mm_ss) - 3;
    integer hh_o = 0 + offset;
    integer mm_o = 1 + offset;
    integer ss_o = 2 + offset;

    integer hours = 0;
    integer minutes = 0;
    integer seconds = 0;

    if (hh_o > -1) hours = llList2Integer(hh_mm_ss, hh_o);
    if (mm_o > -1) minutes = llList2Integer(hh_mm_ss, mm_o);
    if (ss_o > -1) seconds = llList2Integer(hh_mm_ss, ss_o);

    return (seconds) + (minutes * 60) + (hours * 60 * 60);
}

set_media(string url) {
    list params = [
        PRIM_MEDIA_CURRENT_URL, url,
        PRIM_MEDIA_HOME_URL, url,
        PRIM_MEDIA_AUTO_PLAY, TRUE,
        PRIM_MEDIA_AUTO_SCALE, TRUE,
        PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI,
        PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_NONE,
        PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_ANYONE
    ];

    llSetLinkMedia(LINK_THIS, MEDIA_FACE, params);
}

set_texture(string texture) {
    // [ string texture, vector repeats, vector offsets, float rotation_in_radians ]
    list current = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_TEXTURE, MEDIA_FACE]);

    vector repeats = llList2Vector(current, 1);
    vector offsets = llList2Vector(current, 2);
    float rotation_in_radians = llList2Float(current, 3);

    list params = [
        PRIM_TEXTURE, // what property
        MEDIA_FACE, // what face
        texture, // what texture
        repeats,
        offsets,
        rotation_in_radians
    ];

    llSetLinkPrimitiveParamsFast(LINK_THIS, params);
}

// helper function to display playback history or queue
say_list(key from, list items, string list_name) {
    if (llGetListLength(items) == 0) {
        llRegionSayTo(from, 0, list_name + " is empty");
        return;
    }

    integer total = llGetListLength(items) / LIST_STRIDE;
    string say = "\n" + list_name;

    integer i;
    for (i = 0; i < total; i++) {
        integer offset = i * LIST_STRIDE;
        string source_url = llList2String(items, offset + 1);
        string title = llList2String(items, offset + 2);
        integer duration = llList2Integer(items, offset + 3);
        key requested_by = llList2Key(items, offset + 4);

        say += "\n" + (string)(i + 1) + ". " + hyperlink(title, source_url) + " (" + fmt_timestamp(duration) + ") - added by " + user_link(requested_by);
    }

    llRegionSayTo(from, 0, say);
}

push_history() {
    if (llGetListLength(history) / LIST_STRIDE >= HISTORY_MAX) {
        history = llDeleteSubList(history, 0, LIST_STRIDE - 1);
    }

    history += [np_player_url, np_source_url, np_title, np_duration, np_requested_by];
}

resolve(string query, key from, integer play_skip) {
    // we query an external web server for some meta data
    string request_url = API_BASE_URL + "/resolve?" +
        "q=" + llEscapeURL(query) +
        "&u=" + (string)from +
        "&s=" + (string)play_skip;

    // the response is picked up in the http_response handler below
    llHTTPRequest(request_url, [], "");
}

next(integer first) {
    if (np_player_url != "") {
        push_history();
    }

    if (llGetListLength(queue) == 0) {
        llSay(0, "reached end of queue");
        set_idle_timeout(IDLE_TIMEOUT);

        return;
    }

    idle_timeout_on_timer = FALSE;
    is_playing = TRUE;
    playback_seconds = 0;

    // queue is a strided list
    np_player_url = llList2String(queue, 0);
    np_source_url = llList2String(queue, 1);
    np_title = llList2String(queue, 2);
    np_duration = llList2Integer(queue, 3);
    np_requested_by = llList2Key(queue, 4);

    // pop the queue
    queue = llDeleteSubList(queue, 0, LIST_STRIDE - 1);

    set_media(API_BASE_URL + np_player_url);
    set_texture("on");

    if (first) {
        llSay(0, "▶ " + user_link(np_requested_by) + " started playing️ \"" + hyperlink(np_title, np_source_url) + "\" (" + fmt_timestamp(np_duration) + ") ");
        playback_seconds = INIT_DELAY;
    } else {
        llSay(0, "▶ now playing " + hyperlink(np_title, np_source_url) + " (" + fmt_timestamp(np_duration) + ") ");
    }

    llSetTimerEvent(1.0);
}

stop() {
    is_playing = FALSE;
    queue = [];
    np_player_url = "";
    np_source_url = "";
    np_title = "";
    np_duration = 0;
    np_requested_by = NULL_KEY;
    idle_timeout_on_timer = FALSE;

    llSetTimerEvent(0.0);
    llClearLinkMedia(LINK_THIS, MEDIA_FACE);
    set_texture("off");
}

pause() {
    is_playing = FALSE;

    set_media(API_BASE_URL + np_player_url + "/paused");
    set_texture("on");

    set_idle_timeout(3600.0);
}

resume() {
    idle_timeout_on_timer = FALSE;
    is_playing = TRUE;

    set_media(API_BASE_URL + np_player_url + "?t=" + (string)playback_seconds);
    set_texture("on");

    llSetTimerEvent(1.0);
}

sync() {
    if (playback_seconds < 0) playback_seconds = 0;
    set_media(API_BASE_URL + np_player_url + "?t=" + (string)playback_seconds);
}

seek(integer seconds) {
    playback_seconds = seconds;

    if (is_playing) {
        set_media(API_BASE_URL + np_player_url + "?t=" + (string)playback_seconds);
    }
}

set_idle_timeout(float seconds) {
    idle_timeout_on_timer = TRUE;
    llSetTimerEvent(seconds);
}

default
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    state_entry() {
        stop();
        llListen(LISTEN_CHANNEL, "", NULL_KEY, "");
        llSay(0, "tv is listening on channel " + (string)LISTEN_CHANNEL);
    }

    // handle incoming commands
    listen(integer channel, string name, key from, string msg) {
        list cmds_list = llParseString2List(msg, [" "], []); // ["a", "b", ...]
        string cmd = llList2String(cmds_list, 0); // "a"
        string sub_cmd = llList2String(cmds_list, 1); // "b"

        if (cmd == "skip" || cmd == "next") {
            llSay(0, user_link(from) + " skips");
            next(FALSE);

            // eagerly stop the screen and dont wait for the timer
            if (idle_timeout_on_timer) {
                stop();
            }

            return;
        }

        if (cmd == "stop") {
            if (is_playing == FALSE) return;

            stop();
            push_history();
            llSay(0, user_link(from) + " stopped playback");
            return;
        }

        if (cmd == "clear") {
            if (llGetListLength(queue) == 0) {
                llRegionSayTo(from, 0, "queue is already empty");
                return;
            }

            queue = [];
            llSay(0, user_link(from) + " cleared the queue");
            return;
        }

        if (cmd == "pause") {
            if (is_playing == FALSE) return;

            pause();
            llSay(0, user_link(from) + " paused playback");

            return;
        }

        if (cmd == "resume") {
            if (is_playing == TRUE || np_player_url == "") {
                llRegionSayTo(from, 0, "needs to be paused to resume!");
                return;
            }

            resume();
            llSay(0, user_link(from) + " resumed playback");
            return;
        }

        if (cmd == "sync") {
            if (is_playing == FALSE) {
                llRegionSayTo(from, 0, "needs to be playing to sync!");
                return;
            }

            sync();
            llSay(0, user_link(from) + " syncs playback of all listeners (" + fmt_timestamp(playback_seconds) + ")");
            return;
        }

        if (cmd == "seek") {
            if (np_player_url == "" || idle_timeout_on_timer == TRUE) {
                llRegionSayTo(from, 0, "something needs to be playing to seek!");
                return;
            }

            integer total_seconds = parse_timestamp(sub_cmd);

            llSay(0, user_link(from) + " seeks to " + fmt_timestamp(total_seconds));
            seek(total_seconds);
            return;
        }

        if (cmd == "np") {
            if (np_player_url == "") {
                llRegionSayTo(from, 0, "nothing is currently playing");
                return;
            }

            string say = "currently playing: " + hyperlink(np_title, np_source_url);

            if (np_duration > 0) {
                say += " (" + fmt_timestamp(playback_seconds) + " / " + fmt_timestamp(np_duration) + ")";
            }

            say += ", added by " + user_link(np_requested_by);

            llRegionSayTo(from, 0, say);
            return;
        }

        if (cmd == "history" || cmd == "h") {
            say_list(from, history, "history");
            return;
        }

        if (cmd == "queue" || cmd == "q") {
            say_list(from, queue, "queue");
            return;
        }

        if (cmd == "about" || cmd == "info" || cmd == "help") {
            llRegionSayTo(from, 0, "sl-tv by malaises/furudean v" + VERSION + " - https://tv.himawari.fun");
            return;
        }

        if (cmd == "playskip") {
            resolve(sub_cmd, from, 1);
            return;
        }

        resolve(cmd, from, 0);
    }

    // handle meta data web server response
    http_response(key request_id, integer status, list metadata, string body) {
        if (status >= 400) {
            llSay(0, "⚠️ error when resolving player info...\n---\nstatus " + (string)status + ": " + body + "\n---");
            return;
        }

        string player_url = llJsonGetValue(body, ["player_url"]);
        string source_url = llJsonGetValue(body, ["source_url"]);
        string title = llJsonGetValue(body, ["title"]);
        integer duration = (integer)llJsonGetValue(body, ["duration"]);
        key requested_by = (key)llJsonGetValue(body, ["requested_by"]);
        integer play_skip = (integer)llJsonGetValue(body, ["play_skip"]);

        if (play_skip == TRUE) {
            queue = [player_url, source_url, title, duration, requested_by] + queue;
            llSay(0, user_link(requested_by) + " plays \"" + title + "\" (play skip)");
            next(FALSE);
            return;
        }

        // queue is a strided list
        queue += [player_url, source_url, title, duration, requested_by];

        if (np_player_url == "" || idle_timeout_on_timer) {
            // starting from stopped state, or at end of queue
            next(TRUE);
        } else {
            integer position = (llGetListLength(queue) / LIST_STRIDE) - 1;
            string say = user_link(requested_by) + " added \"" + title + "\" to queue";

            if (position == 0) {
                say += " (up next)";
            } else {
                say += " (" + (string)position + " ahead)";
            }

            llSay(0, say);
        }
    }

    timer() {
        if (idle_timeout_on_timer) {
            idle_timeout_on_timer = FALSE;
            llSetTimerEvent(0.0);

            stop();
            return;
        }

        playback_seconds += 1;

        // np_duration = 0 probably means live stream
        if (np_duration != 0 && playback_seconds > np_duration) {
            llSetTimerEvent(0.0);
            next(FALSE);
        }
    }
}
