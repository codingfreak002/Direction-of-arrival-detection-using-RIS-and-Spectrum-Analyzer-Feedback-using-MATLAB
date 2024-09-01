function x_est = OMP_algo(phi_mat,y)

% Setting up initial parameters for the OMP
gamma_curr = y; % gamma_0, initial residual
I_set = []; % set of columns that contribute to y
col_set = []; % index of the columns
max_iter = 10e30; % Maximum number of iterations
iter_no = 1; % initializing the iteration variable
error_iter = Inf; % initial error 
norm_n_eta=0;

% Stopping threshold for error
if norm_n_eta > 0
    thresh = norm_n_eta;
else
thresh = 10^-10; 
end

norm_gamma = [norm(gamma_curr)]; % Initializing the norm of residual

% Norm function = sum of sqaure of all elements and then do the square root
while((iter_no < max_iter+1) && error_iter > thresh) % Checking for stopping criteria iter_no

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    max_ip = 0;
    % Finding the most contributing column
    for col_no = 1:size(phi_mat,2)
        curr_ip = abs(gamma_curr'*phi_mat(:,col_no));
        if curr_ip > max_ip
            max_ip = curr_ip;
            curr_col = col_no;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    col_set = [col_set curr_col]; % Merging basis indices
    I_set = [I_set phi_mat(:,curr_col)]; % Finding the merged basis

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Finding the projection of the measured signal onto the merged basis
    % Define the projection matrix
    projection_mat = I_set*pinv((I_set'*I_set))*I_set';

    % Projection of y onto I
    z_curr = projection_mat*y;
    
    % Updating the residual
    gamma_curr = y - z_curr;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Checking for stopping criteria
    if norm(gamma_curr) > norm_gamma(end)
        break
    else
        norm_gamma = [norm_gamma norm(gamma_curr)];
    end
    % Update error and iteration index
    error_iter = norm(gamma_curr);
    iter_no = iter_no+1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

% Finding the final estimate of x
col_set = unique(col_set); % Fetch only unique values skip repeted values
I_set = [];

% Finding x from I_set;
for col=1:length(col_set)
    I_set = [I_set phi_mat(:, col_set(col))]; % Appending the column from phi mat
end

% Solving the problem in reduced dimension of I_set
y_reduced_dim =zeros(length(col_set),1);
phi_reduced_dim = zeros(length(col_set),length(col_set));

for row = 1:length(col_set)
    y_reduced_dim(row) = y'*I_set(:, row);
    for col = 1:length(col_set)
        phi_reduced_dim(row, col) = I_set(:, row)'*I_set(:, col);
    end
end

% Finding the reduced dimension version of x
x_reduced_dim = pinv(phi_reduced_dim)*y_reduced_dim; % this is an important function

% Filling up the sparse vector x with the elements from the reduced dimension of x
x_est = zeros(181, 1);
for pos = 1:length(col_set)
    x_est(col_set(pos)) = x_reduced_dim(pos); % upadatin only few indexes. other remain 0
end
