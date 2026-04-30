function appendDebugData(data,varName)
%APPENDDEBUGDATA Append debug data to a cell array in the base workspace.

    name = varName;
    if evalin('base', sprintf('exist(''%s'', ''var'')', name))
        debugDataList = evalin('base', name);
    else
        debugDataList = {};
    end
    
    debugDataList{end+1} = data;
    assignin('base', name, debugDataList);
end