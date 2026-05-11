function index = pageVerifier(pages,option)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if isempty(pages)
        index = [];
        return
    end
    
    loadenv(".env");
    apiKey = getenv("OPENAI_API_KEY");
    modelName = "gpt-5-mini";
    [systemPrompt,searchRange] = setVerifier(pages,option);
    verifier = openAIChat( ...
        systemPrompt, ...
        APIKey=apiKey, ...
        ModelName = modelName, ...
        TimeOut=90);

    response = strings(1,numel(pages));


    for i = searchRange
        context = jsonencode(pages(i));
        userPrompt = context;
        response(i) = generate(verifier,userPrompt,TimeOut=3000);
    end
    index = find(contains(response,'yes'));
end

function [systemPrompt, searchRange] = setVerifier(pages,option)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    option = lower(option);
    switch option
        case 'toc'
            systemPrompt = fileread("prompt_tocClassifier.txt");
            lastPage = ceil(0.3*numel(pages));
            searchRange = 1:lastPage;
        case 'register'
            systemPrompt = fileread("prompt_regClassifier.txt");
            lastPage = numel(pages);
            searchRange = 1:lastPage;
        case 'register summary'
            systemPrompt = fileread("prompt_regSummaryClassifier.txt");
            lastPage = numel(pages);
            searchRange = 1:lastPage;
        otherwise
           error(['String variable "option" must be one of: ' ...
    'toc, register, functional description, communications interface, coding example.']);
    end
end