function patternLineCount = detectTocPattern(lines)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    patternLineCount = 0;
    pattern1 = ['^(?!\d+(?:\.\d+)*$)' ...                % exclude pure number 1.1 1.2.1
        '(?!\d+\s*[/|]\s*\d+$)' ...                      % exclude page footing 2 / 21, 2 | 21
        '(?!\d+\s+[Oo][Ff]\s+\d+$)' ...                  % exclude page footing 2 of 21
        '(?!#*\s*.+\s+\d+\s*(?:[/|]\s*\d+|[Oo][Ff]\s+\d+)$)' ... % exclude "# title 4 / 42", "# title 4 of 42"
        '#*\s*\d+(?:\.\d+)*\s+.+?(?:\s|\.{2,}\s*)\d+$']; % "4.1 REGISTER 0 - WHO AM I. ... 7",

    pattern2 = ['^(?!\d+(?:\.\d+)*$)' ...                % exclude pure number 1.1 1.2.1
        '(?!\d+\s*/\s*\d+$)' ...                         % exclude page footing 2 / 21, 2 | 21
        '(?!\d+\s+[Oo][Ff]\s+\d+$)' ...                  % exclude page footing 2 of 21
        '(?!#*\s*.+\s+\d+\s*(?:[/|]\s*\d+|[Oo][Ff]\s+\d+)$)' ... % exclude "# title 4 / 42", "# title 4 of 42"
        '(?!#*\s*(?:Table|Figure)\s+\d+\.?\s+.*(?:\.{2,}\s*)\d+$)' ... % exclude Figure and Table
        '#*\s*[^\d].*?(?:\.{2,}\s*)\d+$']; % Introduction ... 3
    pattern3 = [...
    '^\s*#{1,6}\s+' ...                                  % match "# "
    '(?!Table\s+\d+\b)' ...                              % exclude Table
    '(?!Figure\s+\d+\b)' ...                             % exclude "### Figure 12"
    '[^\d].*?(?:\s+|\.{2,}\s*)\d+\s*$'];                 % ## Introduction 1

    pattern4 = [...
    '^\s*-\s+' ...                                       % match "- "
    '(?!Table\s+\d+\b)' ...                              % exclude Table
    '(?!Figure\s+\d+\b)' ...                             % exclude Figure
    '[^\d].*?(?:\s+|\.{2,}\s*)\d+\s*$'];                 % - Introduction 3

    for i = 1:numel(lines)
        thisLine = lines{i};
        matchPattern1 = matchPattern(thisLine, pattern1);
        matchPattern2 = matchPattern(thisLine, pattern2);
        matchPattern3 = matchPattern(thisLine, pattern3);
        matchPattern4 = matchPattern(thisLine, pattern4);
        if matchPattern1 || matchPattern2 || matchPattern3 || matchPattern4
            patternLineCount = patternLineCount + 1;
            disp(lines{i}); % ----------------------------------------debug-------------------------------------------
        end
    end
end