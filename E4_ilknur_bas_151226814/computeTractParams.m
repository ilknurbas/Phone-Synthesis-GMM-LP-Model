function tract_filter = computeTractParams(phones_to_synthesize,phone_durations,unique_phones,GMM,fs,lp_order)
% function tract_filter = computeTractParams(phones_to_synthesize,phone_durations,unique_phones,GMM,fs,lp_order)
%
% Creates vocal tract filter parameters using LP coefficients.
%
% Inputs:   
%       phones_to_synthesize:    Nx1 cell array with a list of phone IDs
%       phone_durations:         Nx1 vector with phone durations in ms
%       unique_phones:           a list of speech sounds in LibriSpeech
%       GMM:                     struct containing a trained GMM model
%       fs:                      target sampling rate for synthesized speech (in Hz)
%       lp_order:                order of the LPC (default = 20)
%
% Outputs:
%       tract_filter:            vocal tract filter parameters

if nargin <6
    lp_order = 20;
end

N = length(phones_to_synthesize); % number of phones to synthesize

tract_filter = zeros(round(fs*sum(phone_durations)/1000),21);

sample_pos = 1;
for s = 1:N
    % Pointer to correct phone identity in the GMM model
    phone_index = find(strcmp(unique_phones,phones_to_synthesize{s})); 
  
    % IMPLEMENT: calculate phone duration in samples (same as in computeExcitation.m)
    
    %phone_duration_in_samples = ?
    phone_duration_in_samples = round((phone_durations(s)/1000)*fs);
    
    % IMPLEMENT: sample a MFCC feature vector from the trained GMM 
    %             corresponding to the current sound to be synthesized,
    %             where 'phone_index' points to the right GMM phone model.
    %
    % Hints:
    %   - GMM.weights{phone_index} has the GMM mixture weights for each
    %     component for the given sound
    %   - GMM.means{phone_index} has the GMM component means
    %   - GMM.sigmas{phone_index} has the GMM covariance matrices
    
    % you can just use the mean vector of one random component
    % mfcc_vec = ? 
    size(GMM.weights{phone_index}); % 4     1
    no_components = size(GMM.weights{phone_index},1); % 4
    % this captures the variability 
    GMM_component = randsample(no_components, 1, true, GMM.weights{phone_index}); 
    mfcc_vec = mvnrnd(GMM.means{phone_index}(GMM_component,:),GMM.sigmas{phone_index}(:,:,GMM_component));
    % Function mvnrnd(mean,sigma) allows you to draw random samples from multivariate Gaussian distributions. 
    
    % QUESTION 2.1
    % GMM_component = 1;
    % mfcc_vec = GMM.means{phone_index}(GMM_component,:);
    
    % Convert sampled MFCC vector linear prediction (LP) coefficients at a
    % desired LP order to model the vocal tract configuration during the 
    % sound. Repeat the LP for full duration of the sound.
    % (all steps pre-provided)
    a = mfcc2lpc(mfcc_vec,lp_order,0);     
    
    tract_filter(sample_pos:sample_pos+phone_duration_in_samples-1,:) = repmat(a,phone_duration_in_samples,1);
    
    sample_pos = sample_pos+phone_duration_in_samples;
end


end

