function pageRanges = tocResolver(tocEntries,option)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %% Load API KEY
    loadenv(".env");
    apiKey = getenv("OPENAI_API_KEY");
    modelName = "gpt-5-mini";
    context = jsonencode(tocEntries);
    %% Build Response Format
    ranges(1) = struct('start',"1",'end',"5");
    ranges(2) = struct('start',"10",'end',"end");
    output = ranges;
    %% AI
    systemPrompt = fileread("prompt_tocResolver.txt");
    resolver = openAIChat( ...
        systemPrompt, ...
        ResponseFormat = output, ...
        APIKey=apiKey, ...
        ModelName = modelName, ...
        TimeOut=90);
    userPrompt = [
        'Find all the page ranges related to ' option '.' newline, ...
        'The toc in JSON format is provided as follows:' newline , ...
        context];
    pageRanges = generate(resolver,userPrompt,TimeOut=3000);
end

