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
%   Radpat_Rms (RMS Radiation Pattern generator for recorded Tiple sounds)
% 
%   Generates an RMS radiation pattern for the Tiple given audio files.
%   You need to provide the following:
% 
%   takes1  - The number of takes for the first distance
%   takes 2 - The number of takes for the second distance
% 
% 
%   NOTE: Create a folder called 'Thesis Audio Files'
%   in the same directory as this function (radpat_rms.m) 
%   that contains all the audio files
% -----------------------------------------------------------------------------
function radpat_rms(takes1, takes2)

% Variable declarations
% ---------------------

% Number of takes  & distances per contraction
distances = 2;

% Set dB limits (for the Z Axis and Color Map)
lowestDB = 0.01;
highestDB = 0.2;


% Data Initialization
% -------------------

% Get directory containing all audio files (sound events)
directory_name = 'Thesis Audio Files';

% Initialize matrices
mat = [];

% Loop though the microphone array/sound events
for d = 1:distances
    figure('name', ['Radiation Patterns for Tiple: Distance of ', num2str(d * 12), ' inches']);
    
    % If we are at 12 inches, average 
    if (d == 1)
        t = takes1;
    else
        t = takes2;
    end
        
    for x = 1:4
        for y = 1:4
            % Read in sound event file
            filename = sprintf('r%dc%d_d%d_mus%d', x, y, d, t);
            filename = [directory_name, '/', filename];
            [hit, fs] = wavread(filename);
            
            % Reshape matrix to correspond to mic array's physical layout
            mat(x, y, :) = reshape(hit, 1, 1, []);
        end
    end
        
    % We now have all the sound events for 1 plot of the 16 mic grid.        
    
    % *********************************************************************    
    % NORMALIZATION SECTION
    % *********************************************************************
    
    % What this is doing is finding a common maximum amongst ALL 16 files
    % (for a single sound event), and then normalize all 16 files
    % according to that factor.
    
    % First, get the maximum value that exists in all 16 files
    max_mat = max(max(max(mat, [], 3)));
    
    % Next, normalize every single sound file with respect to that value
    for row = 1:4
        for column = 1:4
            mat(row, column, :) = mat(row, column, :) / max_mat;
        end
    end
    
    % *********************************************************************
    
    % Get RMS for each element
    MAT = rms(mat, 3);        

    % Maximum and Minimum Mathematics
    [maxCol, indexMaxRow] = max(MAT);
    [maxOverall, indexMaxCol] = max(maxCol);    
    maxRow = indexMaxRow(indexMaxCol);
    micMax = (4 * (maxRow - 1)) + indexMaxCol;
    
    [minCol, indexMinRow] = min(MAT);
    [minOverall, indexMinCol] = min(minCol);    
    minRow = indexMinRow(indexMinCol);
    micMin = (4 * (minRow - 1)) + indexMinCol;
    
    difference = (maxOverall - minOverall);
    
    msgMax = sprintf('Max: %d - Mic %d (Row %d, Col %d)', maxOverall, micMax, maxRow, indexMaxCol);
    msgMin = sprintf('Min: %d - Mic %d (Row %d, Col %d)', minOverall, micMin, minRow, indexMinCol);
    msgDiff = sprintf('Difference: %d', difference);    
    
    % Plot Results
    surf(1:4, 1:4, MAT)
    shading interp
    L = get(gca,'XLim');
    set(gca, 'FontSize', 14) 
    set(gca, 'XMinorTick','on','YMinorTick','on', 'XTick',linspace(L(1),L(2),4), 'YTick',linspace(L(1),L(2),4))
    set(gca, 'XTickLabel', {'0'; '4'; '8'; '12'}, 'YTickLabel', {'0'; '4'; '8'; '12'})        
    title('Musical Passage RMS Pattern')
    axis on
    axis square
    axis image
    xlabel({'Length of Array (inches)', msgMax, msgMin, msgDiff});
    ylabel('Length of Array (inches)')
    zlabel('Amplitude')
    hcb = colorbar;
    colorTitleHandle = get(hcb,'Title');
    colorBarTitle = 'Amplitude';
    set(colorTitleHandle ,'String',colorBarTitle);
        
    % Orient the plot
    view([180,90])  

    % Set dB limits for the Z Axis and Color Map
    zlim([lowestDB, highestDB])
    caxis([lowestDB, highestDB])

    % Save the plot as a figure and as a png image. If required, uncomment.
    % saveas(gca, sprintf('surf_Lower%05d_Center%05d_Upper%05d.fig', round(lowerBound), round(centerFreq), round(upperBound)), 'fig')
    % saveas(gca, sprintf('surf_Lower%05d_Center%05d_Upper%05d.png', round(lowerBound), round(centerFreq), round(upperBound)), 'png')

    % Clear mic array matrix for next plot
    mat = [];        

end
        
end
