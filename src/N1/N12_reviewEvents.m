h=ReviewEventsGUI;
handles=guihandles(h);
set(handles.directory,'String','../../matData/');
%Force callback of directory: HOW?
set(handles.subject,'String',['sub' num2str(sub) 'Processed']);
%Force callback of subject: HOW?
waitfor(h)