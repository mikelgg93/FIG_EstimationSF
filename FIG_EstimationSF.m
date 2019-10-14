function []= FIG_EstimationSF(imageDir)
%% Plot the figure of the SFit for the SFCut off estimation
% MGG 190114 ver '9.6.0.1135713 (R2019a) Update 3'
%
% As seen in the paper: XXX
% Use as FIG_EstimationSF() to obtain the same image as the one printed in
% the article.
% 
% You can modify the image used in the subplot b, by calling to the
% function FIG_EstimationSF(imageDir), input should be readable by imread
% function in matlab.
% 
% If you want to add values to the function to calculate the SFcutoff
% limit, look at the function estimateSFCutOFF.

if nargin<1
    imageDir= 'http://sipi.usc.edu/database/download.php?vol=misc&img=5.3.01';
end
%% Subplot A - Piecewise surface linear function 
subplot 121
[fitresult]= estimateSFCutOFF();
p= plot(fitresult,'style','Surface');
alpha(p, .7);
colormap summer
view(31.3, 28.72);
yticks(gca,[1 10 20 30 40])
yticklabels(gca,{'-20°','-10°','0°','+10°','+20°'});
xticks(gca,[-9 1 10 20 30 40 50 60 70 80 90])
xticklabels(gca,{'-50°','-40°','-30°','-20°','-10°','0°','10°','20°','30°','40°','50°'});

xtickangle(40);ytickangle(-10);
xlabel(['    _T_e_m_p_o_r_a_l                            _N_a_s_a_l',newline,'Horizontal Meridian    '], 'rotation', -14);
xh = get(gca,'xlabel'); % handle to the label object
p1 = get(xh,'position'); % get the current position property
p1(2) = 8.5;p1(1)= 5 ;        % double the distance,                        
set(xh,'position',p1);   % set the new position
ylabel('Vertical Meridian','rotation', 35);
yh = get(gca,'ylabel'); % handle to the label object
p1 = get(yh,'position'); % get the current position property
p1(2) = 20;p1(1)= 100 ;        % double the distance,                        
set(yh,'position',p1) 
zlabel(['SF Cut off',newline,' cyc/deg.'],'rotation',0);
zh = get(gca,'zlabel'); % handle to the label object
p1 = get(zh,'position'); % get the current position property
p1(2) = 0;p1(1)= -60 ;  p1(3)= 20;      % double the distance,                        
set(zh,'position',p1) 
t= title(['A) Estimation function of Spatial Frequency Cut-Off', newline ,'across the Retina']);
set(t, 'horizontalAlignment', 'left'); set(t,'Position',[-30, -10, 95] );
hold on; clr= lines(3);
s1= scatter3(x2(1:3), y2(1:3), z2(1:3),100,...  
   'MarkerFaceColor',clr(1,1:3));alpha(s1, 1);
s2= scatter3(x2(4:7), y2(4:7), z2(4:7),100,...
    'MarkerFaceColor',clr(2,1:3));alpha(s2, 1);
s3= scatter3(x2(7:end), y2(7:end), z2(7:end),100,...
  'MarkerFaceColor',clr(3,1:3));alpha(s3, 1);

h2 = findobj(gca,'Type','line'); set(h2,'LineWidth',2, 'Color', 'k');
h3= findall(findall(0, 'Type', 'Scatter'),'-property','LineWidth');set(h3,'LineWidth',2);set(gca,'linewidth',1.5);
set(findall(findall(0, 'Type', 'figure'),'-property','MarkerEdgeColor'),'MarkerEdgeColor','k');
set(findall(findall(0, 'Type', 'figure'),'-property','FontSize'),'FontSize',12);
set(findall(findall(0, 'Type', 'figure'),'-property','FontWeight'),'FontWeight','bold');
legend({'L.N.Thibos  1987','R. Rosen 2014','Anderson 1991'},'Location','northeast','NumColumns',1);

%% Subplot B - Representation of images under lowpass filter to the SFCutoff.
subplot 122
title(['B) Low pass filtered reference image by SF_c_u_t_o_f_f', newline]);
fdrawsegmentation2;
h2 = findobj(gca,'Type','line'); set(h2,'LineWidth',2, 'Color', 'k');
set(findall(findall(0, 'Type', 'figure'),'-property','FontSize'),'FontSize',12);
set(findall(findall(0, 'Type', 'figure'),'-property','FontWeight'),'FontWeight','bold');set(gca,'linewidth',1.5);
set(gcf, 'Position',[174.6 293.8 1132 468.0]);
hold on; 
axes('pos',[.65 .43 .15 .15]) % Image at fovea
imshow(simulateimage(41,3, imageDir));
axes('pos',[.65 .750 .15 .15]) % 
imshow(simulateimage(41,1, imageDir));
axes('pos',[.65 .1 .15 .15])
imshow(simulateimage(41,5, imageDir));

axes('pos',[.78 .43 .15 .15]) % 
imshow(simulateimage(76,3, imageDir));
axes('pos',[.525 .43 .15 .15])
imshow(simulateimage(1,3, imageDir));

%% Functions
function [fitresult]= estimateSFCutOFF()
    %Get a fit using the data reported in the literature
x2= [41 21 6 ...%
    41 41 61 21 ...%
    41 33 16 1 -14 49 66 81 96 41 41 41 41];
y2= [21 21 21 ...
    1 41 21 21 ...
    21 21 21 21 21 21 21 21 21 1 41 13 29];
z2= [54 6 3 ...% LNT 1987 (0.1166 correction to Rosen)
    4.88 5.82 6.7 6.7 ...% Rosen2014 (He found vertical assymetries)
    60 10 4.5 2.3 0.8 10 6.48 4.91 1.9 2.54 2.54 10 10];% Anderson 1991(He found horizontal assymetries)
[xData, yData, zData] = prepareSurfaceData( x2, y2, z2 );
[fitresult, ~] = fit( [xData, yData], zData, 'linear', 'Normalize', 'on' );
end

function [simIm] = simulateimage(angle, meridian, imageDir)
% Apply a low pass filter to the image according to the SF cutoff
%     corresponding to the location.
% For fovea, meridian = 3; angle= 0; 
img= imread(imageDir);
fineimage= imresize(img, [256 256]);
Sz=size(fineimage);
[x, y]= meshgrid(-Sz(2)/2:(Sz(2)/2-1),...
    Sz(1)/2:-1:-(Sz(1)/2-1));
r=sqrt(x.^2 + y.^2);
fineimage= fftshift(fft2(double(fineimage)));
[fitresult]= estimateSFCutOFF();
m=[1 11 21 31 41]; % Position of the meridians
SFcut= fitresult(angle,m(meridian));% in cyc/deg
% Apply low-pass filter with Spatial frequency cut-off
r0= SFcut*2; %Image subtended 2° 
lowpass= exp(-(r.^2)./(2*(r0^2)));% Gaussian low pass filter
lo= exp(-(r.^2+r.^2)./(2*r0).^2);
fineimage= fineimage.*lo;%wpass;
fineimage= ifftshift(fineimage);
simIm= uint8(ifft2(fineimage));
end

function []= fdrawsegmentation2()
% Just draw the annular rings and degs. For display porpuses.
hold on;
plot([1 40],[40 1],'k-');
plot([1 40],[1 40],'k-');
plot([20 20],[1 40],'k--');
plot([1 40],[20 20],'k--');
plot(20,20,'k*');
plot(20+ 10.8,18.8,'k*');
xlabel('Horizontal Meridian')
ylabel('Vertical Meridian')
xticks(gca,[1 10 20 30 40])
xticklabels(gca,{'-20°','-10°','0°','10°','20°'});
yticks(gca,[1 10 20 30 40])
yticklabels(gca,{'+20°','+10°','0°','-10°','-20°'});
for nn= 5:5:20
    a=nn*1; % horizontal radius
    b=nn*1; % vertical radius
    x0=40/2; % x0,y0 ellipse centre coordinates
    y0=40/2;
    t=-pi:0.01:pi;
    x=x0+a*cos(t);
    y=y0+b*sin(t);
    plot(x,y,'k')
end,end
end