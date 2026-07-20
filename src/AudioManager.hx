import hxd.snd.SoundGroup;
import hxd.res.Sound;

enum SoundGroupKind
{
    Music;
    SFX;
}

enum Sfx
{
    Click;
    Move;
    Unlock;
    Hit;
    Bgm;
    Pop;
}

typedef SoundDef =
{
    name:Sfx,
    group:SoundGroupKind,
    volume:Float,
    clips:Array<Sound>,
    ?loop:Bool,
    ?overrideExisting:Bool
}

class AudioManager
{
    public static var inst:AudioManager;

    private var musicGroup:SoundGroup;
    private var sfxGroup:SoundGroup;

    private var sounds:Map<Sfx, SoundDef> = new Map();
    private var active:Map<Sfx, Sound> = new Map();

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

        RegisterSounds();

        Mute(SaveManager.IsMuted(false), false, false);
        Mute(SaveManager.IsMuted(true), true, false);
    }

    private function RegisterSounds()
    {
        Register({name: Sfx.Click,  group: SoundGroupKind.SFX, volume: .7, clips: [hxd.Res.sfx.click.jump, hxd.Res.sfx.click.jump2, hxd.Res.sfx.click.jump4]});
        Register({name: Sfx.Move,   group: SoundGroupKind.SFX, volume: 1,  clips: [hxd.Res.sfx.movement.synth1]});
        Register({name: Sfx.Unlock, group: SoundGroupKind.SFX, volume: .6, clips: [hxd.Res.sfx.unlock.unlock]});
        Register({name: Sfx.Hit,    group: SoundGroupKind.SFX, volume: .7, clips: [hxd.Res.sfx.hit.hit]});
        Register({name: Sfx.Pop,    group: SoundGroupKind.SFX, volume: .7, clips: [hxd.Res.sfx.pop.pop]});

        //Register({name: Sfx.Bgm, group: SoundGroupKind.Music, volume: 1, loop: true, clips: [hxd.Res.sfx.mus]});
    }

    private function Register(def:SoundDef)
    {
        if(def.loop == null)
            def.loop = false;

        if(def.overrideExisting == null)
            def.overrideExisting = true;

        sounds.set(def.name, def);
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

    public function Play(name:Sfx)
    {
        var def = sounds.get(name);
        if(def == null)
        {
            trace('Sound $name not registered');
            return;
        }

        if(def.overrideExisting)
        {
            var current = active.get(name);
            if(current != null)
                current.stop();
        }

        var clip = Utils.RandomArray(def.clips);
        var group = def.group == SoundGroupKind.Music ? musicGroup : sfxGroup;

        clip.play(def.loop, def.volume, null, group);

        if(def.overrideExisting)
            active.set(name, clip);
    }

    public function Stop(name:Sfx)
    {
        var current = active.get(name);
        if(current == null)
            return;

        current.stop();
        active.remove(name);
    }
}
