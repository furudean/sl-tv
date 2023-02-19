integer MEDIA_FACE = 3;
integer CHANNEL = -333;
string API_BASE_URL = "https://https://tv.himawari.fun";
integer INIT_DELAY = -5;

// this is a strided list
// [string player_url, string source_url, string title, integer duration, key requested_by, ...]
list queue = [];

integer is_playing = FALSE;
integer playback_seconds = 0;
integer idle_timeout_on_timer = FALSE;

// currently playing
string np_player_url;
string np_source_url;
string np_title;
integer np_duration;
key np_requested_by;

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

next(integer first) {
    if (llGetListLength(queue) == 0) {
        llSay(0, "reached end of queue");
        set_idle_timeout(30.0);

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
    queue = llDeleteSubList(queue, 0, 4);

    set_media(API_BASE_URL + np_player_url);
    set_texture("on");

    if (first) {
        llSay(0, "▶ " + user_link(np_requested_by) + " started playing️ \"" + np_title + "\" (" + np_source_url + ")");
        playback_seconds = INIT_DELAY;
    } else {
        llSay(0, "▶ " + np_title + " (" + np_source_url + ")");
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
        llListen(CHANNEL, "", NULL_KEY, "");
    }

    // handle incoming commands
    listen(integer chan, string name, key id, string msg) {
        list parsed_message = llParseString2List(msg, [","], []); // ["user", "a b"]
        key from = (key)llList2String(parsed_message, 0); // "user"
        string cmds = llList2String(parsed_message, 1); // "a b"

        list cmds_list = llParseString2List(cmds, [" "], []); // ["a", "b"]
        string cmd = llList2String(cmds_list, 0); // "a"
        string sub_cmd = llList2String(cmds_list, 1); // "b"

        if (cmd == "skip") {
            next(FALSE);
            return;
        }

        if (cmd == "stop") {
            if (is_playing == FALSE) return;

            stop();
            llSay(0, user_link(from) + " stopped playback");
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
            llSay(0, user_link(from) + " syncs playback (" + fmt_timestamp(playback_seconds) + ")");
            return;
        }

        if (cmd == "seek") {
            if (np_player_url == "") {
                llRegionSayTo(from, 0, "something needs to be playing to seek!");
                return;
            }

            integer total_seconds = parse_timestamp(sub_cmd);

            llSay(0, user_link(from) + " seeks to " + fmt_timestamp(total_seconds));
            seek(total_seconds);
            return;
        }

        // we query an external web server for some meta data
        string request_url = API_BASE_URL + "/resolve?" +
            "q=" + llEscapeURL(cmd) + 
            "&u=" + (string)from;

        // the response is picked up in the http_response handler below
        llHTTPRequest(request_url, [], "");
    }

    // handle meta data web server response
    http_response(key request_id, integer status, list metadata, string body) {
        if (status >= 500) { 
            llSay(0, "<!> could not connect to resolve server :-(");
            return; 
        }

        if (status >= 400) { 
            llSay(0, "<!> could not resolve");
            return;
        }

        string player_url = llJsonGetValue(body, ["player_url"]);
        string source_url = llJsonGetValue(body, ["source_url"]);
        string title = llJsonGetValue(body, ["title"]);
        integer duration = (integer)llJsonGetValue(body, ["duration"]);
        key requested_by = (key)llJsonGetValue(body, ["requested_by"]);

        // queue is a strided list
        queue += [player_url, source_url, title, duration, requested_by];

        if (np_player_url == "") {
            // starting from stopped state, start immediately
            next(TRUE);
        } else {
            llSay(0, user_link(requested_by) + " added \"" + title + "\" to queue");
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
