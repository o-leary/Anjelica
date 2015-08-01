--
-- JukeBox Config
--
local config = {}

config.now_playing = ""
config.nothing_playing = "There is no track playing."

config.help = ""

config.set_comment = true
config.comment = ""

-- Message shown to channel when a youtube link is posted.
config.youtube_html = [[
<table>
    <tr>
        <td align="center" valign="middle">
            <a href="http://youtu.be/%s">%s</a>
        </td>
    </tr>
    <tr>
        <td align="center">
            <a href="http://youtu.be/%s"><img src="%s" width="250" /></a>
        </td>
    </tr>
</table>
]]

-- Message shown to channel when a new song starts playing.
config.now_playing_html = [[
        <table>
<!--                 <tr>
                        <td align="center"><img src="%s" width=150 /></td>
                </tr> -->
                <tr>
                        <td align="center"><b>Now Playing: <a href="http://youtu.be/%s">%s</a></b></td>
                </tr>
                <tr>
                        <td align="center">Added by %s</td>
                </tr>
        </table>
]]

-- Message shown to channel when a song is added to the queue by a user.
config.song_added_html = [[
        <b>%s</b> queued "%s".
]]

-- Message shown to channel when a user votes to skip a song.
config.user_skip_html = [[
        <b>%s</b> has voted to skip this song.
]]

-- Message shown to channel when a song has been skipped.
config.song_skipped_html = [[
        <b>Skipping song!</b>
]]
config.admin_song_skipped_html = [[
        <b>Moderator skipped song!</b>
]]

-- Message shown to channel when a user votes to skip a song.
config.user_stop_html = [[
        <b>%s</b> voted to stop music.
]]

-- Message shown to channel when a song has been skipped.
config.music_stopped_html = [[
        <b>Music Stopped!</b>
]]
config.admin_music_stopped_html = [[
        <b>Moderator stopped the music!</b>
]]

return config
