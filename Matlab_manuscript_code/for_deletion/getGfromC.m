function G = getGfromC(C,T)


G = C;

G(2:end-1) = (C(3:end) - C(1:end-2))./(T(3:end) - T(1:end-2));
G(1) = (C(2) - C(1))/(T(2) - T(1));
G(end) = (C(end) - C(end-1))/(T(end) - T(end-1));





end
