function [sameSpot, distance] = compareNodes(n1, n2, xCol, yCol, xThreshold, yThreshold)

    xy1 = n1.Data([xCol, yCol]);
    xy2 = n2.Data([xCol, yCol]);
    
    xDist = xy2(1) - xy1(1);
    yDist = xy2(2) - xy1(2);
    
    if (abs(xDist) <= xThreshold && abs(yDist) <= yThreshold)
        sameSpot = true;
    else
        sameSpot = false;
    end
    
     distance = sqrt(xDist^2 + yDist^2);

end

