function match = matchPattern(line,pattern)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    matchPosition = regexp(line,pattern,'once');
    match = false;
    if ~isempty(matchPosition)
        match = true;
    end
end