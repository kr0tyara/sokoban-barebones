package levels;

// You can die in this level! :)

class Mortal extends Level
{
    public function new()
    {
        super(Data.LevelsKind.level08);
    }
        
    public override function Init()
    {
        super.Init();
        Level.grid.gravity = true;
    }
}