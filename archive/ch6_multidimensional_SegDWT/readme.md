% Version: 2.10.2012 (the thesis DVD version)
% The code is meant to accompany chapter 6 from [1] and to generate figs.
% B.1-B.5

% [1] PRÙŠA, Zdenìk Segmentwise Discrete Wavelet Transform: doctoral thesis.
% Brno: Brno University of Technology, Faculty of Electrical Engineering and
% Communication, Department of Telecommunications, 2012. 105 p.
% Supervised by Mgr. Pavel Rajmic, Ph.D.
%
% (c) 2012 Zdenìk Prùša
% Dept. of Telecommunications, FEEC, Brno University of Technology, Czech Republic
%
% If you have found any bugs or if you have any questions, remarks, wishes or ideas please contact me at
% zdenek.prusa@gmail.com

% Basically there are 1D,2D and 3D implementations od the new SegDWT
% algorithm from chapter 4.1.4 in [1].
%
% Functions (x=1:3):

%% demoSegDWTxD
% Demo functions showing analysis and sythesis of individual segments covering the whole input signal.

%% testSegDWTxD
% Functions perform analysis and synthesis of a defined segment.
% Coefficient chcking is performed also.

% The above functions call the following wrapper functions working with 1:3D input arrays:

%% readInput

%% extendInput

%% fwdInput

%% inwInput