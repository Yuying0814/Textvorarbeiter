function matchTitle = detectTocTitle(line)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    matchTitle = false;
    keywords = {'content','contents','list of contents','table of contents','index of contents','toc','contents overview'...
        'inhalt','inhalte','verzeichnis','inhaltsverzeichnis'};
    for i = 1:numel(keywords)
        % pattern = sprintf('^#* *%s *$',keywords{i});
        pattern = sprintf([ ...
            '^(?!#*\\s*(?:list of\\s+)?(?:tables|figures|images?|illustrations)\\s*$)' ...
            '#*\\s*%s\\s*$'], keywords{i});
        match = matchPattern(line,pattern);
        if match
            matchTitle = true;
            %disp(line); % test
            break
        end
    end
end 