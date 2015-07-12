
function phi = phi_Heston(OBJ, t, S0, v0,  u)

sigma0 = sqrt(v0); %initial Vol (square root of the variance)

d = sqrt( (OBJ.kappa - OBJ.rho.*OBJ.theta.*u.*1i).^2 + (OBJ.theta.^2).*(1i.*u + u.^2) );
g2 = (OBJ.kappa - OBJ.rho.*OBJ.theta.*u.*1i - d)./(OBJ.kappa - OBJ.rho.*OBJ.theta.*u.*1i + d);
phi = exp(1i.*u.*(log(S0)+(OBJ.drift-OBJ.q).*t)).*...
    exp(  OBJ.eta.*OBJ.kappa.*(OBJ.theta.^(-2)).*( (OBJ.kappa - OBJ.rho.*OBJ.theta.*1i.*u - d).*t - 2.*log((1-g2.*exp(-d.*t))./(1-g2)) )  ).*...
    exp(  sigma0.^2.*(OBJ.theta.^(-2)).*(OBJ.kappa - OBJ.rho.*OBJ.theta.*1i.*u - d).*((1-exp(-d.*t))./(1-g2.*exp(-d.*t)))  );

end
