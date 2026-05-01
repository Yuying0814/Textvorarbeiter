function registers = preRegExtractor(pages)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if isempty(pages)
        registers = struct([]);
        return
    end

    loadenv(".env");
    apiKey = getenv("OPENAI_API_KEY");
    modelName = "gpt-5-mini";
    systemPrompt = fileread("prompt_preRegExtractor.txt");

    registers(1) = struct('name',"xxx",'adress',"xxx",'bank',"xxx",'page',"xxx",'source_index',"xxx");
    registers(2) = struct('name',"xxx",'adress',"xxx",'bank',"xxx",'page',"xxx",'source_index',"xxx");
    
    nameExtractor = openAIChat( ...
        systemPrompt, ...
        ResponseFormat = registers, ...
        APIKey=apiKey, ...
        ModelName = modelName, ...
        TimeOut=90);
    
    context = jsonencode(pages);
    userPrompt = ['Context is provided as follows:' ...
        newline ...
        context ... 
        newline ...
        'Extract register names, addresses, banks, pages, and source indexes according to the required struct array output format.'];
    registers = generate(nameExtractor,userPrompt,TimeOut=3000);
end
