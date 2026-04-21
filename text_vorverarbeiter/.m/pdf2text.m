function Text = pdf2text(pdfPath)
%UNTITLED Summary of this function goes here
% https://docs.mistral.ai/capabilities/document_ai/basic_ocr
%   Detailed explanation goes here
loadenv(".env");
apiKey = getenv("MistralOCR_API_KEY");
Text = [];
fileID = "";
payloadPath = fullfile(tempdir, 'ocr_payload.json');
outputPath = fullfile(tempdir, 'ocr_output.json');
if ~isfile(pdfPath)
    error('PDF file not found: %s', pdfPath);
end

try
    %% 1.Upload PDF
    cmd = sprintf([ ...
        'curl -s https://api.mistral.ai/v1/files ' ...
        '-H "Authorization: Bearer %s" ' ...
        '-F purpose="ocr" ' ...
        '-F "file=@%s"'], ...
        apiKey, pdfPath);

    [status, output] = system(cmd);
    if status ~= 0
        error('Upload failed, errorID: %d', status);
    end
    uploadResult = jsondecode(output);
    fileID = uploadResult.id;

    %% 2.Get the URL of Uploaded PDF
    cmd = sprintf([ ...
        'curl -s -X GET "https://api.mistral.ai/v1/files/%s/url?expiry=24" ' ...
        '-H "Accept: application/json" ' ...
        '-H "Authorization: Bearer %s"'], ...
        fileID, apiKey);

    [status, output] = system(cmd);
    if status ~= 0
        error('Failed to get URL, errorID: %d', status);
    end

    urlResult = jsondecode(output);
    fileURL = char(urlResult.url);

    %% 3. OCR Query
    % Build OCR-Query Body
    bodyStruct = struct();
    bodyStruct.model = "mistral-ocr-latest";
    bodyStruct.document = struct("type", "document_url", "document_url", fileURL);
    bodyStruct.table_format = "html";
    bodyStruct.include_image_base64 = true;
    jsonText = jsonencode(bodyStruct);

    % Body saved in Json Form
    fid = fopen(payloadPath, 'w');
    if fid == -1
        error('Failed to open payload file for writing: %s', payloadPath);
    end
    fwrite(fid, jsonText, 'char');
    fclose(fid);

    % Send OCR Query
    cmd = sprintf([ ...
        'curl -s -X POST https://api.mistral.ai/v1/ocr ' ...
        '-H "Content-Type: application/json" ' ...
        '-H "Authorization: Bearer %s" ' ...
        '-d "@%s" ' ...
        '-o ocr_output.json'], ...
        apiKey, payloadPath);

    status = system(cmd);
    if status ~= 0
        error('Query failed, errorID: %d', status);
    end

    % Extract Result from Query Output
    result = fileread(outputPath);
    Text = jsondecode(result);

    %% Delete Uploaded Document from Cloud
    if ~isempty(fileID)
        cmd = sprintf([ ...
            'curl -s -X DELETE https://api.mistral.ai/v1/files/%s ' ...
            '-H "Authorization: Bearer %s"'], ...
            fileID, apiKey);

        [status, output] = system(cmd);
        if status ~= 0
            error('Delete failed, errorID: %d', status);
        end
    end

catch ME
    %% Delete Uploaded Document from Cloud
    if ~isempty(fileID)
        cmd = sprintf([ ...
            'curl -s -X DELETE https://api.mistral.ai/v1/files/%s ' ...
            '-H "Authorization: Bearer %s"'], ...
            fileID, apiKey);
        system(cmd);
    end

    rethrow(ME);
end
end