function [stringNoTags] = removeTags(string)
%removeTags takes a string and removes tags of the form <SOME_TAG> (html style)
%from all its ocurrences

stringNoTags=regexprep(string,'<[^>]*>','');
stringNoTags=regexprep(stringNoTags,'~','='); %Also removing '~'
end

