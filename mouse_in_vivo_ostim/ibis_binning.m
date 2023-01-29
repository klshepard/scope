% Spatial Binning
function [bindata] = ibis_binning(rawdata, binSize)
    bindata = nanmean(reshape(rawdata,binSize,[],size(rawdata,3)));
    bindata = reshape(bindata,size(rawdata,1) / binSize,[],size(rawdata,3));
    bindata = permute(bindata,[2 1 3]);
    bindata = nanmean(reshape(bindata,binSize,[],size(rawdata,3)));
    bindata = reshape(bindata,size(rawdata,2) / binSize,[],size(rawdata,3));
    bindata = permute(bindata,[2 1 3]);
%     for ii = 1:12
%         for jj = 1:16
%             bindata(ii,jj,:,:) = mean(rawdata((ii-1).*16+1:ii.*16,(jj-1).*16+1:jj.*16,:,:),[1 2]);
%         end
%     end  

end
