classdef FileLock < handle
    properties (Access = private)
        fileLock = []
        file
    end

    methods
        function this = FileLock(filename)
            this.file = java.io.RandomAccessFile(filename,'rw');
            fileChannel = this.file.getChannel();
            this.fileLock = fileChannel.tryLock();
        end

        function val = hasLock(this)
            if ~isempty(this.fileLock) && this.fileLock.isValid()
                val = true;
            else
                val = false;
            end
        end

        function delete(this)
            this.release();
        end

        function release(this)
            if this.hasLock
                this.fileLock.release();
            end
            this.file.close
        end
    end
end