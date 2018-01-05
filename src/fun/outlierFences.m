function [allOutliers,extremeOutliers] = outlierFences(data,dim)
%outlierFences detects outliers in data, using the 'fences' strategy, where
%any data point more than 1.5 inter-quartile ranges away from the first or
%third quartile marks is deemed a 'mild' outlier, and any point more than 3
%IQRs away is an 'extreme' outlier
% This function operates along columns of data.
%OUTPUT:
%Returns two binary matrices allOutliers and extremeOutliers, of the same
%size as data. Values equal to 1 indicate an outlier.

% if nargin<2 || isempty(dim) || dim<1
%     dim=1;
% end

Quartiles=quantile(data,4);
IQRs=Quartiles(3,:)-Quartiles(1,:); %Computing IQR along columns
k=[1.5,3]; %Computing 2 classes of outliers
outlierClass=cell(size(k));
for i=1:length(k)
    lowerThreshold=Quartiles(1,:)-k(i)*IQRs;
    upperThreshold=Quartiles(3,:)+k(i)*IQRs;
    outlierClass{i}=bsxfun(@lt, data(:,:), lowerThreshold) | bsxfun(@gt, data(:,:), upperThreshold);
end

allOutliers=reshape(outlierClass{1},size(data));
extremeOutliers=reshape(outlierClass{2},size(data));

end

