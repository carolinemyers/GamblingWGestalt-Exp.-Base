%%  Hello
%%% Gambling with Gestalt: Experiment 1
%Written by Caroline Myers (contact: cfm304@nyu.edu) 
%New York University
%Carrasco Lab
%August 2019. 
%Version history: D26

%This program was written by Caroline Myers. It executes and records
%in-line behavioral response subject data. 
%Inputs: SID, Block, Date, SInitials
%Outputs: SID, Coordinate locations of point A, B, TP (true point), SP
%(subjective point- provided by user), RT (matlab), RT (PTB), accuracy,
%reward value, 
%% 00 init
clear all
close all
clc
%% ENTER PARTICIPANT ID
subjectID = 1; %%%%%%%%CHANGE ME HERE!
blockNumber = 1; %%%%%%%%CHANGE ME HERE!
date = 083019; %%%%%%%CHANGE ME HERE!
subInit = 'BTA'; %%%%CHANGE ME HERE!

trialss = xlsread('trials.xlsx','Sheet1');
condtable = nan(length(trialss),7)
%% Partinfo
AssertOpenGL;

if ~exist('subjectID','var')
    subjectID=100;
end
%warn if duplicate sub ID
fileName =['InterpolExp1Subj' num2str(subjectID) (subInit) 'block' num2str(blockNumber) 'day' num2str(date) '.txt'];
if exist(fileName,'file')
    if ~IsOctave
        resp=questdlg({['This file' fileName 'already exists']; 'Press ok to overwrite'},...
            'duplicate warning','cancel','ok','ok');
    else
        resp=input(['the file ' fileName ' already exists. do you want to overwrite it? [Type ok for overwrite]'], 's');
    end
    
    if ~strcmp(resp,'ok') %abort experiment if cancelled
        disp('ABORT!')
        return
    end
end

%% Cond table
nconds=(size(condtable,1)); %number of conditions. sorta. Stim pairings. 
ntrain=0;%number of training trials

nTrialsAll = 20; %%%%%%CHANGE ME :)
shuffeldTrialIDs = randperm(nTrialsAll); %Permutations of total number of trials
order = mod(shuffeldTrialIDs,nconds); %But we have 20 conditions
order = order + 1;

%create a vector array of random numbers to randomize MP starting location
%on Y axis
randomStartingPointY = 300 + (600-300)*rand(nTrialsAll,1); %r = a + (b-a).*rand(N,1).

%order=[ceil(rand(1,ntrain)*ntrials), shuffeldTrialIDs];%attach a randomly drawn subsample as training trials

% output data file
Headers = {'subjid',	'ntrain',	'order',	'axind',	'ayind',	'bxind',	'byind',	'tpxind'	,'tpyind',	'SPx',	'Spy','anscorrect',	'rt','mlrt','YStartPoint','earnings'};
data = NaN * ones((length(order)-ntrain),length(Headers)); %preallocate results matrix

%Create a vector array to keep track of total participant earnings
earnings = zeros((length(order)-ntrain),1)
%% Now exp
try
    KbName('UnifyKeyNames'); %unify keyboard inputs
    KbCheck;
    ListenChar(2);%disable Matlab key output
    escapeKey = KbName('ESCAPE');
    upKey = KbName('UpArrow');
    downKey = KbName('DownArrow');
    olddebuglevel=Screen('Preference', 'VisualDebuglevel', 3);%Set higher DebugLevel
    screens=Screen('Screens');
    screenNumber=max(screens);
    [widthSc, heightSc]=Screen('WindowSize', max(screens));
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('WindowSize',screenNumber)
    
    %%%%%%%%%%%%%%%%%%%%%%%%FULL SCREEN: comment one out %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [expWin,rect]=Screen('OpenWindow',screenNumber);% full screen
    
    %%%%%%%%%%%%%%%%%%%%%%%% WINDOW: comment one out %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %[expWin,rect]=Screen('OpenWindow',screenNumber,[],[0 0 1440 900]);
    
    [mx, my] = RectCenter(rect); %get the midpoint (mx, my) of this window, x and y

    condtable = nan(length(trialss),7)
    for ii = 1:length(trialss)
        condtable(ii,1) = trialss(ii,1)
        condtable(ii,2) = mx - trialss(ii,2)
        condtable(ii,3) = my - trialss(ii,3)
        condtable(ii,4) = mx - trialss(ii,4)
        condtable(ii,5) = my - trialss(ii,5)
        condtable(ii,6) = mx - trialss(ii,6)
        condtable(ii,7) = my - trialss(ii,7)
    end
    %% Preparing and displaying the instruction screens
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Instruction screen 1 %%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize', expWin, 24);
    myText = ['In this experiment you will be presented with two stable points that lie on an imaginary line.\n' ...
        ' \n' ...
        'Your task is to use the arrow keys to place a third moveable point so that it lies along the line. \n' ...
        ' \n' ...
        'The object of your task is to place the point as close to the line as possible.   \n' ...
        ' \n' ...
        'After each trial, you will receive a monetary reward. The closer you place the point to the line, the greater the reward.\n' ...
        ' \n' ...
        'Press any key to continue to the next page.'];
    
    DrawFormattedText(expWin, myText, 'center', 'center');% Draw 'myText', centered in the display window:
    Screen('Flip', expWin); %flip at next refresh
    KbWait([], 3);% Wait for key stroke.
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Instruction screen 2 %%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize', expWin, 24);
    myText = ['Press the UP arrow key to move the point up. \n' ...
        ' \n' ...
        '  Press the DOWN arrow key to move the point down.\n' ...
        ' \n' ...
        ' \n' ...
        ' \n' ...
        '  When you have placed the point so that it best completes the line, press the RIGHT arrow key to proceed to the next trial.\n' ...
        ' \n' ...
        ' \n' ...
        'Press any key to begin the experiment.\n' ];
    DrawFormattedText(expWin, myText, 'center', 'center');% Draw 'myText', centered in the display window
    
    
    Screen('Flip', expWin);% Show text at next display refresh
    KbWait([], 3);% Wait for key stroke.
    
    for ii=1:length(order)
        if ii==ntrain+1  %before the first test trial
            DrawFormattedText(expWin, 'Are you ready for the experiment?\n Press any key to start.', 'center', 'center');%U ready dude?
            Screen('Flip', expWin);%flip to front buffer
            KbWait([], 3);%wait for UI
        end
        condInd = (condtable(order(ii),(1)));% Copy the content of the previously prepared texture or offscreenWindow % into the backbuffer of the onscreen window, then flip it to the front
        AxInd = (condtable(order(ii),(2)));
        AyInd = (condtable(order(ii),(3)));
        BxInd = (condtable(order(ii),(4)));
        ByInd = (condtable(order(ii),(5)));
        TPxInd = (condtable(order(ii),(6)));
        TPyInd = (condtable(order(ii),(7)));
        [xCenter, yCenter] = RectCenter(rect);% Get the centre coordinate of the window
        
        baseRect = [0 0 4 4];% Make the size of the point to be 4x4
        rectColor = [0 0 255];%make it blue
        squareX = xCenter; %x coordinates remain the same, in the center of the screen
        squareY = randomStartingPointY(ii); %use our rand array to randomize starting point for MP
        pixelsPerPress = .2; %how many pixels should our point move per press?
        
        waitframes = 1;
        exitDemo = false;  % This is the cue which determines whether we exit the demo
        escapeKey = KbName('ESCAPE');
        upKey = KbName('UpArrow');
        downKey = KbName('DownArrow');
        rightKey = KbName('RightArrow');
        % Loop the animation until the escape key is pressed
        while exitDemo == false; %until user presses right arrow key

            [keyIsDown,secs, keyCode] = KbCheck; %Check the keyboard to see if a button has been pressed

            if keyCode(rightKey);
                [SPx,SPy] = RectCenter(centeredRect);%Returns the integer x,y coordinates of center. Vectorized.
                data(ii,1) = subjectID;
                data(ii,2) = ii - ntrain;
                data(ii,3) = order(ii);
                data(ii,4) = AxInd;
                data(ii,5) = AyInd;
                data(ii,6) = BxInd;
                data(ii,7) = ByInd;
                data(ii,8) = TPxInd;
                data(ii,9) = TPyInd;
                data(ii,10) = SPx;
                data(ii,11) = SPy;
                data(ii,13) = rt;
                data(ii,14) = MLrt;
                data(ii,15) = randomStartingPointY(ii);
                exitDemo = true; %exit while statement
                if SPy == TPyInd;
                    anscorrect = 1;
                    data(ii,12) = 1;
                    earnings(ii) = 5;
                    Beeper('high', [.4], [.15]);
                elseif SPy == TPyInd -1 || SPy == TPyInd +1;
                    anscorrect = 2;
                    data(ii,12) = 0;
                    earnings(ii) = 3;
                    Beeper('med', [.4], [.15]);
                elseif SPy == TPyInd -3 || SPy == TPyInd +3;
                    anscorrect = 3;
                    data(ii,12) = 0;
                    earnings(ii) = 1;
                    Beeper('med', [.4], [.15]);
                else
                    anscorrect = 0;
                    data(ii,12) = 0;
                    Beeper('med', [.4], [.15]);
                end
            elseif keyCode(upKey)
                squareY = squareY - pixelsPerPress;
                
            elseif keyCode(downKey)
                squareY = squareY + pixelsPerPress;
            end
            
            centeredRect = CenterRectOnPointd(baseRect, squareX, squareY);% Center the rectangle on the centre of the screen
            
            Screen('glPoint', expWin, [0 0 0], (AxInd),(AyInd),[,5]);%draw point A stim into backbuffer
            Screen('glPoint', expWin, [0 0 0], (BxInd),(ByInd),[,5]);%draw point B stim into backbuffer
             Screen('glPoint', expWin, [0 0 255], (squareX),(squareY),[,5]);
            %Screen('FillRect', expWin, rectColor, centeredRect);%draw MP stim into backbuffer
            
            [VBLTimestamp, StimulusOnsetTime, FlipTimestamp]=Screen('Flip', expWin);
            tic; % timestamps are not the same, e.g. plot([VBLTimestamp StimulusOnsetTime FlipTimestamp tic])
            
            [resptime, keyCode] = KbWait;
            MLrt=toc; %Matlab response time
            rt=resptime-StimulusOnsetTime; %PTB response time, uses stimonset
            cc=KbName(keyCode);  %find out which key was pressed, translate code into str
        end
        exitDemo = true;
        if anscorrect == 1;
            DrawFormattedText(expWin, ['You placed the point on the line. You have earned $5 this trial.\n' ...
                ' \n' ...
                'You have earned $' num2str(sum(earnings)) ' so far. \n' ...
                ' \n' ...
                ' \n' ...
                'Press any key to start next trial.'], 'center', 'center');
            Screen('Flip', expWin);
            KbWait([], 3); %wait for keystroke
        elseif anscorrect == 2
            Screen('glPoint', expWin, [0 0 0], (AxInd),(AyInd),[,5]);
            Screen('glPoint', expWin, [0 0 0], (BxInd),(ByInd),[,5]);
            Screen('FillRect', expWin, rectColor, centeredRect);
            Screen('glPoint', expWin, [255 0 0], (TPxInd),(TPyInd),[,5]);
            Screen('Flip', expWin);
            WaitSecs(.6);
            DrawFormattedText(expWin, ['You placed the point within 1 pixel of the line. You have earned $3 this trial.\n' ...
                ' \n' ...
                'You have earned $' num2str(sum(earnings)) ' so far. \n' ...
                ' \n' ...
                ' \n' ...
                'Press any key to start next trial.'], 'center', 'center');
            Screen('Flip', expWin);
            KbWait([], 3); %wait for keystroke
            
        elseif anscorrect == 3
            Screen('glPoint', expWin, [0 0 0], (AxInd),(AyInd),[,5]);
            Screen('glPoint', expWin, [0 0 0], (BxInd),(ByInd),[,5]);
            Screen('glPoint', expWin, [0 0 255], (squareX),(squareY),[,5]);
            %Screen('FillRect', expWin, rectColor, centeredRect);
            Screen('glPoint', expWin, [255 0 0], (TPxInd),(TPyInd),[,5]);
            
            Screen('Flip', expWin);
            WaitSecs(.6)
            DrawFormattedText(expWin, ['You placed the point within 3 pixels of the line. You have earned $1 this trial.\n' ...
                ' \n' ...
                'You have earned $' num2str(sum(earnings)) ' so far. \n' ...
                ' \n' ...
                ' \n' ...
                'Press any key to start next trial.'], 'center', 'center');
            Screen('Flip', expWin);
            KbWait([], 3); %wait for keystroke
            
            
        elseif anscorrect == 0;
            Screen('glPoint', expWin, [0 0 0], (AxInd),(AyInd),[,5]);
            Screen('glPoint', expWin, [0 0 0], (BxInd),(ByInd),[,5]);
            Screen('glPoint', expWin, [0 0 255], (squareX),(squareY),[,5]);
            %Screen('FillRect', expWin, rectColor, centeredRect);
            Screen('glPoint', expWin, [255 0 0], (TPxInd),(TPyInd),[,5]);
            
            Screen('Flip', expWin);
            WaitSecs(.6);
            DrawFormattedText(expWin, ['You did not place the point close enough to the line. You have earned $0 this trial.\n' ...
                ' \n' ...
                'You have earned $' num2str(sum(earnings)) ' so far. \n' ...
                ' \n' ...
                ' \n' ...
                'Press any key to start next trial.'], 'center', 'center');
            Screen('Flip', expWin);
            KbWait([], 3); %wait for keystroke
        end
    end %of trials loop
    cd(data.Data);
    filename = ['InterpolExp1Subj' num2str(subjectID) 'block' num2str(blockNumber) '_data.mat'];
    save(filename, 'data')
    cd('..')
end
accuracy = sum((data(:,12))/(length(data)));
accuracypercent = accuracy.*100;
earningsSum = sum(earnings(:,1));
DrawFormattedText(expWin, ['This is the end of this block.\n'...
    'Your accuracy was ' num2str(accuracypercent) ' %' ...
                ' \n' ...
'Your total earnings for this block amount to $' num2str(earningsSum) '! \n'...                
                ' \n' ...
'Please find the experimenter!'], 'center', 'center');
Screen('Flip', expWin);
KbWait([], 2); %wait for keystroke

%% restore
ShowCursor;
sca;
ListenChar(0);%turn matlab key output back on
Screen('Preference', 'VisualDebuglevel', olddebuglevel);%return to olddebuglevel
%% Table
subjidVals = data(:,1);
ntrainVals = data(:,2);
orderVals = data(:,3);
AxindVals = data(:,4);
AyindVals = data(:,5);
BxindVals = data(:,6);
ByindVals = data(:,7);
TPxindVals = data(:,8);
TPyindVals = data(:,9);
SPxVals = data(:,10);
SPyVals = data(:,11);
anscorrectVals = data(:,12);
rtVals = data(:,13);
mlrtVals = data(:,14);
MPStartingYPosVals = data(:,15);
EarningsVals = earnings(:);
DataTable = table(subjidVals,ntrainVals,orderVals,AxindVals,AyindVals,BxindVals,ByindVals,TPxindVals,TPyindVals,SPxVals,SPyVals,anscorrectVals,rtVals,mlrtVals,MPStartingYPosVals,earnings);

fileNameTxt=['InterpolExp1Subj' num2str(subjectID) (subInit) 'block' num2str(blockNumber) 'day' num2str(date) '.txt'];
fileNameXLS=['InterpolExp1Subj' num2str(subjectID) (subInit) 'block' num2str(blockNumber) 'day' num2str(date) '.xls'];
writetable(DataTable,fileNameTxt);
writetable(DataTable,fileNameXLS,'Sheet',1,'Range','A1');

fileName =['InterpolExp1Subj' num2str(subjectID) (subInit) 'block' num2str(blockNumber) 'day' num2str(date) '.txt'];
