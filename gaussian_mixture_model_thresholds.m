spm('Defaults', 'FMRI');

%make sure to unzip all the ucorrected p-value statistical maps first and create a directory for them!
original_path = '/Users/bass/Desktop/new_conn_data/gmm_results/unzipped_components/';

%here we are looping through all the statistical maps, generating gaussian mixture models with 3 components, and then calculating thresholds for each component
%labeling of the legend is inaccurate so look at the file gaussian_mixture_model_shaded.m to correct the legend

for j=0:9
    nii = spm_vol(strcat(original_path, 'dr_stage3_ic000', num2str(j), '_tstat2.nii'));
    nifti_data = spm_read_vols(nii);
    mean_data = mean(nifti_data(:));
    std_value = std(nifti_data(:));
    
    %converts all the intensity values to z-scores
    standardized_data = (nifti_data - mean_data)/std_value;
    spm_write_vol(nii, standardized_data)
    
    numComponents = 3;
    Options = statset('MaxIter', 1000);
    
    rng(123, 'twister');
    gmm = fitgmdist(nifti_data(:), 3, 'RegularizationValue', 0.1, 'Options', Options);

    data_min = min(nifti_data(:));
    data_max = max(nifti_data(:));
    x = linspace(min(nifti_data(:)),max(nifti_data(:)), 100);
    
    % Plot the histogram with PDF overlay
    figure;
    histogram(nifti_data(:), 'Normalization', 'pdf', 'BinMethod', 'auto');
    hold on;
    
    gm_weights = gmm.ComponentProportion;
    gm_mean = gmm.mu;
    gm_std = sqrt(gmm.Sigma);
    
    mixture_mean = sum(gm_weights .* gm_mean);
    mixture_var = sum(gm_weights .* (gm_std.^2));
    mixture_std = sqrt(mixture_var);
    
    for i = 1:numComponents
        y = normpdf(x, gm_mean(i), squeeze(gm_std(1,1,i)));
        %combined_pdf = combined_pdf + y;
        squeezed_gm_std = squeeze(gm_std(1,1,i));
        plot(x, y, 'LineWidth', 2);
    end

    hold off;
    
    % Add labels and legend
    xlabel('z-scores');
    ylabel('Probability Density');
    
    %find the intersection points
    pdf1 = normpdf(x, gm_mean(1), (squeeze(gm_std(1, 1, 1))));
    pdf2 = normpdf(x, gm_mean(2), (squeeze(gm_std(1, 1, 2))));
    pdf3 = normpdf(x, gm_mean(3), (squeeze(gm_std(1, 1, 3))));
    
    
    legend('Null', 'Deactivation', 'Activation');
    
    
    mu1 = gm_mean(1);
    
    mu2 = gm_mean(2);
    
    mu3 = gm_mean(3);
    
    var1 = (squeeze(gm_std(1, 1, 1))).^2;
    var2 = (squeeze(gm_std(1, 1, 2))).^2;
    var3 = (squeeze(gm_std(1, 1, 3))).^2;
    disp("component:")
    disp(num2str(j))

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
    %disp(val)
    %disp(yval);
end

for k=10:19
    nii = spm_vol(strcat(original_path, 'dr_stage3_ic00', num2str(k), '_tstat2.nii'));
    nifti_data = spm_read_vols(nii);
    mean_data = mean(nifti_data(:));
    std_value = std(nifti_data(:));
    
    %converts all the intensity values to z-scores
    standardized_data = (nifti_data - mean_data)/std_value;
    %spm_write_vol(nii, standardized_data)
    
    numComponents = 3;
    Options = statset('MaxIter', 1000);
    
    rng(123, 'twister');
    gmm = fitgmdist(nifti_data(:), 3, 'RegularizationValue', 0.1, 'Options', Options);
    %gmm1 = fitgmdist(nifti_data(:), 1, 'RegularizationValue', 1e-6, 'Options', Options);
    
    
    % Determine the range of your data
    data_min = min(nifti_data(:));
    data_max = max(nifti_data(:));
    x = linspace(min(nifti_data(:)),max(nifti_data(:)), 100);
    
    % Plot the histogram with PDF overlay
    figure;
    %histogram(nifti_data(:), 'Normalization', 'pdf', 'BinMethod', 'auto');
    hold on;
    
    gm_weights = gmm.ComponentProportion;
    gm_mean = gmm.mu;
    gm_std = sqrt(gmm.Sigma);
    
    mixture_mean = sum(gm_weights .* gm_mean);
    mixture_var = sum(gm_weights .* (gm_std.^2));
    mixture_std = sqrt(mixture_var);
    
    for i = 1:numComponents
        y = normpdf(x, gm_mean(i), squeeze(gm_std(1,1,i)));
        %combined_pdf = combined_pdf + y;
        squeezed_gm_std = squeeze(gm_std(1,1,i));
        plot(x, y, 'LineWidth', 2);
    end
    
    hold off;
    
    % Add labels and legend
    xlabel('z-scores');
    ylabel('Probability Density');
    
    %find the intersection points
    pdf1 = normpdf(x, gm_mean(1), (squeeze(gm_std(1, 1, 1))));
    pdf2 = normpdf(x, gm_mean(2), (squeeze(gm_std(1, 1, 2))));
    pdf3 = normpdf(x, gm_mean(3), (squeeze(gm_std(1, 1, 3))));
    
    
    legend('Null', 'Deactivation', 'Activation');
    
    
    mu1 = gm_mean(1);
    
    mu2 = gm_mean(2);
    
    mu3 = gm_mean(3);
    

    var1 = (squeeze(gm_std(1, 1, 1))).^2;
    var2 = (squeeze(gm_std(1, 1, 2))).^2;
    var3 = (squeeze(gm_std(1, 1, 3))).^2;
    disp("component:")
    disp(num2str(k))
    
    yfun = @(mu,var, x)(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
    val = fzero(@(x) yfun(mu2, var2, x) - yfun(mu3, var3, x), mean([mu2,mu3]));
    yval = yfun(mu2, var2, val);
    
    if(val<0 && val<-0.1)
        disp("deactivation_value")
        disp(val)
    end
    if(val>0 && val>0.1)
        disp("activation_value")
        disp(val)
    end


    yfun = @(mu,var, x)(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
    val = fzero(@(x) yfun(mu1, var1, x) - yfun(mu2, var2, x), mean([mu1,mu2]));
    yval = yfun(mu1, var1, val);
    %disp(val)
    %disp(yval);
    if(val<0 && val<-0.1)
        disp("deactivation_value")
        disp(val)
    end
    if(val>0 && val>0.1)
        disp("activation_value")
        disp(val)
    end

    yfun = @(mu,var, x)(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
    val = fzero(@(x) yfun(mu1, var1, x) - yfun(mu3, var3, x), mean([mu1,mu3]));
    yval = yfun(mu1, var1, val);
 
    if(val<0 && val<-0.1)
        disp("deactivation_value")
        disp(val)
    end
    if(val>0 && val>0.1)
        disp("activation_value")
        disp(val)
    end
end

    

