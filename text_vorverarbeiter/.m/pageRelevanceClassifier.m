function index = pageRelevanceClassifier(pages,option)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    loadenv(".env");
    apiKey = getenv("OPENAI_API_KEY");
    modelName = "gpt-5-mini";
    [systemPrompt,searchRange] = setClassifier(pages,option);
    classifier = openAIChat( ...
        systemPrompt, ...
        APIKey=apiKey, ...
        ModelName = modelName, ...
        TimeOut=90);

    response = strings(1,numel(pages));


    for i = searchRange
        context = jsonencode(pages(i));
        userPrompt = context;
        response(i) = generate(classifier,userPrompt,TimeOut=3000);
    end
    index = find(contains(response,'yes'));
end

function [systemPrompt, searchRange] = setClassifier(pages,option)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    option = lower(option);
    switch option
        case 'toc'
            systemPrompt = fileread("prompt_tocVerifier.txt");
            lastPage = ceil(0.3*numel(pages));
            searchRange = 1:lastPage;
        case 'register'
            systemPrompt = fileread("prompt_regVerifier.txt");
            lastPage = numel(pages);
            searchRange = 1:lastPage;
        case 'functional description'
            systemPrompt = fileread("prompt_funVerifier.txt");
            lastPage = numel(pages);
            searchRange = 1:lastPage;
        case 'communications interface'
            systemPrompt = fileread("prompt_comVerifier.txt");
            lastPage = numel(pages);
            searchRange = 1:lastPage;        
        case 'coding example'
            systemPrompt = fileread("prompt_codingVerifier.txt");
            lastPage = numel(pages);
            searchRange = 1:lastPage; 
        otherwise
           error(['String variable "option" must be one of: ' ...
    'toc, register, functional description, communications interface, coding example.']);
    end
end