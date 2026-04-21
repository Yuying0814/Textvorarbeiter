function tocJson = tocEntryExtractor(tocPages)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Load API KEY
    loadenv(".env");
    apiKey = getenv("OPENAI_API_KEY");
    modelName = "gpt-5-mini";
    context = jsonencode(tocPages);
%% Build Response Format
    tocEntries(1) = struct('page_number',1,'content',"",'source_index',0);
    tocEntries(2) = struct('page_number',2,'content',"",'source_index',0);
    tablesStr(1) = struct('id',"",'content',"",'format',"",'word_confidence_scores',"");
    tablesStr(2) = struct('id',"",'content',"",'format',"",'word_confidence_scores',"");
    tocPagesStr(1) = struct('index',1,'markdown',"",'tables',tablesStr);
    tocPagesStr(2) = struct('index',2,'markdown',"",'tables',tablesStr);
    output = struct('toc_entries',tocEntries,'fixed_pages',tocPagesStr);
%% AI Calling
    systemPrompt = fileread("prompt_tocExtractor.txt");
    extractor = openAIChat( ...
        systemPrompt, ...
        ResponseFormat = output, ...
        APIKey=apiKey, ...
        ModelName = modelName, ...
        TimeOut=90);
    userPrompt = context;
    tocJson = generate(extractor,userPrompt,TimeOut=3000);
end