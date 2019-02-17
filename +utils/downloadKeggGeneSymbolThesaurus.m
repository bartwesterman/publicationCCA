function downloadKeggGeneSymbolThesaurus( saveFilePath )
%DOWNLEADKEGGGENESYMBOLTHESAURUS Summary of this function goes here
%   Detailed explanation goes here

    dreamGeneExpressionTable = readtable(Config.DREAM_CELLLINE_EXPRESSION);

    geneSymbols = dreamGeneExpressionTable.Var1;
    keggIds     = cell(size(geneSymbols));
    
    geneSymbolsPerRequest = 100;
    for i = 1:geneSymbolsPerRequest:length(geneSymbols)
         
        disp(['numberOfGeneSymbolsConvertedSoFar ' num2str(i)]);
        
        commaSeparatedGeneSymbols = strjoin(geneSymbols(i:min((i + geneSymbolsPerRequest - 1), length(geneSymbols))), ',');
    
        url = ['http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.xml?method=db2db&input=genesymbol&inputValues=' commaSeparatedGeneSymbols '&outputs=KEGG%20Gene%20ID&taxonId=9606&format=row'];
            
        result = xmlread(url);
        
        conversions = result.getElementsByTagName('item');
        
        for j = 0:(conversions.getLength() - 1)
            conversion = conversions.item(j);
            inputText = char(conversion.getElementsByTagName('InputValue').item(0).getTextContent());
            geneSymbolIndex = i + j;
            
            assert(strcmp(geneSymbols{geneSymbolIndex}, inputText), ['mismatched input text: input in response = ' inputText ' and input in file = ' geneSymbols{geneSymbolIndex}]);
            
            keggId = char(conversion.getElementsByTagName('KEGGGeneID').item(0).getTextContent());
            
            keggIds{geneSymbolIndex} = keggId;
        end
    end
    
    keggIdsWithoutColon = cellfun(@(v) strrep(v, ':', ''), keggIds, 'UniformOutput', false);
    
    thesaurusTable = table(geneSymbols,  keggIds, keggIdsWithoutColon);
    writetable(thesaurusTable, saveFilePath, 'FileType', 'text', 'WriteVariableNames', false);
    
    csvData = fileread(saveFilePath);
    thsData = strrep(csvData, sprintf(',-,-\n'), sprintf('\n'));
    
    fid = fopen(saveFilePath, 'w');
    fwrite(fid, thsData);
    fclose(fid);
end

