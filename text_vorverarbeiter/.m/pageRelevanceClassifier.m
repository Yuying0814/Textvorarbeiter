function outPages = pageRelevanceClassifier(pages)
% Classify each datasheet page into predefined relevance topics.

    if isempty(pages)
        error("No pages input.");
    end

    loadenv(".env");
    apiKey = getenv("OPENAI_API_KEY");
    modelName = "gpt-5-mini";

    systemPrompt = fileread("prompt_pageRelevanceClassifier.txt");
    responseFormat = struct( ...
        "is_toc", false, ...
        "is_register_summary_relevant", false, ...
        "is_register_map_relevant", false, ...
        "is_digital_interface_relevant", false, ...
        "is_data_conversion_relevant", false, ...
        "is_initialization_and_reset_relevant", false, ...
        "is_timing_relevant", false, ...
        "is_interrupt_alert_relevant", false, ...
        "is_fifo_relevant", false, ...
        "is_coding_example", false);

    classifier = openAIChat( ...
        systemPrompt, ...
        ResponseFormat=responseFormat, ...
        APIKey=apiKey, ...
        ModelName=modelName, ...
        TimeOut=90);

    preContent = "";
    classification = {};
    for i = 1:numel(pages)
        context = struct( ...
            "current_page", pages(i), ...
            "previous_content", preContent);

        userPrompt = jsonencode(context);
        classification{end+1} = generate(classifier, userPrompt, TimeOut=3000);
        preContent = getPageTail(pages(i));
    end
    [pages.classification] = classification{:};
    outPages = pages;
end


function pageTail = getPageTail(page)
    text = extractTextFrom(page);
    text = char(text);
    [~, chPos] = regexp(text, '\S+', 'match', 'start');

    if isempty(chPos)
        pageTail = "";
        return
    end

    wordCounts = numel(chPos);
    startWordIdx = max(1,ceil(wordCounts/2));
    startChIdx = chPos(startWordIdx);

    pageTail = text(startChIdx:end);
end