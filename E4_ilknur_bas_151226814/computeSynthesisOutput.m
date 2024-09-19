function synthesis_output = computeSynthesisOuput(excitation,tract_filter,lp_order)
% function synthesis_output = computeSynthesisOuput(excitation,tract_filter,lp_order)
%
% Creates synthetic speech using an excitation signal and LP vocal tract
% parameters.
%
% Inputs:   
%       excitation:           excitation signal
%       tract_filter:         LP vocal tract parameters
%       lp_order:             order of the LPC (default = 20)
%
% Outputs:
%       synthesis_output:     synthesized output

if nargin <3
    lp_order = 20;
end

synthesis_output = zeros(size(excitation));

for n = lp_order+1:length(excitation)
    % IMPLEMENT: Implement LP synthesis as an IIR filtering loop using the
    % excitation signal and vocal tract parameters generated above.
    % Filtering should be performed sample-by-sample.
    % 
    % Hint:
    %   - LP parameters from Step 2) are in FIR form with the trivial 0:th
    %     coefficient (value = 1). See the exercise document for details how
    %     to apply the LP coefficients as an IIR filter. 
    %    
    
    %synthesis_output(n) = ? 
    size(tract_filter(n,2:end)); % 1    20
    size(synthesis_output(n-1:-1:n-lp_order)); % 20     1
    size(sum(tract_filter(n,2:end)*synthesis_output(n-1:-1:n-lp_order))); % 1     1
    synthesis_output(n) = excitation(n) - sum(tract_filter(n,2:end)*synthesis_output(n-1:-1:n-lp_order));

   

end

end

