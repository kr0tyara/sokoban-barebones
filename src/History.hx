package;

import entities.BaseEntity;

typedef HistoryState = {
    entity:BaseEntity,
    state:Dynamic,
    ?spawned:Bool
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

    private var pendingDestroyed:Array<BaseEntity> = [];

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

    
    public function NotifyDestroyed(entity:BaseEntity)
    {
        pendingDestroyed.push(entity);
    }

    private function Backfill(entity:BaseEntity, oldStates:Array<HistoryState>)
    {
        if(currentState >= 0 && !ContainsEntity(states[currentState], entity))
        {
            var state = LastStateOf(entity);
            if(state != null)
                oldStates.push({entity: entity, state: Reflect.copy(state.state)});
        }
    }

    public function MakeState(forceAll:Bool = false)
    {
        var newStates = new Array<HistoryState>();
        var oldStates = new Array<HistoryState>();

        for(entity in grid.allEntities)
        {
            if(entity.dirty || forceAll)
            {
                Backfill(entity, oldStates);

                var isNew = LastStateOf(entity) == null;
                newStates.push({entity: entity, state: entity.MakeState(), spawned: isNew});
                entity.dirty = false;
            }
        }

        for(entity in pendingDestroyed)
        {
            Backfill(entity, oldStates);
            newStates.push({entity: entity, state: null});
        }
        pendingDestroyed = [];

        if(oldStates.length > 0)
            states[currentState] = states[currentState].concat(oldStates);

        if(newStates.length > 0)
        {
            states.push(newStates);
            currentState++;
            undone = new Array<Array<HistoryState>>();
        }

        Game.ui.Refresh();
    }

    private function ApplyChanges()
    {
        for(state in states[currentState])
            if(state.state != null)
                state.entity.ApplyState(state.state);

        Game.ui.Refresh();
    }

    private function SyncExistence(frame:Array<HistoryState>, entering:Bool)
    {
        for(record in frame)
        {
            if(record.spawned == true)
                SetAlive(record.entity, entering);
            else if(record.state == null)
                SetAlive(record.entity, !entering);
        }
    }

    private function SetAlive(entity:BaseEntity, alive:Bool)
    {
        var isAlive = grid.allEntities.contains(entity);
        if(alive && !isAlive)
            grid.Revive(entity);
        else if(!alive && isAlive)
            grid.Destroy(entity, false);
    }

    public function Undo():Bool
    {
        if(currentState - 1 < 0)
            return false;

        currentState -= 1;
        var lastState = states.pop();
        undone.push(lastState);

        SyncExistence(lastState, false);
        ApplyChanges();

        return true;
    }

    public function Redo():Bool
    {
        if(undone.length == 0)
            return false;

        currentState += 1;
        var frame = undone.pop();
        states.push(frame);

        SyncExistence(frame, true);
        ApplyChanges();

        return true;
    }

    public function SetState(state:Int)
    {
        if(state < 0 || state >= states.length + undone.length)
            return;

        while(currentState > state) Undo();
        while(currentState < state) Redo();
    }

    public function Restart()
    {
        var initial = states[0].map(s -> s.entity);

        for(entity in grid.allEntities.copy())
            if(!initial.contains(entity))
                grid.Destroy(entity);

        for(record in states[0])
            if(!grid.allEntities.contains(record.entity))
                grid.Revive(record.entity);

        for(state in states[0])
            state.entity.ApplyState(state.state);

        MakeState(true);
    }
}