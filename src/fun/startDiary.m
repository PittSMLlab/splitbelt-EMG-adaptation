function startDiary(diaryFileName)
    if exist(diaryFileName,'file')
        movefile(diaryFileName,[diaryFileName '_' num2str(now)])
    end
    diary(diaryFileName)
    disp(datetime)
end

