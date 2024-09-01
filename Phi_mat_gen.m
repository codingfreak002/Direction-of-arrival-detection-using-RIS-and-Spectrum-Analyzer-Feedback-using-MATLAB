function H_matrix = Phi_mat_gen(M1,N,L,B_matrices,theta)

    % Given parameters
    Sn = 1; % Signal value
    M = M1*N; % Number of elements
    periodicity = 16e-3; % Periodicity of the elements (10mm)
    lambda = 3e8 / (5.5e9); % Wavelength (c/f)
    Xf = 350e-3; % Position of the focal point (350mm)
    Zf = 350e-3; % Distance of the focal point (350mm)

    % Initialize matrices and arrays to store results
    H_matrices = cell(L, 1); % Store H(theta) matrices

for i = 1:L
    % Generate a random B matrix
    B = B_matrices{i};

    % Calculate H(theta) matrix
    H = zeros(1, length(theta));
    for n = 1:length(theta)
        H_theta = 0; % Initialize H_theta for this theta
        for m = 1:M
            for l = 1:M
                % Calculate positions of elements m and l
                Xm = periodicity * (m - (M + 1) / 2); % Position of mth element from the center
                Xl = periodicity * (l - (M + 1) / 2); % Position of lth element from the center

                % Calculate the phase terms
                phase_m = -1i * 2 * pi / lambda * (Xm * sind(theta(n)) - sqrt(Zf^2 + (Xf - Xm)^2));
                phase_l = 1i * 2 * pi / lambda * (Xl * sind(theta(n)) - sqrt(Zf^2 + (Xf - Xl)^2));

                % Calculate H(theta) for each theta
                H_theta = H_theta + (-1)^B(m) * exp(phase_m) * (-1)^B(l) * exp(phase_l);
            end
        end
        % Multiply with E[Sn*Sn]
        H_theta = H_theta * (Sn * Sn');
        
        % Assign the calculated H_theta to the corresponding index in H
        H(n) = H_theta;
    end
    % Store H(theta) matrix and other results
    H_matrices{i} = H;
end

% Convert H_matrices to a matrix
H_matrix = cell2mat(H_matrices);
end