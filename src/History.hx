package;

import entities.BaseEntity;

typedef HistoryState = {
    entity:BaseEntity,
    state:Dynamic 
}

class History
{
    public var currentState = -1;

    private var states:Array<Array<HistoryState>>;
    private var undone:Array<Array<HistoryState>>;
    
    private var grid:Grid;

    public var steps(get, null):Int;
    public function get_steps():Int
    {
        return states.length;
    }

    public var undoneCount(get, null):Int;
    public function get_undoneCount():Int
    {
        return undone.length;
    }

    public function new()
    {
    }

    public function Initialize(grid:Grid)
    {
        this.grid = grid;
        currentState = -1;
        states = new Array<Array<HistoryState>>();
        undone = new Array<Array<HistoryState>>();
    }

    public function ContainsEntity(states:Array<HistoryState>, entity:BaseEntity)
    {
        var filter = states.filter(a -> a.entity == entity);
        return filter.length > 0;
    }

    public function LastStateOf(entity:BaseEntity):HistoryState
    {
        var i = states.length - 1;
        while(i >= 0)
        {
            for(state in states[i])
            {
                if(state.entity == entity)
                    return state;
            }

            i--;
        }

        return null;
    }

    public function MakeState(forceAll:Bool = false)
    {
        var newStates = new Array<HistoryState>();
        var oldStates = new Array<HistoryState>(); // clone old states that will be updated in the new one
        for(entity in grid.allEntities)
        {
            if(entity.dirty || forceAll)
            {
                // запомним старый стэйт перед обновлением
                if(currentState >= 0 && !ContainsEntity(states[currentState], entity))
                {
                    var state = LastStateOf(entity);
                    if(state != null)
                        oldStates.push({entity: entity, state: Reflect.copy(state.state)});
                }

                newStates.push({entity: entity, state: entity.MakeState()});
                entity.dirty = false;
            }
        }

        if(oldStates.length > 0)
        {
            states[currentState] = states[currentState].concat(oldStates);
        }
        
        if(newStates.length > 0)
        {
            states.push(newStates);
            currentState++;

            undone = new Array<Array<HistoryState>>();
        }
    }

    public function SetState(state:Int)
    {
        if(state < 0 || state >= states.length - 1)
            return;

        currentState = state;
        states = states.slice(0, currentState + 1);

        ApplyChanges();
    }

    private function ApplyChanges()
    {
        for(state in states[currentState])
            state.entity.ApplyState(state.state);
    }

    public function Undo():Bool
    {
        if(currentState - 1 < 0)
            return false;

        currentState -= 1;
        var lastState = states.pop();
        undone.push(lastState);

        ApplyChanges();
        
        return true;
    }
    
    public function Redo():Bool
    {
        if(undone.length == 0)
            return false;

        currentState += 1;
        states.push(undone.pop());

        ApplyChanges();
        
        return true;
    }

    public function Restart()
    {
        for(state in states[0])
            state.entity.ApplyState(state.state);

        MakeState(true);
    }
}