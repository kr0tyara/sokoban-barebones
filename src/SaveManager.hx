typedef GameSave =
{
    lastLevel:Data.LevelsKind,
    levels:Map<Data.LevelsKind, LevelSave>,
    sfxMuted:Bool,
    bgmMuted:Bool
}
typedef LevelSave = 
{
    id:Data.LevelsKind,
    steps:Int,
    completed:Bool
}

class SaveManager
{
    public static var inst:SaveManager;

    public static var save:GameSave;
    // name of the save file, make it unique!
    public static var saveSlot:String = 'sokothing';
    
    public function new()
    {
        inst = this;

        var firstLevel = Data.levels.all[0].id;
        var defaultSave:GameSave = {lastLevel: firstLevel, levels: new Map<Data.LevelsKind, LevelSave>(), sfxMuted: false, bgmMuted: false};

        #if !ld
        save = hxd.Save.load(defaultSave, saveSlot);
        #else
        save = defaultSave;
        #end

        if(Data.levels.get(save.lastLevel) == null)
            save.lastLevel = firstLevel;
    }

    public static function Save()
    {
        #if !ld
        hxd.Save.save(save, saveSlot);
        #end
    }

    public static function SetMute(mute:Bool, bgm:Bool)
    {
        if(bgm)
            save.bgmMuted = mute;
        else
            save.sfxMuted = mute;

        Save();
    }

    public static function SetLastLevel(id:Data.LevelsKind)
    {
        save.lastLevel = id;
        Save();
    }

    public static function CompleteLevel(id:Data.LevelsKind, steps:Int)
    {
        var level = GetLevelInfo(id);

        if(steps < level.steps || level.steps == -1)
            level.steps = steps;

        level.completed = true;
        
        save.levels[id] = level;
        Save();
    }

    public static function IsMuted(bgm:Bool)
    {
        if(bgm)
            return save.bgmMuted;
        
        return save.sfxMuted;
    }

    public static function GetLevelInfo(id:Data.LevelsKind):LevelSave
    {
        var levelInfo = save.levels[id];
        if(levelInfo == null)
        {
            return {
                    steps: -1,
                    id: id,
                    completed: false
                };
        }

        return levelInfo;
    }
}