function [lineHandles] = addBinaryBoundary(plotHandle, binaryData,xCoord,yCoord)
% Given some binary data matrix, plots a 'boundary' around the 1's of the
% matrix.

if nargin<3 || isempty(xCoord)
    xCoord=1:size(binaryData,1);
end
if nargin<4 || isempty(yCoord)
    yCoord=1:size(binaryData,2);
end

axes(plotHandle)

%Add zero-padding around matrix to get edges in the border of matrix
xCoord=[xCoord(1)-(xCoord(2)-xCoord(1)) xCoord 2*xCoord(end)-xCoord(end-1)];
yCoord=[yCoord(1)-(yCoord(2)-yCoord(1)) yCoord 2*yCoord(end)-yCoord(end-1)];
binaryData=[zeros(size(binaryData,1)+2,1) [zeros(1,size(binaryData,2)); binaryData; zeros(1,size(binaryData,2))] zeros(size(binaryData,1)+2,1)];

%If we want to get only horizontal and vertical edges (looks better):
xCoord2=linspace(xCoord(1),xCoord(end),100*length(xCoord));
yCoord2=linspace(yCoord(1),yCoord(end),100*length(yCoord))';
binaryData2=interp2(xCoord,yCoord',double(binaryData),xCoord2,yCoord2,'nearest',0);

%The simplest way:
[~,cc]=contour(xCoord2,yCoord2,binaryData2,[.5 .5]);
cc.LineWidth=4;
cc.Color=[0 0 0];
lineHandles=cc;


end

