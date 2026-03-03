package levels;

// You can implement custom logic for different levels.
// Specify className of the level in the spreadsheet, and a class for it will be generated automatically.

class SampleLevel extends Level
{
    public function new()
    {
        super(Data.LevelsKind.level00);
    }
        
    public override function Init()
    {
        super.Init();

        trace('This is Level 0.');
    }
}