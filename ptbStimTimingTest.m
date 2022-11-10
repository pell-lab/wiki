% Based on Bridges D, Pitiot A, MacAskill MR, Peirce JW. 2020. The timing mega-study: 
% comparing a range of experiment generators, both lab-based and online. 
% PeerJ 8:e9414 https://doi.org/10.7717/peerj.9414

% This script is designed to test the trigger-stimulus synchronization accuracy. It does that by:
% % a) presenting a visual + auditory stimulus
% % b) sending an event marker (trigger) immediatly after
% % c) repeating the process n times. 

% You can run the script while saving the event marking data and then test their accuracy 

function ptbTimingTest

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip sync if osx
platform = Screen('Computer');
if platform.osx == true
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% VBLSyncTest
% Screen params
[windowPtr] = Screen('OpenWindow', screenNumber, [0,0,0]);
[screenW, screenH] = Screen('WindowSize', windowPtr);
% Retreive the maximum priority number
topPriorityLevel = MaxPriority(windowPtr);

%%%%%%%%%%%%%%%%%% usb2ttl %%%%%%%%%%%%%%%%%%%%%%%%%%
s = serial('COM6');
set(s, 'BaudRate', 115200, 'DataBits', 8, 'Parity', 'none', 'StopBits', 1, 'FlowControl', 'none', 'Terminator', '');
fopen(s);
fprintf(s, 'RR');  

%%%%%%%%%%%%%%%%%% Visual Stim %%%%%%%%%%%%%%%%%%%%%%
rectW = 400;
rectH = 400;
rectColor = [255, 255 , 255];
rectXPos = (screenW - rectW)/2;
rect = [rectXPos, 0, rectXPos + rectW, rectH];
%%%%%%%%%%%%%%%%%% Visual Stim %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Auditory Stim %%%%%%%%%%%%%%%%%%%%
% Initialize Sounddriver
InitializePsychSound(1);

% Number of channels and Frequency of the sound
nrchannels = 2;
freq = 48000;
repetitions = 1;
% Length of the beep
beepLengthSecs = .2;

% Should we wait for the device to really start (1 = yes)
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
pahandle = PsychPortAudio('Open', [], 1, 3, freq, nrchannels);

% Make a beep which we will play back to the user
myBeep = MakeBeep(400, beepLengthSecs, freq);

% Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);
%%%%%%%%%%%%%%%%%% Auditory Stim %%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Keyboard and RT matrix%%%%%%%%%%%%
escapeKey = KbName('ESCAPE');
%%%%%%%%%%%%%%%%%% Keyboard and RT matrix%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Event Durations %%%%%%%%%%%%%%%%%%
% Visual Stim durations %
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);
isiDuration = round(.3 / ifi, 0);  % In frames
stimDuration = round(.2 / ifi, 0);  % In frames
blankDuration = round(5 / ifi, 0);  % In frames 
waitframes = 1;
nTrials = 100;
%%%%%%%%%%%%%%%%%% Event Durations %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%Blank%%%%%%%%%%%%%%%%%%%%%%%
Priority(topPriorityLevel);
vbl = Screen('Flip', windowPtr);
PsychPortAudio('Start', pahandle, repetitions,0);
PsychPortAudio('Stop', pahandle, 1,1);
for frames = 1:blankDuration
    vbl = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
end
%%%%%%%%%%%%%%%%%%%%%%%%%Blank%%%%%%%%%%%%%%%%startCue%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%Trials%%%%%%%%%%%%%%%%%%%%%%
for trials = 1:nTrials
    % Cue to determine whether a response has been made
    respToBeMade = true;
    FlushEvents('keyDown');

    % blank screen
    for frameN = 1:isiDuration
        vbl = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
    end

    % start audio
    %fprintf(s, '00'); % stop send of trigger
    tWhen = vbl + (waitframes - 0.5) * ifi;
    tPredictedVisualOnset = PredictVisualOnsetForTime(windowPtr, tWhen);
    whenAudioStarted = PsychPortAudio('Start', pahandle, repetitions, tPredictedVisualOnset, 0);
    %display(whenAudioStarted)
    %fprintf(s, '%02X', 1); % send trigger
        
    for frameN = 1:stimDuration
        % Present visual stimuli
        %fprintf(s, '00'); % stop send of trigger
        Screen('FillRect', windowPtr, rectColor, rect);
        vbl = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
        %fprintf(s, '%02X', 2); % send trigger
        
        % set TTL pulse
        if frameN == 1
            fprintf(s, '%02X', 10); % send trigger
        elseif frameN == round(isiDuration/2, 0)
            fprintf(s, '00'); % stop send of trigger
        end;
        
        % check for quit
        if respToBeMade
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyCode(escapeKey)
                ShowCursor;
                sca;
                return
            end;  
        end; 
  
    end

    % Wait for stop of playback
    PsychPortAudio('Stop', pahandle, 0, 0);
    % TURN OFF TTL
                
end;
%%%%%%%%%%%%%%%%%%%%%%%%%Trials%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%Blank%%%%%%%%%%%%%%%%%%%%%%%
vbl = Screen('Flip', windowPtr);
for frames = 1:blankDuration
    vbl = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
end
%%%%%%%%%%%%%%%%%%%%%%%%%Blank%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%Close%%%%%%%%%%%%%%%%%%%%%%
Priority(0);
% Close the audio device
PsychPortAudio('Close', pahandle);
% Close port to usb2ttl
fprintf(s, 'RR');
fclose(s);
delete(s);
clear s
% Clear the screen.
sca;
Screen('CloseAll');
