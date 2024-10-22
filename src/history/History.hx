package history;

import entities.BaseEntity;

class History
{
    public static var inst:History;
    public var currentState = -1;

    private var grid:Grid;
    private var states:Array<Array<HistoryState>>;
    private var undone:Array<Array<HistoryState>>;

    public var steps(get, null):Int;
    public function get_steps():Int
    {
        return states.length - 1;    
    }

    public function new()
    {
        if(inst != null)
        {
            return;
        }

        inst = this;
    }

    public function Initialize(grid:Grid)
    {
        this.grid = grid;
        currentState = -1;
        states = new Array<Array<HistoryState>>();
        undone = new Array<Array<HistoryState>>();
    }

    public function AreStatesEqual(a:Array<HistoryState>, b:Array<HistoryState>, isSecondStateInitial:Bool):Bool
    {
        if(a.length != b.length && !isSecondStateInitial)
            return false;

        for(state in a)
        {
            var corresponding = b.filter(a -> a.entity == state.entity);
            if(corresponding.length == 0)
                return false;

            if(!corresponding[0].CompareTo(state))
                return false;
        }

        return true;
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

    public function MakeState()
    {
        var newStates = new Array<HistoryState>();
        var oldStates = new Array<HistoryState>(); // сохраняем старые стейты которые обновятся в новом
        for(entity in grid.allEntities)
        {
            if(entity.dirty)
            {
                if(currentState >= 0 && !ContainsEntity(states[currentState], entity))
                    oldStates.push(LastStateOf(entity).Clone());

                newStates.push(entity.MakeState());
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

        for(state in states[currentState])
        {
            state.entity.ApplyState(state);
        }

        grid.RebuildGrid();
    }

    public function Undo():Bool
    {
        if(currentState - 1 < 0)
            return false;

        currentState -= 1;
        var lastState = states.pop();
        undone.push(lastState);

        for(state in states[currentState])
        {
            state.entity.ApplyState(state);
        }
        
        grid.RebuildGrid();
        return true;
    }
    
    public function Redo():Bool
    {
        if(undone.length == 0)
            return false;

        currentState += 1;
        states.push(undone.pop());

        for(state in states[currentState])
        {
            state.entity.ApplyState(state);
        }
        
        grid.RebuildGrid();
        return true;
    }
}