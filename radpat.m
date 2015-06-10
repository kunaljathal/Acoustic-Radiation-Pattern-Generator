% ***************************************************************************
%
%   The Colombian Tiple: Sound Radiation Patterns and Implications for 
%   Amplification and Recording Strategies
% 
%   Juan Jose Cardona Bernat
%   
%   Submitted in partial fulfillment of the requirements for the Master in 
%   Music Technology in the Department of Music and Performing Arts Professions 
%   in the Steinhardt School%   Masters of Music Technology, New York University
%
%   Code written by: Kunal Jathal 
% 
% ****************************************************************************

% ----------------------------------------------------------------------------
%   Radpat (Frequency Radiation Pattern generator for recorded Tiple sounds)
% 
%   Generates a frequency radiation pattern for the Tiple given audio files.
%   You need to provide the following:
% 
%   contraction - 'low', 'mid', 'hig', 'har', 'lop', 'mip', 'hip', 'hap'
%   midBand     -  the center frequency around which you want to focus the plot
%   bandWidth   -  total bandwidth around the center frequency
% 
%   NOTE: Create a folder called 'Thesis Audio Files'
%   in the same directory as this function (radpat.m) 
%   that contains all the audio files
% -----------------------------------------------------------------------------
function radpat(contraction, midBand)

% Variable declarations
% ---------------------

% Number of takes, harmonics (incl fund freq), & distances per contraction
takes = 3;   
distances = 2;
harmonics = 1 + 3;

% Set dB limits (for the Z Axis and Color Map)
lowestDB = -5;
highestDB = 15;

% Octave band factor
octaveBand = 12 * 2;

% Contractions - commented because they are called by user explicitly
% contractions = ['low', 'mid', 'hig', 'har', 'lop', 'mip', 'hip', 'hap'];


% Data Initialization
% -------------------

% Get directory containing all audio files (sound events)
directory_name = 'Thesis Audio Files';

% Initialize matrices
mat = [];
avg_mat = [];

% FFT Parameters 
fftSize = 0;
fftLength = 2^fftSize;

% Loop though the microphone array/sound events
for d = 1:distances
    figure('name', ['Radiation Patterns for Tiple: Distance of ', num2str(d * 12), ' inches']);
    
for h = 1:harmonics    
    
    % Get frequency ranges to display
    centerFreq = midBand * h;
    lowerBound = centerFreq / (2^(1/octaveBand));
    upperBound = centerFreq * (2^(1/octaveBand));
        
    for t = 1:takes
        for x = 1:4
            for y = 1:4
                % Read in sound event file
                filename = sprintf('r%dc%d_d%d_%s%d', x, y, d, contraction, t);
                filename = [directory_name, '/', filename];
                [hit, fs] = wavread(filename);
                
                % Set FFT length: since all takes are the same length, set
                % the window size only once
                if (fftSize == 0)
                    fftSize = nextpow2(length(hit));
                    fftLength = 2^fftSize;
                end
                
                % 'Window' the sound file. Since each sound file is
                % essentially a transient signal that starts with silence
                % (~0) at the beginning of the time window and then rises
                % to some maximum and decays again to silence (~0) before
                % the end of the time window, it satisfies the periodic
                % requirement. So a special windowing function isn't
                % necessary.
                hit(1) = 0;
                hit(fftLength) = 0;

                % Reshape matrix to correspond to mic array's physical layout
                mat(x, y, :) = reshape(hit, 1, 1, []);
            end
        end
        
        % We now have all the sound events for 1 plot of the 16 mic grid.        
        
        % Get FFT magnitudes
        MAT = (abs(fft(mat, fftLength, 3)));        

        % Get 'full range' x axis for frequency plot
        freqVectTest = linspace(0, fs/2, size(MAT, 3)/2);

        % Get true lower and upper x axis limits wrt frequency bounds
        [minArray, lowerIndx] = min(abs(lowerBound - freqVectTest));
        lowerIndx = lowerIndx(1);

        [minArray, upperIndx] = min(abs(upperBound - freqVectTest));
        upperIndx = upperIndx(1);
                
        % Fill in the average matrix of the FFT for each microphone spot
        avg_mat(:, :, t) = mean(MAT(:, :, lowerIndx:upperIndx), 3);
        
        % Clear mic array matrix for next plot
        mat = [];        

    end
    
    % Convert plot into dB, by averaging/collapsing the 3rd dimension

    % *********************************************************************    
    % NORMALIZATION SECTION
    % *********************************************************************
    
    % What this does is normalize the final *averaged* FFTs. This is almost
    % equivalent to simply modifying the color bar - the only difference is
    % that, the color bar scale is in dB, whereas the FFT is not. Uncomment
    % if required.
    
    % BAND_AVG = mean(avg_mat, 3);
    % normalizationFactor = max(max(BAND_AVG));
    % BAND_AVG = BAND_AVG / normalizationFactor;
    % BAND = 10*log10(BAND_AVG);

    % *********************************************************************

    
    % *********************************************************************
    % STANDARD SECTION
    % *********************************************************************
    
    BAND = 10*log10(mean(avg_mat, 3));    
    
    % *********************************************************************
    
    % Maximum and Minimum Mathematics
    [maxCol, indexMaxRow] = max(BAND);
    [maxOverall, indexMaxCol] = max(maxCol);    
    maxRow = indexMaxRow(indexMaxCol);
    micMax = (4 * (maxRow - 1)) + indexMaxCol;
    
    [minCol, indexMinRow] = min(BAND);
    [minOverall, indexMinCol] = min(minCol);    
    minRow = indexMinRow(indexMinCol);
    micMin = (4 * (minRow - 1)) + indexMinCol;
    
    difference = round(maxOverall - minOverall);
    maxOverall = round(maxOverall);
    minOverall = round(minOverall);
    
    msgMax = sprintf('Max: %d dB - Mic %d (Row %d, Col %d)', maxOverall, micMax, maxRow, indexMaxCol);
    msgMin = sprintf('Min: %d dB - Mic %d (Row %d, Col %d)', minOverall, micMin, minRow, indexMinCol);
    msgDiff = sprintf('Difference: %d dB', difference);
        
    % Divide window into a horizontal grid of the number of total takes
    subplot(1, harmonics, h);
    surf(1:4, 1:4, BAND)
    shading interp
    L = get(gca,'XLim');
    set(gca, 'FontSize', 14) 
    set(gca, 'XMinorTick','on','YMinorTick','on', 'XTick',linspace(L(1),L(2),4), 'YTick',linspace(L(1),L(2),4))                
    set(gca, 'XTickLabel', {'0'; '4'; '8'; '12'}, 'YTickLabel', {'0'; '4'; '8'; '12'})        
    title({contractionName(contraction), ['Centered at ', num2str(centerFreq), ' Hz - ', harmonicName(h)]})
    axis on
    axis square
    axis image
    xlabel({'Length of Array (inches)', msgMax, msgMin, msgDiff})
    ylabel('Length of Array (inches)')
    zlabel('dB')
        
    % Orient the plot
    view([180,90])  

    % Set dB limits for the Z Axis and Color Map
    zlim([lowestDB, highestDB])
    caxis([lowestDB, highestDB])

    % Save the plot as a figure and as a png image. If required, uncomment.
    % saveas(gca, sprintf('surf_Lower%05d_Center%05d_Upper%05d.fig', round(lowerBound), round(centerFreq), round(upperBound)), 'fig')
    % saveas(gca, sprintf('surf_Lower%05d_Center%05d_Upper%05d.png', round(lowerBound), round(centerFreq), round(upperBound)), 'png')
end

hcb=colorbar('Southoutside');
set(hcb, 'Position', [.1 .15 .8150 .05]);
colorTitleHandle = get(hcb,'Title');
colorBarTitle = 'Power (dB)';
set(colorTitleHandle ,'String',colorBarTitle);
        
end

end

% ----------------------------------------------------------------------------
%   contractionName 
% 
%   Returns the contraction full name given the abbreviation.
% -----------------------------------------------------------------------------
function c = contractionName(abbreviation)
    
switch (abbreviation)
    case 'low'
        c = 'Low Strummed Chord';
    case 'mid'
        c = 'Mid Range Strummed Chord';
    case 'hig'
        c = 'High Range Chord';
    case 'lop'
        c = 'Low Pulsed Chord';
    case 'mip'
        c = 'Mid Range Pulsed Chord'
    case 'hip'
        c = 'High Range Pulsed Chord';
    case 'hap'
        c = 'Harmonics Pulsed Chord';
    case 'har'
        c = 'Harmonics Strummed Chord';
    case 'mus'
        c = 'Musical Passage';
    otherwise
        error('Invalid Contraction entered.');
end    

end

% ----------------------------------------------------------------------------
%   harmonicName 
% 
%   Returns the Harmonic Description given the abbreviation.
% -----------------------------------------------------------------------------
function h = harmonicName(abbreviation)
    
switch (abbreviation)
    case 1
        h = 'Fundamental Frequency';
    case 2
        h = 'First Harmonic';
    case 3
        h = 'Second Harmonic';
    case 4
        h = 'Third Harmonic';
    otherwise
        error('Invalid harmonic entered.');
end    

end


