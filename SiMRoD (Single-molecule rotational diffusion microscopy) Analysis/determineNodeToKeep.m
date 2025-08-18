function nodeToKeep = determineNodeToKeep(node, numOccurrences, signalIntensityColumnIndex)

    %If only a single node, return the node.
    if (numOccurrences == 1)
        nodeToKeep = node;
        return;
    end

    medianIndex = median(1:numOccurrences);
    
    if (mod(numOccurrences, 2) == 0)
        %If even number of nodes, keep the middle node that has the higher
        %intensity.
        
        %Determine the first middle node index.
        middleNode1Index = floor(medianIndex);
   
        %Find the first middle node.
        counter = 1;
        while (counter ~= middleNode1Index)
            node = node.Next;
            counter = counter + 1;
        end
        
        %Get the intensities of the two middle nodes.
        middleNode1Intensity = node.Data(signalIntensityColumnIndex);
        middleNode2Intensity = node.Next.Data(signalIntensityColumnIndex);
        
        %Return the index of the middle node with the higher intensity.
        if (middleNode1Intensity >= middleNode2Intensity)
            nodeToKeep = node;
        else
            nodeToKeep = node.Next;
        end
        
    else
        %If odd number of nodes, keep the middle node.
       
        %Find the middle node.
        counter = 1;
        while (counter ~= medianIndex)
            node = node.Next;
            counter = counter + 1;
        end
        
        nodeToKeep = node;
   end
end

