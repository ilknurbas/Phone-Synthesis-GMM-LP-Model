function excitation = computeExcitation(phones_to_synthesize,voiced,phone_durations,f0,fs,excitation_style,glottis_file)
% function excitation = computeExcitation(phones_to_synthesize,voiced,phone_durations,f0,fs,excitation_style,glottis_file)
%
% Creates an excitation signal for the speech-to-be-produced.
%
% Inputs:   
%       phones_to_synthesize:     Nx1 cell array with a list of phone IDs
%       voiced:                   Nx1 vector with binary flags denoting
%                                 whether the phone is voiced or not
%       phone_durations:          Nx1 vector with phone durations in ms
%       f0:                       Nx1 vector with F0 of voiced phones (set
%                                 to arbitrary value for unvoiced sounds)
%       fs:                       sampling rate (in Hz)
%       excitation_style:         excitation style for voiced sounds ('impulse' / 'glottis')
%       glottis_file:             the file from which a pre-provided glottis pulse is loaded
%
% Outputs:
%       excitation:               excitation signal

if nargin <7
    glottis_file = 'glottis_long.wav';
end


N = length(phones_to_synthesize); % number of phones to synthesize

% Load glottis excitation and resample to match target audio sampling rate
if(strcmp(excitation_style,'glottis'))
    [x_glott,fs_glott] = audioread(glottis_file);
    x_glott = resample(x_glott,fs,fs_glott);
end

% Initialize an empty excitation vector whose total duration corresponds to
% summed duration of phones-to-be-synthesized
excitation = zeros(round(fs*sum(phone_durations)/1000),1);

% Iterate through pre-defined phones and create corresponding segment of
% excitation for each. 
sample_pos = 1;
for s = 1:N
        
    % IMPLEMENT: calculate phone duration in samples
    %phone_duration_in_samples = ?
    phone_duration_in_samples = round((phone_durations(s)/1000)*fs);
    
    % IMPLEMENT :
    % Create excitation signals for four types of cases: silent segments,
    % unvoiced segments, and voiced segments with impulse train, and voiced
    % segments with glottal excitation. 
            
    
    if(strcmp(phones_to_synthesize{s},'sil'))
        % IMPLEMENT: Create excitation for silence segments (Case 1)
        %excitation_phone = ? silence (or inaudible noise levels)
        excitation_phone = zeros(phone_duration_in_samples,1);
        
    elseif(~voiced(s))
        % IMPLEMENT: Create excitation for voiceless sounds (Case 2)        
        %excitation_phone = ? white noise
        excitation_phone = rand(phone_duration_in_samples,1);
        % manual tunning
        % excitation_phone = excitation_phone * 0.1;
         
        
    elseif(voiced(s))
    % IMPLEMENT: Create excitation for voiced sounds (Cases 3 and 4)
      
        if(strcmp(excitation_style,'impulse'))
            % Create impulse train with impulses at the given F0 period
            %excitation_phone = ?
            impulse_train = zeros(phone_duration_in_samples, 1);
            period = round(fs/f0(s));
            impulse_train(1:period:end) = 1;
            excitation_phone = impulse_train;
            
            
        elseif(strcmp(excitation_style,'glottis'))
            % Create correct-length glottal excitation from the existing
            % waveform in x_glott, and resample to desired F0 with resample()..
            % Original F0 of the glottal signal is approx. 114 Hz.
            % For simplcity, you can use first M samples of the excitation signal.
            
            %excitation_phone = ?
            f0_glott = 114; % this is f0 of the pre-recorded excitation 114Hz
            resampled_glottis = resample(x_glott, f0(s), f0_glott);
            excitation_phone = resampled_glottis(1:phone_duration_in_samples);
            
            
        end
    else
        error('unknown voicing specification');
    end
    
    % Add the current excitation segment to the overall excitation vector
    excitation(sample_pos:sample_pos+phone_duration_in_samples-1) = excitation_phone;
    
    sample_pos = sample_pos+phone_duration_in_samples;
end

sum(phone_durations)/1000==length(excitation)/fs % 1

