function downloadKeggPathways( pathwayIdList, targetPath)
%DOWNLOADFILELIST Summary of this function goes here
%   Detailed explanation goes here

    for i = 1:length(pathwayIdList)
        pathwayId = pathwayIdList{i};
        
        pathwayId = strrep(pathwayId, ':', '');
        
        targetFilePath = [targetPath pathwayId '.xml'];
        sourceUrl      = ['http://rest.kegg.jp/get/' pathwayId '/kgml'];
        
        try
            pathwayFileContents = urlread(sourceUrl);
        catch
            disp(['Failed to download ' pathwayId]);
            continue;
        end
        
        fid = fopen(targetFilePath, 'w');
        
        fwrite(fid, pathwayFileContents);
        
        fclose(fid);
        disp(['Successfully downloaded ' pathwayId]);

    end
end

