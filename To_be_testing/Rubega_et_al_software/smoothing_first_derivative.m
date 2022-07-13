function [u_hat,yp,rat1_1,t_old,gamma,y,t,yp1]=smoothing_first_derivative(rat1_1,new_time,ds,a,b)
% Thanks to this function, it's possible to compute the smoothing of the signal, its first time-derivative

% interval of interest 
t_start=find(new_time>=a,1,'first');
t_end=find(new_time>=b,1,'first');

t_old=new_time(t_start):new_time(2)-new_time(1):new_time(t_end); % time starting from t_start

rat1_1=rat1_1(t_start:t_end); % data in the interval of interest
first_values=mean(rat1_1(1:10));

rat1_1=rat1_1-first_values; % data first value=0; 

if ds~=0
y=downsample(rat1_1,ds);
t=downsample(t_old,ds);
else
    y=rat1_1;
    t=t_old;
end

n=length(y);

B=eye(length(y),length(y));
sigma=0.005;
sigma2=sigma^2;
Sigmav=sigma2*B; % covariance error matrix

r=zeros(1,n);
r(1)=1;

d=zeros(1,n);
d(1)=1;
m=2;

for k=1:m
    d=filter([1 -1],1,d);
end

F=toeplitz(d,r);

c=ones(n,1);
G=toeplitz(c,r);

%% Gamma_criterion 

% Diagonalization

b=diag(B);
b_zeros=find(b==0);
b(b_zeros)=eps;
B2=diag(b.^(-0.5));

toll=10e-6;
convergenza=1;
gmin=1e-10;
gmax=1e10;

% SVD

H=B2*G*inv(F);
[U,D,V]=svd(H);
epsi=U'*B2*y;

ni=zeros(n,1);
ro=zeros(n,1);

while convergenza==1

gamma=10^((log10(gmin)+log10(gmax))/2);

for i=1:n
    di=D(i,i);
    ni(i)=di*epsi(i)/(di^2+gamma);
    ro(i)=gamma*epsi(i)/(di^2+gamma);    
end

WRSS=sum(ro.^2);

if WRSS>trace(Sigmav)
    gmax=gamma;
else
    gmin=gamma;
end
   
if abs(WRSS-trace(Sigmav))<toll %|| k>20
    convergenza=0;
    gamma;
end

%k=k+1

end
%%

u_hat=inv(F)*V*ni;
yp1=G*u_hat;

u_hat=interp1(t,u_hat,t_old,'pchip');
yp=interp1(t,yp1,t_old,'pchip');
