%% Step-4: Eliminate Repeated Spots for Top and Bottom Files Automatically
clc;

%% === Input Parameters ===
file_prefix = 'Test_SiMRoD'; % Change this if your files have a different prefix
outputFolderPath = '/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/'; % Folder where output will be saved

frameColumnIndex = 1;
xColumnIndex = 2;
yColumnIndex = 5;
signalIntensityColumnIndex = 8;

numFramesToConsider = 0; % Number of frames each spot lasts during acquisition
xThreshold = 20; % Threshold in nm
yThreshold = 20; % Threshold in nm

%% === Process Both Files ===
channel_types = {'top', 'bottom'};

for idx = 1:length(channel_types)
    channel = channel_types{idx};
    
    inputTextFileName = [file_prefix 'overall_' channel '2.txt'];
    outputListFileName = [file_prefix 'overall_' channel '2_sorted.txt'];
    outputStatisticsFileName = [file_prefix 'overall_' channel '2_statistics.txt'];
    
    fprintf('Processing %s file...\n', channel);
    
    % === Read the input file ===
    array2D = dlmread([outputFolderPath inputTextFileName]);
    numSpots = size(array2D, 1);
    linkedLists = cell(numSpots, 1);

    for k = 1:numSpots
        linkedLists{k} = dlnode(array2D(k,:));
    end

    % === Main Processing ===
    counter = 1;
    while (counter < length(linkedLists))
        currentNode = linkedLists{counter};
        currentFrame = currentNode.Data(frameColumnIndex);
        flag = true;
        innerCounter = counter;
        candidateNodes = [];
        while (flag)
            innerCounter = innerCounter + 1;
            if innerCounter <= length(linkedLists)
                nextNode = linkedLists{innerCounter};
                nextFrame = nextNode.Data(frameColumnIndex);
                frameDifference = nextFrame - currentFrame;
                if (frameDifference > 0 && frameDifference <= numFramesToConsider)
                     [sameSpot, distance] = compareNodes(currentNode, nextNode, xColumnIndex, yColumnIndex, xThreshold, yThreshold);
                     if (sameSpot)
                         candidateNodes = [candidateNodes; nextFrame, distance, innerCounter];
                     end
                else
                    flag = false;
                end
            else
                flag = false;
            end
        end
        
        % Handle duplicates in same frame
        idx2 = 1;
        while (idx2 < size(candidateNodes,1))
            node1 = candidateNodes(idx2,:);
            node2 = candidateNodes(idx2 + 1,:);
            if node1(1) == node2(1)
                if node1(2) >= node2(2)
                    candidateNodes(idx2,:) = [];
                else
                    candidateNodes(idx2 + 1,:) = [];
                end
            else
                idx2 = idx2 + 1;
            end
        end
        
        % Insert after currentNode and remove from linkedLists
        if size(candidateNodes,1) > 0
            for k = size(candidateNodes,1):-1:1
                insertAfter(linkedLists{candidateNodes(k,3)}, currentNode);
                linkedLists(candidateNodes(k,3)) = [];
            end
        end
        
        counter = counter + 1;
    end

    % === Save Statistics ===
    statisticsFileID = fopen([outputFolderPath, outputStatisticsFileName], 'w');
    fprintf(statisticsFileID, 'Tracks of repeat occurrences identified by frame number: \n\n');
    numUniqueSpots = length(linkedLists);
    numOccurrences = ones(numUniqueSpots, 1);
    for k = 1:numUniqueSpots
        node = linkedLists{k};
        frameNumbers = num2str(node.Data(frameColumnIndex));
        while ~isempty(node.Next)
            node = node.Next;
            frameNumbers = [frameNumbers, ' ', num2str(node.Data(frameColumnIndex))];
            numOccurrences(k) = numOccurrences(k) + 1;
        end
        fprintf(statisticsFileID,'%s\n', frameNumbers);
    end
    fprintf(statisticsFileID, '\n\n\n');
    fprintf(statisticsFileID, ['Number of unique spots: ', num2str(numUniqueSpots)]);
    fprintf(statisticsFileID, '\n\n');
    for k = 1:numFramesToConsider + 1
        frequency = sum(numOccurrences == k);
        fprintf(statisticsFileID, '%s\n', ['Frequency of ', num2str(k), ' occurrences : ', ...
                    num2str(frequency), ' (', num2str(sprintf('%.2f', frequency / numUniqueSpots * 100)), '%)']);
    end
    fclose(statisticsFileID);

    % === Save Final Filtered List ===
    nodeToKeep = cell(numUniqueSpots, 1);
    for k = 1:numUniqueSpots
        nodeToKeep{k} = determineNodeToKeep(linkedLists{k}, numOccurrences(k), signalIntensityColumnIndex);
    end
    outputArray2D = zeros(numUniqueSpots, size(array2D, 2));
    for k = 1:numUniqueSpots
        outputArray2D(k,:) = nodeToKeep{k}.Data;
    end
    % Save output for this channel (top or bottom)
    dlmwrite([outputFolderPath, outputListFileName], outputArray2D, 'delimiter', ' ', 'newline', 'pc', 'precision', '%10.7f');
    
    fprintf('Finished processing %s file.\n\n', channel);
end

disp('All processing complete for both top and bottom files.');