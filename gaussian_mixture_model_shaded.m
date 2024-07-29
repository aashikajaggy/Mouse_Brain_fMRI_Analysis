spm('Defaults', 'FMRI');
%load one statistical map at a time - use non corrected p-value maps
nii = spm_vol(strcat(original_path, 'dr_stage3_ic000', '0', '_tstat1.nii'));
nifti_data = spm_read_vols(nii);

%extract mean and standard deviation
mean_data = mean(nifti_data(:));
std_value = std(nifti_data(:));
standardized_data = (nifti_data - mean_data)/std_value;

%do this command only once
spm_write_vol(nii, standardized_data)


%set num components as 3, so we get three gaussians as output
numComponents = 3;

%tune the max iterations - we need 1000 iterations for convergence
Options = statset('MaxIter', 1000);
rng(123, 'twister');

%tune regularization value
gmm = fitgmdist(nifti_data(:), 3, 'RegularizationValue', 0.1, 'Options', Options);
data_min = min(nifti_data(:));
data_max = max(nifti_data(:));

%define axis
x = linspace(min(nifti_data(:)),max(nifti_data(:)), 100);
[counts, binCenters] = hist(nifti_data(:), 100);  % Adjust the number of bins (100 here) as needed

figure;
hold on;
gm_weights = gmm.ComponentProportion;
gm_mean = gmm.mu;
gm_std = sqrt(gmm.Sigma);
    
mixture_mean = sum(gm_weights .* gm_mean);
mixture_var = sum(gm_weights .* (gm_std.^2));
mixture_std = sqrt(mixture_var);

%created a histogram in the background thatis shaded in blue
hist = histogram(nifti_data(:), 100, 'FaceColor', 'b', 'EdgeColor', 'none', 'Normalization', 'probability');



for i = 1:numComponents
    y = normpdf(x, gm_mean(i), squeeze(gm_std(1,1,i)));

    %combined_pdf = combined_pdf + y;
    squeezed_gm_std = squeeze(gm_std(1,1,i));
    %shading in the different gaussian curves with different colors to make them easier to recognize
    if(i==1)
        pdf1_p = plot(x, y,'Color', [0.5, 0.5, 0.5], 'LineWidth', 2);
        fill(x, y, [0.5, 0.5, 0.5], 'FaceAlpha', 0.3);
    end
    if(i==2)
        pdf2_p = plot(x, y,'r', 'LineWidth', 2);
        fill(x, y,'r', 'FaceAlpha', 0.3);
    end
     if(i==3)
        pdf3_p = plot(x, y,'g', 'LineWidth', 2);
        fill(x, y, 'g', 'FaceAlpha', 0.3);
    end
end

hold off;


% Add labels and legend
xlabel('z-scores');
ylabel('Probability Density');

    
%these definitions will help with defining the legend and finding intersection points (thresholds)
pdf1 = normpdf(x, gm_mean(1), (squeeze(gm_std(1, 1, 1))));
pdf2 = normpdf(x, gm_mean(2), (squeeze(gm_std(1, 1, 2))));
pdf3 = normpdf(x, gm_mean(3), (squeeze(gm_std(1, 1, 3))));



mu1 = gm_mean(1);
    
mu2 = gm_mean(2);
    
mu3 = gm_mean(3);

means_arr = [mu1, mu2, mu3];
minimum = min(means_arr);
maximum = max(means_arr);

%Since gmm in matlab randomly assigns gaussian curves as one of the three components, we need to use the mean to identify the gaussian curve as deactivation
%activation, or null distribution.
%This will help with creating the legend
if(mu1==minimum)
    deactivation_gaussian = pdf1_p;
    deact_color = [0.5, 0.5, 0.5];
elseif(mu2==minimum)
    deactivation_gaussian = pdf2_p;
    deact_color = [1, 0, 0];
else
    deactivation_gaussian = pdf3_p;
    deact_color = [0, 1, 0];
end


if(mu1==maximum)
    activation_gaussian = pdf1_p;
    act_color = [0.5, 0.5, 0.5];
elseif(mu2==maximum)
    activation_gaussian = pdf2_p;
    act_color = [1, 0, 0];
else
    activation_gaussian = pdf3_p;
    act_color = [0, 1, 0];
end

if(mu3~=maximum)&&(mu3~=minimum)
    null_gaussian = pdf3_p;
    null_color = [0, 1, 0];
elseif(mu2~=maximum)&&(mu2~=minimum)
    null_gaussian = pdf2_p;
    null_color = [1, 0, 0];
else
    null_gaussian = pdf1_p;
    null_color = [0.5, 0.5, 0.5];
end

hold on;
qw{1} = plot(nan, 'Color', null_color);
qw{2} = plot(nan, 'Color', deact_color);
qw{3} = plot(nan, 'Color', act_color);
qw{4} = plot(nan, 'b');

arr = [null_gaussian, deactivation_gaussian, activation_gaussian];

legend([qw{:}],{'Null', 'Deactivation', 'Activation', 'T-Stat Histogram'}, 'location','best');
%fill(x, pdf1, 'b', 'FaceAlpha', 0.3);
hold off;

    
%Calculating intersection points between the curves!
    
var1 = (squeeze(gm_std(1, 1, 1))).^2;
var2 = (squeeze(gm_std(1, 1, 2))).^2;
var3 = (squeeze(gm_std(1, 1, 3))).^2;
disp("component:")
disp("0")

yfun = @(mu,var, x)(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
val = fzero(@(x) yfun(mu2, var2, x) - yfun(mu3, var3, x), mean([mu2,mu3]));
yval = yfun(mu2, var2, val);
    %disp(val)
    %disp(yval);
    
if(val<0 && val<-0.1)
    disp("deactivation_value!")
end
if(val>0 && val>0.1)
    disp("activation_value!")
end

yfun = @(mu,var, x)(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
val = fzero(@(x) yfun(mu1, var1, x) - yfun(mu2, var2, x), mean([mu1,mu2]));
yval = yfun(mu1, var1, val);
    %disp(val)
    %disp(yval);
if(val<0 && val<-0.1)
    disp("deactivation_value!")
    disp(val)
end
if(val>0 && val>0.1)
    disp("activation_value!")
    disp(val)
end
yfun = @(mu,var, x)(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
val = fzero(@(x) yfun(mu1, var1, x) - yfun(mu3, var3, x), mean([mu1,mu3]));
yval = yfun(mu1, var1, val);
if(val<0 && val<-0.1)
    disp("deactivation_value!")
    disp(val)
end
if(val>0 && val>0.1)
    disp("activation_value!")
    disp(val)
end
   
