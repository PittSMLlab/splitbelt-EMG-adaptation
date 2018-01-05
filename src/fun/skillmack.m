% [p stats] = skillmack(response, treatments, blocks)
%
% The Skillings-Mack Statistical Test
%
% A nonparametric two-way ANOVA when the number of observations per
% treatment block is one or zero (i.e., when there are missing
% observations).  If the response variable is parametric
% (or normally distributed), anovan() should be used instead.
%
%
% Syntax
% [p] = skillmack(response, treatments, blocks)
% [p stats] = skillmack(response, treatments, blocks)
% 
% or
%
% [p stats] = skillmack(M)
%
% This version assumes M is structured similar to a table in the function
% friedman(), where columns are treatments, and rows are blocks. 
%
%
% Example:
%
% The following table given in Skillings & Mack (1981, page 173) describes 
% an unbalanced block design example for assembly times, assembly methods 
% (treatments, in rows), and people (blocks, in columns).  We might be
% interested in knowing whether there is a significant difference between
% assembly methods regardless of the person assembling them.  Formally, we
% are testing for the probability that the differences apparent in response
% time by assembly method (controlling for the assemblers) are due to 
% chance.
% 
% %                  Blocks (Person)
% %         A   B   C   D   E   F   G   H   I
% M =     [3.2 3.1 4.3 3.5 3.6 4.5 NaN 4.3 3.5; ...  % A  
%          4.1 3.9 3.5 3.6 4.2 4.7 4.2 4.6 NaN; ...  % B   Treatments
%          3.8 3.4 4.6 3.9 3.7 3.7 3.4 4.4 3.7; ...  % C  (Assembly Method)
%          4.2 4.0 4.8 4.0 3.9 NaN NaN 4.9 3.9];     % D     
%
% % Matlab syntax, however, prefers the row/block column/treatment
% % composition to the matrix.  
% M = M';
% 
% % While this is a concise way to represent the information, large
% % datasets may not feature such compression.  The data might also be
% % stored as three separate vectors.
% [block treatment response] = find(sparse(M));
% % or
% [person method time] = find(sparse(M));
%
% [p stats] = skillmack(M)
% % or
% [p stats] = skillmack(response, treatments, blocks)
% % or
% [p stats] = skillmack(time, method, person)
% % are equivalent, and yield:
%
% stats.T = 15.5930
% stats.df = 3
% stats.p = 0.0014
%
% % We could see these differences visually with a boxplot:
% boxplot(M)
% 
% The algorithm uses the chi-squared approximation for the p-value, which 
% should not be used when there are very few observations.  Please refer to
% the original text for a complete description.
% 
% References: 
% Hollander, M., & Wolfe, D. A. (1999). Nonparametric statistical methods (2nd ed.). New York: Wiley.
% Mack, G. A., & Skillings, J. H. (1980). A Friedman-Type Rank Test for Main Effects in a 2-Factor Anova. Journal of the American Statistical Association, 75(372), 947-951.
% Skillings, J. H., & Mack, G. A. (1981). On the Use of a Friedman-Type Statistic in Balanced and Unbalanced Block Designs. Technometrics, 23(2), 171-177.
%
% The code was tested against several published datasets, including the
% original dataset published by Skillings & Mack (1981).  For a copy of
% these datasets and other code written by the author, please see:
% http://www.geog.ucsb.edu/~pingel/matlabCode/index.html
%
% Use of this code for any non-commercial purpose is granted under the GNU
% Public License.  
%
% Author: 
% Thomas J. Pingel
% Department of Geography
% University of California, Santa Barbara
% 11 November 2010

function [p stats] = skillmack(M, treatments, blocks)

if nargin<3
% This section reformats matrix M into:
%     X (observations in the matrix M)
%     treatments (columns of M, and the variable of interest) 
%     blocks (rows of M, and the nuisance variable)

% Pick apart the observations
X = reshape(M,numel(M),1); 

% Since input is a matrix, define the levels.
treatmentlevels = [1:size(M,2)]'; % Columns
blocklevels = [1:size(M,1)]'; % Rows
% treatmentlevels = ([1:size(M,2)]'); % Columns
% blocklevels = ([1:size(M,1)]'); % Rows
k = length(treatmentlevels);
n = length(blocklevels);
treatments = reshape(repmat(treatmentlevels',n,1),numel(X),1); 
blocks = reshape(repmat(blocklevels,k,1),numel(X),1); 


% Get rid of extraneous information, as this will be redefined in the next
% section anyway.
clear treatmentlevels blocklevels k n;
end
%%
% This section applies to if the preferred format is supplied
% skillmack(X,treatments,blocks) where X is a vector (double) and
% treatments and blocks are cell arrays.

% X is now the first argument, input as M

if nargin==3
    X = M;
end

% First, convert to a cell array from matrix if necessary
if ~iscell(treatments)
    treatments2 = cell(size(treatments));
    for i=1:length(treatments)
        treatments2{i,1} = treatments(i);
    end
    treatments = treatments2;
    clear treatments2 i;
end
if ~iscell(blocks)
    blocks2 = cell(size(blocks));
    for i=1:length(blocks)
        blocks2{i,1} = blocks(i);
    end
    blocks = blocks2;
    clear blocks2 i;
end
%%
% Change to cell array of strings, for standardization.
% for i=1:length(blocks)
%     blocks{i,1} = num2str(blocks{i});
%     treatments{i,1} = num2str(treatments{i});
% end  
% clear i;

% Determine unique levels
treatmentlevels = unique(treatments);
blocklevels = unique(blocks);


%%
% Check to see if any block has only one observation.  If so, for now just
% issue a warning.  Technically, this block should be removed.
for i=1:length(blocklevels)
    indx = find(strcmp(blocks,blocklevels{i}));
    if length(indx) <= 1
        disp(['Block ',num2str(blocklevels{i}),' has an insufficient number of observations.']);
    end
end
clear i indx;

%% Balance the observations
% See if the results improve if 'unbalanced' setups are replaced with NaNs


%%
% Create a vector to hold ranked observations
rankedobs = nan(size(X));
% disp(num2str(size(X)));
% disp(num2str(length(blocklevels)));
for i=1:length(blocklevels)
   % Step II
   % Within each block, rank the observations from 1 to ki, where ki is the
   % number of treatments present in block i.  If ties occur, use average
   % ranks.
   % Grab the blocks at level i
   indx = find(strcmp(blocks,blocklevels{i}));
   % r holds the ranks for that block. NaNs in empty values.
   r = tiedrank(X(indx));
   % Step III
   % Let r(i,j) be the rank assigned to X(i,j) if the observation is present.
   % Otherwise, let r(i,j) = (k(i) + 1) / 2;
   % In other words, replace NaNs with guesses.
   indx2 = isnan(r);
    if sum(indx2)>0
%       disp('There are some NaN observations.');
      replacementr = (sum(isfinite(r)) + 1) / 2;
      r(indx2) = replacementr;
    end
   
   
   for j=1:length(indx)
      rankedobs(indx(j)) = r(j);
   end
end
clear i j indx indx2 r replacementr
% disp(num2str(rankedobs));
%% Let's try step 4: Calculating weights.
A = nan(length(treatmentlevels),1);
maxrank = nan(size(rankedobs));
frontweight = nan(size(rankedobs));
backweight = nan(size(rankedobs));
totalweight = nan(size(rankedobs));
% Calculate front and back weights 
for i=1:numel(X)
   maxrank(i) = max(rankedobs(find(strcmp(blocks,blocks{i}))));
   frontweight(i) = sqrt(12/(maxrank(i)+1));
   backweight(i) = rankedobs(i) - ((maxrank(i) + 1)/2);
end

% Multiply them together to get total weights
totalweight = frontweight.*backweight;
% Sum each treatment.
for i=1:length(A)
    indx = find(strcmp(treatments,treatmentlevels{i}));
    A(i) = sum(totalweight(indx));
end
clear i totalweight frontweight backweight maxrank indx;
% disp(num2str(A));

%% Create sigma matrix
sigma = nan(length(treatmentlevels),length(treatmentlevels));
k = length(treatmentlevels);
for i=1:k % row
    for j=1:k % column
       indxi = intersect(find(strcmp(treatments,treatmentlevels{i})),find(isfinite(X)==1));
       indxj = intersect(find(strcmp(treatments,treatmentlevels{j})),find(isfinite(X)==1));
%        indxk = intersect(indxi,indxj);
       sigma(i,j) = -length(intersect([blocks{indxi}],[blocks{indxj}]));
    end
end
for i=1:length(treatmentlevels)
    j = setdiff([1:length(treatmentlevels)],i);
    sigma(i,i) = sum(abs(sigma(i,j)));
end

%% Calculate the final statistic.
isigma = pinv(sigma);
T = A' * pinv(sigma) * A;

% Hollander and Wolfe (1999) propose that any value of A be omitted since
% Aj's are linearly dependent (see page 320).  For test purposes, this line
% equates to:
% A = A(1:end-1);
% sigma = sigma(1:end-1,1:end-1);

% However, this produces the same test statistic as the above.
% Note that values in Hollander and Wolfe can be obtained by rounding the
% values of A to the third decimal and the inverse of sigma to the fourth decimal.
% A = round(A*1000)./1000;
% isigma = round(inv(sigma)*10000)./10000;
% T = A' * isigma * A;

%% Calculate mean ranks
meanranks = nan(size(treatmentlevels));
for i=1:length(treatmentlevels)
    indx = find(strcmp(treatments,treatmentlevels{i}));
    meanranks(i) = nanmean(rankedobs(indx));
end
clear indx;
%%

df = length(treatmentlevels)-1;
p = 1 - chi2cdf(T,df);
stats.T = T;
stats.df = df;
stats.p = p;
stats.A = A;
stats.sigma = sigma;
stats.isigma = isigma;
stats.source = 'skillmack';
stats.labels = treatmentlevels;
stats.meanranks = meanranks;