function Cube_Volume_Estimator
% The condensate is divided into multiple smaller cubes of specified dimensions. 
% Then, the number of localizations within each smaller cube is determined by the program.

%% Input Variables
file_read= readmatrix("Test_Exp.csv"); % Filename of the experimental dataset
length= 5500; % size of the big cube in 'nm' (this length should cover the whole condensate)
slices= 100; % Length of smaller cubes in 'nm' (this defines the size of the smaller cubes) 

%% Calculations
file= file_read(:,3:5);
c = [mean(file(:,1)), mean(file(:,2)), mean(file(:,3))];
r= length/2;
x_c= c(1,1);
y_c= c(1,2);
z_c= c(1,3);
v1= [x_c-r, y_c-r, z_c-r];
v2= [x_c-r, y_c-r, z_c+r];
v3= [x_c-r, y_c+r, z_c-r];
v4= [x_c-r, y_c+r, z_c+r];
v5= [x_c+r, y_c-r, z_c-r];
v6= [x_c+r, y_c-r, z_c+r];
v7= [x_c+r, y_c+r, z_c-r];
v8= [x_c+r, y_c+r, z_c+r];
v= [v1; v2; v3; v4; v5; v6; v7; v8];
x= v(:,1);
y= v(:,2);
z= v(:,3);

x_min= min(x);
y_min= min(y);
z_min= min(z);
x_max= max(x);
y_max= max(y);
z_max= max(z);

s= size(file);
total= s(1,1);
file_new=[];
for a=1:1:total
    if file(a,1)>=x_min && file(a,1)<=x_max && file(a,2)>=y_min && file(a,2)<=y_max && file(a,3)>=z_min && file(a,3)<=z_max
        spot_selected= [file(a,:)];
        file_new= [file_new; spot_selected];
    end
end
x2= file_new(:,1);
y2= file_new(:,2);
z2= file_new(:,3);

figure(1);
scatter3(x,y,z,'o');
hold on
scatter3(x2,y2,z2,'*');
hold off
saveas(gcf, 'cube.fig');
%writematrix(file_new,'spotsincube_Exp_Zfiltered_100.xlsx'); %Saves the file with raw values also

total_slices= length/slices; 
i= slices;
s2=size(file_new);
total2= s2(1,1);
j=1;
k=1;
x_filtered=[];
final_info=[];
z_counts=0;

for j=1:1:total_slices
    ll_x= x_min+i*(j-1);
    ul_x= x_min+i*j;
    file_x= file_new(file_new(:,1)>=ll_x & file_new(:,1)<ul_x, :);
    for l= 1:1:total_slices
        ll_y= y_min+i*(l-1);
        ul_y= y_min+i*l;
        file_yy= file_x(:,2:3);
        file_y= file_yy(file_yy(:,1)>=ll_y & file_yy(:,1)<ul_y, :);
        for m= 1:1:total_slices
            ll_z= z_min+i*(m-1);
            ul_z= z_min+i*m;
            file_zz= file_y(:,2);
            z_count= find(file_zz>=ll_z&file_zz<ul_z);
            z_countss= size(z_count);
            z_counts= z_countss(1,1);
            stored_info= [ul_x, ul_y, ul_z, z_counts];
            final_info= [final_info; stored_info];
        end
    end
end
writematrix(final_info, "Final_Histogram.xlsx");
volume = numel(find(final_info(:,4)>0))*((slices/1000)^3);
density = total2./volume;
save("Results.mat","density","volume",'-mat');
end