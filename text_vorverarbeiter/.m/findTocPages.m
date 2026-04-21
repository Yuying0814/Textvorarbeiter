function [tocIdx,outPages] = findTocPages(pages)
% Detect TOC-like pages and return their page indices.
%
% Input:
%   pages (struct): Page array extracted from ocrResult.pages.
%
% Output:
%   tocIdx (double): Indices of pages classified as TOC-like.
%   outPages (struct): Updated page array with per-page TOC scores and
%       repaired markdown content when OCR line reconstruction succeeds.

    nPages = numel(pages);
    first20PercentPages = 1:ceil(0.2*nPages);
    last20PercentPages = ceil(0.8*nPages):nPages;
    searchRange = [first20PercentPages last20PercentPages];
    titlePage = -999;
    hasTitle = false;
    tocIdx = [];
    fixedBuffer = cell(1,nPages);

    % Initialize the TOC-like score for all pages
    for k = 1:numel(pages)
        pages(k).TocLikeScore = 0;
    end

    for i = searchRange
        % Split the page markdown into lines for pattern analysis
        text = pages(i).markdown;
        lines = text2lines(text);
        nLines = numel(lines);

        %% Detect a TOC heading on the current page, e.g., "Contents"
        scoresTitle = 0;
        titleFound = false;
        tocTitleLineIndex = 0;

        if ~hasTitle
            for j = 1:numel(lines)
                thisLine = lower(lines{j});
                titleFound = detectTocTitle(thisLine);
                if titleFound
                    hasTitle = true;
                    scoresTitle = 1;
                    tocTitleLineIndex = j;
                    titlePage = i;
                    break;
                end
            end
        end

        % Count TOC-like lines, e.g., section number + title + dot leaders + page number
        patternLineCount = detectTocPattern(lines);

        % If a TOC heading is detected but no TOC-like entries are found,
        % the OCR output may be fragmented. Attempt line reconstruction and
        % re-evaluate the page.
        fixedLines = {};

        if any(i == [titlePage:titlePage+5]) && patternLineCount == 0
            fixedLines = fixTocPages(lines, tocTitleLineIndex);
            patternLineCount = detectTocPattern(fixedLines);
        end
        if patternLineCount>0
        disp(patternLineCount); % -------------------------------------debug------------------------------------
        disp(nLines);
        disp(i);
        end
        %% If a page contains both a TOC heading and TOC-like entries,
        % use the detected entry count as the reference count for
        % subsequent page scoring.

        if titleFound && patternLineCount ~= 0
            tocReferenceCount = patternLineCount;
        else
            tocReferenceCount = nLines;
        end

        %% Compute the final TOC-like score
        scores = 0;
        scoresToc = scoreToc(patternLineCount, nLines);

        % Total TOC-like score for the current page
        scores = scoresTitle + scoresToc;

        %% Store outputs
        pages(i).TocLikeScore = scores;
        if scores > 0.1
            tocIdx = [tocIdx i];
            % Replace the original markdown only when OCR reconstruction
            % produces non-empty lines and improves TOC-pattern detection.
            if ~isempty(fixedLines) && patternLineCount > 5
                fixedContent = '';
                for j = 1:tocTitleLineIndex
                    fixedContent = [fixedContent lines{j} newline];
                end
                for j = 1:numel(fixedLines)
                    fixedContent = [fixedContent fixedLines{j} newline];
                end
                fixedBuffer{i} = fixedContent;
            end
        end
    end

    % Refine TOC page indices using low-score consecutive-page stopping
    % rule, which means it's impossible that 2 consecutive pages have few
    % toc entries
    scoresArray = [pages(1:nPages).TocLikeScore];
    [~,maxIdx] = max(scoresArray);
    stopPage = inf;

    for i = maxIdx:nPages-1
        isLowPair = scoresArray(i) > 0 && scoresArray(i) <= 0.2 && ...
            scoresArray(i+1) > 0 && scoresArray(i+1) <= 0.2;
        if isLowPair
            stopPage = i + 1; % keep this page, exclude pages after it
            break;
        end
    end

    if isfinite(stopPage)
        tocIdx = tocIdx(tocIdx <= stopPage);
    end

    for i = 1:numel(tocIdx)
        pageIdx = tocIdx(i);
        if ~isempty(fixedBuffer{pageIdx})
            pages(pageIdx).markdown = fixedBuffer{pageIdx};
        end
    end

    outPages = pages;
end

function scoresToc = scoreToc(patternLineCount,nLines)
% Compute a TOC-like score from the number of matched TOC-pattern lines.
    scoresToc = patternLineCount/nLines;

end

function fixedLines = fixTocPages(lines, matchedLine)
% Reconstruct TOC-like entries when OCR splits one entry across multiple lines.

    entryLine = '';
    idx = 1;
    fixedLines = {};
    hasTocBegin = false;

    for j = matchedLine + 1:numel(lines)
        thisLine = lines{j};
        matchPageNum = matchPattern(thisLine, '^\d+$'); % Detect a standalone page number
        matchHtmlTitle = matchPattern(thisLine, '^#');  % Detect a heading-like title line

        if matchHtmlTitle            
            if  hasTocBegin && ~isempty(strtrim(entryLine))
            % Store the previous incomplete TOC line before starting a new one    
                fixedLines{idx} = entryLine;
                idx = idx + 1;
            end
            % Build toc-entry line
            entryLine = strtrim(thisLine);
            hasTocBegin = true;

        elseif matchPageNum && hasTocBegin
            % Close the current TOC line when a trailing page number is found
            entryLine = [entryLine '... ' strtrim(thisLine)];
            fixedLines{idx} = entryLine;
            idx = idx + 1;
            entryLine = '';
            hasTocBegin = false;

        else
            
            if hasTocBegin
                % Append continuation text to the current TOC line
                entryLine = [entryLine ' ' strtrim(thisLine)];
            else
                % Preserve unrelated lines as independent lines
                fixedLines{idx} = thisLine;
                idx = idx + 1;
            end
        end
    end

    % Preserve the last reconstructed line if it does not end with a page number
    if hasTocBegin && ~isempty(strtrim(entryLine))
        fixedLines{idx} = entryLine;
    end

    % Remove empty elements after reconstruction
    if ~isempty(fixedLines)
        blankMaskFixed = cellfun(@isempty, strtrim(fixedLines));
        fixedLines = fixedLines(~blankMaskFixed);
    end
end