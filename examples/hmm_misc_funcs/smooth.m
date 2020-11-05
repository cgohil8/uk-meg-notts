function y = smooth(x,frame,mode)

% SMOOTH Perform windowed smoothing on a vector using mathematical functions
% 
% SYNTAX
% 
%     Y = smooth(X,FRAME)
%     Y = smooth(X,FRAME,MODE)
% 
% 
% DESCRIPTION
% 
% Y = smooth(X,FRAME) smooths the input vector X by calculating the running
% RMS over a series of frames. FRAME specifies the frame characteristics;
% it can be set to:
% 
% a scalar - this will be used as the length of the frame, the window will
% be rectangular
% a vector - this specifies the shape of the analysis window, the frame
% length will be length(frame).
% 
% Y = smooth(X,FRAME,MODE) allows the user to specify a different
% mathematical smoothing function. The options are:
% 
% 'rms' - calculates the running rms (default)
% 'mean' - calculates the running mean (moving average filter)
% 'median' - calculates the running median
% 
% NOTE: SMOOTH uses a vectorized implementation that may be slow when X 
% and/or FRAME_LENGTH are very large. The number of elements that are used
% for calculation is length(X)*FRAME_LENGTH. The algorithm vectorizes the
% operation by creating a matrix of indexes and extracting its diagonals.
% E.g. for a vector of length 4 and frame_length of 2, the algorithm
% creates a temporary zero-padded matix x2 from which it creates a set of
% indexes:
% 
% 1 1
% 2 2
% 3 3
% 4 4
% 5 5
% 6 6
% 
% It then extracts the diagonals where -length(x2)+frame_length<=k<=0,
% yielding:
% 
% 1 2
% 2 3
% 3 4
% 4 5
% 
% this is used to index x2; operations are then perfromed along the rows.

%% Gather inputs

if ~isvector(x)
    error('''x'' must be a vector')
end

if isscalar(frame)
    frame_length = frame;
    window = ones(frame_length,1);
elseif isvector(frame)
    window = frame;
    frame_length = length(frame);
else
    error('''frame'' must be a vector or a scalar')
end

if nargin<3
    mode = 'rms';
end

%% Smooth

% zero pad
x2 = [zeros(ceil((frame_length)/2)-1,1); x(:); zeros(floor(frame_length/2),1)];

% get indexes
index = spdiags(repmat((1:length(x2))',[1 frame_length]),0:-1:-length(x2)+frame_length);

window = repmat(window,[1 length(x)]);

% do calculations
switch lower(mode)
    case 'rms'
        y = sqrt(mean((window.*x2(index)).^2));
    case 'median'
        y = median((window.*x2(index)));
    case 'mean'
        y = nanmean((window.*x2(index)));
    otherwise
        error('Unknown ''mode'' specified')
end

% transpose if necessary
if size(y,1)~=size(x,1)
    y = y';
end

end