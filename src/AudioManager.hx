import hxd.snd.SoundGroup;
import hxd.res.Sound;

class AudioManager
{
    public static var inst:AudioManager;

    private var musicGroup:SoundGroup;
    private var sfxGroup:SoundGroup;

    private var bgm:Sound;

    private var clicks:Array<Sound>;
    private var click:Sound;

    private var moves:Array<Sound>;
    private var move:Sound;

    private var unlock:Sound;

    public var sfxMuted:Bool = false;
    public var bgmMuted:Bool = false;

    public function new()
    {
        if(inst != null)
            return;

        inst = this;

        musicGroup = new SoundGroup('music');
        sfxGroup   = new SoundGroup('sfx');
        musicGroup.volume = .5;
        sfxGroup.volume = .75;

        clicks = [hxd.Res.sfx.click.jump, hxd.Res.sfx.click.jump2, hxd.Res.sfx.click.jump4];
        moves = [hxd.Res.sfx.movement.synth1];

        Mute(SaveManager.IsMuted(false), false, false);
        Mute(SaveManager.IsMuted(true), true, false);
    }

    public function Mute(mute:Bool, bgm:Bool, manual:Bool = true)
    {
        if(bgm)
        {
            bgmMuted = mute;
            musicGroup.volume = mute ? 0 : 1;
        }
        else
        {
            sfxMuted = mute;
            sfxGroup.volume = mute ? 0 : 1;
        }

        if(manual)
            SaveManager.SetMute(mute, bgm);
    }

    public function BGM()
    {
        /*
        bgm = hxd.Res.sfx.mus;   
        bgm.play(true, 1, null, musicGroup);
        */
    }

    public function Click()
    {
        if(click != null)
            click.stop();

        click = Utils.RandomArray(clicks.filter(a -> a != click));
        click.play(false, .7, null, sfxGroup);
    }

    public function Move()
    {
        if(move != null)
            move.stop();

        move = Utils.RandomArray(moves);
        move.play(false, 1, null, sfxGroup);
    }

    public function Unlock()
    {
        if(unlock != null)
            unlock.stop();

        unlock = hxd.Res.sfx.unlock.unlock;
        unlock.play(false, .6, null, sfxGroup);
    }
}