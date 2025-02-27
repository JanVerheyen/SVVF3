% Citation 550 - Linear simulation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Variables, functions, etc.....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% xcg = 0.25*c

% Stationary flight condition
% imported from data of plane (use timestamps)

hp0    = 7000*0.3048;      	  % pressure altitude in the stationary flight condition [m]
V0     = 240*0.5144447;       % true airspeed in the stationary flight condition [m/sec]
alpha0 = 2/180*pi;       	  % angle of attack in the stationary flight condition [rad]
th0    = 1/180*pi;       	  % pitch angle in the stationary flight condition [rad]

% Aircraft mass

%empty mass
m_empty = 9165*0.453592;      %aircraft empty weight [kg]
arm_empty = 292.18*0.0254;

%payload
m_pilot1 = 70;                %mass of the passengers
arm_1 = 131*0.0254;
m_pilot2 = 70;
arm_2 = 131*0.0254;
m_coordinator = 70;
arm_10 = 170*0.0254;
m_observer1L = 70;
arm_3 = 214*0.0254;
m_observer1R = 70;
arm_4 = 214*0.0254;
m_observer2L = 70;
arm_5 = 251*0.0254;
m_observer2R = 70;
arm_6 = 251*0.0254;
m_observer3L = 70;
arm_7 = 288*0.0254;
m_observer3R = 70;
arm_8 = 288*0.0254;

%fuel
m_fuel = 700;
arm_fuel = 0.072644;


x_cg = (m_empty*arm_empty+m_pilot1*arm_1+m_pilot2*arm_2+m_coordinator*arm_10+m_observer1L*arm_3+m_observer1R*arm_4+m_observer2L*arm_5+m_observer2R*arm_6+m_observer3L*arm_7+m_observer3R*arm_8+m_fuel*arm_fuel)/(m_pilot1+m_pilot2+m_coordinator+m_observer1L+m_observer1R+m_observer2L+m_observer2R+m_observer3L+m_observer3R+m_fuel);
disp(x_cg);


% aerodynamic properties
e      = 0.8;             % Oswald factor [ ]
CD0    = 0.04;            % Zero lift drag coefficient [ ]
CLa    = 5.084;           % Slope of CL-alpha curve [ ]

% Longitudinal stability
Cma    = 12;                % longitudinal stability [ ]
Cmde   = 12;                % elevator effectiveness [ ]

% Aircraft geometry

S      = 30.00;	          % wing area [m^2]
Sh     = 0.2*S;           % stabiliser area [m^2]
Sh_S   = Sh/S;	          % [ ]
lh     = 0.71*5.968;      % tail length [m]
c      = 2.0569;          % mean aerodynamic cord [m]
lh_c   = lh/c;	          % [ ]
b      = 15.911;          % wing span [m]
bh     = 5.791;	          % stabiliser span [m]
A      = b^2/S;           % wing aspect ratio [ ]
Ah     = bh^2/Sh;         % stabiliser aspect ratio [ ]
Vh_V   = 1;               % [ ]
ih     = -2*pi/180;       % stabiliser angle of incidence [rad]

% Constant values concerning atmosphere and gravity

rho0   = 1.2250;          % air density at sea level [kg/m^3] 
lambda = -0.0065;         % temperature gradient in ISA [K/m]
Temp0  = 288.15;          % temperature at sea level in ISA [K]
R      = 287.05;          % specific gas constant [m^2/sec^2K]
g      = 9.81;            % [m/sec^2] (gravity constant)

rho    = rho0*((1+(lambda*hp0/Temp0)))^(-((g/(lambda*R))+1));   % [kg/m^3]  (air density)
W      = m*g;				                        % [N]       (aircraft weight)

% Constant values concerning aircraft inertia

muc    = m/(rho*S*c);
mub    = m/(rho*S*b);
KX2    = 0.019;
KZ2    = 0.042;
KXZ    = 0.002;
KY2    = 1.25*1.114;

% Aerodynamic constants

Cmac   = 0;                     % Moment coefficient about the aerodynamic centre [ ]
CNwa   = CLa;   		        % Wing normal force slope [ ]
CNha   = 2*pi*Ah/(Ah+2);        % Stabiliser normal force slope [ ]
depsda = 4/(A+2);               % Downwash gradient [ ]

% Lift and drag coefficient

CL = 2*W/(rho*V0^2*S);               % Lift coefficient [ ]
CD = CD0 + (CLa*alpha0)^2/(pi*A*e);  % Drag coefficient [ ]

% Stabiblity derivatives

CX0    = W*sin(th0)/(0.5*rho*V0^2*S);
CXu    = -0.02792;
CXa    = -0.47966;
CXadot = +0.08330;
CXq    = -0.28170;
CXde   = -0.03728;

CZ0    = -W*cos(th0)/(0.5*rho*V0^2*S);
CZu    = -0.37616;
CZa    = -5.74340;
CZadot = -0.00350;
CZq    = -5.66290;
CZde   = -0.69612;

Cmu    = +0.06990;
Cmadot = +0.17800;
Cmq    = -8.79415;

CYb    = -0.7500;
CYbdot =  0     ;
CYp    = -0.0304;
CYr    = +0.8495;
CYda   = -0.0400;
CYdr   = +0.2300;

Clb    = -0.10260;
Clp    = -0.71085;
Clr    = +0.23760;
Clda   = -0.23088;
Cldr   = +0.03440;

Cnb    =  +0.1348;
Cnbdot =   0     ;
Cnp    =  -0.0602;
Cnr    =  -0.2061;
Cnda   =  -0.0120;
Cndr   =  -0.0939;


%state space matrices

%symmetric flight
A = [CXu-2*muc CXa CZ0 CXq;CZu CZa+(CZadot-2*muc)*Dc -CX0 CZq+2*muc;0 0 -Dc 1;Cma Cma+Cmadot*Dc 0 Cmq-2*muc*KY2^2*Dc];

%asymetric flight
B = [CYb+(CYbdot-2*mub)*Db CL CYp CYr-4*mub;0 -0.5*Db 1 0;Clb 0 Clb-4*mub*KX2^2*Db Clr+4*mub*KXZ*Db;Cnb+Cnbdot*Db 0 Cnp+4*mub*KXZ*Db Cnr-4*mub*KZ2^2*Db];








