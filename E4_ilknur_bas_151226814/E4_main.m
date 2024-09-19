% E4_main.m 
% Exercise #4 for Speech Processing (COMP.SGN.340)

clear all

curdir = fileparts(which('E4_main.m')); % determine current folder
addpath([curdir '/aux_scripts/']); % add supplementary scripts
addpath([curdir '/GMM/']); % add GMM solution from E3
addpath([curdir '/sap-voicebox/voicebox/']); % add voicebox toolbox for supplementary scripts


%% Step 0.1) Data pre-processing (pre-provided scripts)

% Load LibriSpeech (CHANGE TO YOUR OWN PATH)
% datapath = '/Users/rasaneno/speechdb/LibriSpeech/';
datapath = '/Users/ilknurbas/Documents/MATLAB/Speech Processing/E4/LibriSpeech/';

% Load LibriSpeech MFCC feature vectors and phone labels, now using all
% data as training data. In contrast to Exercise #3, now MFCC vectors are not
% normalized and do not contain temporal derivatives. 
[x_train,labels_train,x_test,labels_test,unique_phones] = loadLibriData_E4(datapath,1);


%% Step 0.2) Data modeling with a GMM (repetition from Exercise #3).
%
% Note: the classification step can be skipped, but may be useful for
% ensuring that the GMM has learned to model speech sounds with a reasonable 
% accuracy. 

n_comps = 4;

GMM = trainGMM(x_train,labels_train,n_comps,1,30);

% Test GMM in phone classification (on the training data)
[loglik,predicted_labels] = testGMM(x_train,GMM);

% Evaluate
[accuracy,UAR,confmat] = evaluateClassification(predicted_labels,labels_train);

fprintf('Classification accuracy: %0.2f%%.\n',accuracy); %  36.59%.

%% Step 0.3) Define speech sounds to synthesize
%
% Required utterance specifications: 
%
%       'phones_to_synthesize' : Nx1 cell array with a list of phone IDs
%       'voiced'               : Nx1 vector with binary flags denoting
%                                whether the phone is voiced or not
%       'phone_durations'      : Nx1 vector with phone durations in ms
%       'f0'                   : Nx1 vector with F0 of voiced phones (set
%                                to arbitrary value for unvoiced sounds)
%
% See example default utterance below for an example.
%
% Hint: 'unique_phones' contains a list of speech sounds in LibriSpeech.
%       To get help with ARPABET phone code interpretation, see, e.g.:
%       https://isip.piconepress.com/projects/switchboard/doc/education/phone_comparisons/  
%
%
% Default utterance: "She is my friend" with a ~100 Hz male voice.
phones_to_synthesize = {'SH','IY','sil','IH','S','sil','M','AY','sil','F','R','EY','N','D'};
voiced =                [0    1    0     1     0   0    1    1    0    0   1   1    1  0]; 
phone_durations =       [200, 150, 80,  100,  80, 30, 40,  220, 50,  50, 120 200  80, 160]; % in milliseconds
f0 =                    [100  130  100   100   100 100  100  130  100  100 100 120  120 100]; % in Hz      

% Some isolated vowels to test with:
%phones_to_synthesize    = {'AY','IY','EY','OW'};
%voiced                  = [1 1 1 1];
%phone_durations         = [350,350,350,500];
%f0                      = [100 150 200,80];

% Random vowel babbling to test with:
%[phones_to_synthesize, voiced, phone_durations, f0] = babbleGenerator(3);


%% Step 1) Create excitation signal for the speech-to-be-produced
%
% Hints:
%       - Silence can be modeled as zeros or with (very) small amplitude 
%         random numbers.
%       - Voiced excitation must correspond to glottal signal or impulse train
%         that persists throughout the duration of the voiced sound.
%       - Unvoiced excitation can be modeled white Gaussian noise with a
%         suitable amplitude scaling (e.g., using randn()) 
%

% Determine excitation style for voiced sounds
excitation_style = 'impulse'; % 'impulse' / 'glottis'

fs = 16000; % target sampling rate for synthesized speech 

% Call excitation generation function
excitation = computeExcitation(phones_to_synthesize,voiced,phone_durations,f0,fs,excitation_style);

%% Use audiowrite() to create requested .wav files of the created excitations. 

% audiowrite(?,?,?)
if(strcmp(excitation_style,'glottis'))
    audiowrite('excitation_glottal.wav',excitation,fs)
else
    audiowrite('excitation_impulse.wav',excitation,fs)
end


%% Step 2) Create vocal tract parameters for each time-step

tract_filter = computeTractParams(phones_to_synthesize,phone_durations,unique_phones,GMM,fs);

%%
% Plot tract parameters
plotTractParameters(tract_filter);

%% Step 3) synthesize into speech

synthesis_output = computeSynthesisOutput(excitation,tract_filter);

%%
soundsc(synthesis_output,fs);

%% Step 4) Experiment with the synthesis pipeline
%
% No pre-provided code here. See the exercise instructions and use
% audiowrite() to create requested .wav files. 
% audiowrite(?,?,?)

if(strcmp(excitation_style,'impulse'))
    audiowrite('test_synthesis_impulse.wav',synthesis_output,fs)
else 
    audiowrite('test_synthesis_glottal.wav',synthesis_output,fs)
end


%% 
% Random vowel babbling to test with:
% [phones_to_synthesize, voiced, phone_durations, f0] = babbleGenerator(3);
% phones_to_synthesize

% Some isolated vowels to test with:
% phones_to_synthesize    = {'AY','IY','EY','OW'};
% voiced                  = [1 1 1 1];
% phone_durations         = [350,350,350,500];
% f0                      = [100 150 200,80];

% phones_to_synthesize = {'SH','IY','sil','IH','S','sil','M','AY','sil','F','R','EY','N','D'};
% voiced =                [0    1    0     1     0   0    1    1    0    0   1   1    1  0]; 
% phone_durations =       [200, 150, 80,  100,  80, 30, 40,  220, 50,  50, 120 200  80, 160];
% f0 =                    [100  130  100   100   100 100  100  130  100  100 100 120  120 100];

% ERIN S RED MOON
phones_to_synthesize    = {'EH','R','IH','N','Z','sil','R','EH','D','sil','M','UW','N'};
f0                      = [127  100 120 120 120  100  100  127 100  100  100  230 120];  
voiced                  = [ 1    1    1   1   1    0    1    1   1    0    1   1    1];  
phone_durations         = [100  70   70  50   90   70   70  90   60  90   70   90   80]; % 1sec = 1000ms

excitation_style_custom = ['impulse' , 'glottis'];

fs = 16000; % target sampling rate for synthesized speech 
for style=1:2
    if style==1 
        x = 'impulse';
    else 
        x = 'glottis';
    end 
    excitation_custom = computeExcitation(phones_to_synthesize,voiced,phone_durations,f0,fs,x);
    tract_filter = computeTractParams(phones_to_synthesize,phone_durations,unique_phones,GMM,fs);
    plotTractParameters(tract_filter);
    if style==1 
        custom_synthesis_impulse = computeSynthesisOutput(excitation_custom,tract_filter);
        audiowrite('custom_synthesis_impulse.wav',custom_synthesis_impulse,fs)
    else 
        custom_synthesis_glottis = computeSynthesisOutput(excitation_custom,tract_filter);
        audiowrite('custom_synthesis_glottis.wav',custom_synthesis_glottis,fs)
    end
end

%%
soundsc(custom_synthesis_impulse,fs);

%%
soundsc(custom_synthesis_glottis,fs);




