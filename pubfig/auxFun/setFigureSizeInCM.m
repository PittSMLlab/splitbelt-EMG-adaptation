function setFigureSizeInCM(figHandle,figSize)
dpi=get(0,'ScreenPixelsPerInch');
set(figHandle,'Units','pixels')
oldSize=figHandle.InnerPosition(3:4);
factors=(dpi/2.54)*figSize./oldSize;
factor=min(factors);
resizeFigure(figHandle, factor);
end

