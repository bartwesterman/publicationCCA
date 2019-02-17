function filewrite( text, filePath )

    fid = fopen(filePath,'w');
    fprintf(fid, text);
    fclose(fid);

end

