clear ;
clc;
% ------- Producing INPUTS ---------%
a=input('Give me Number Of Spans :');
b=input('Give me the span length :');
c=input('Give me Number Of Stories :');
d=input('Give me the story height :');
e=3*(a+1)*(c+1);
O=(a+1)*c+(a*c);
% -------coordinates matrix-------%
h=zeros(a+1,1);
    h(:,1)=0:b:a*b;
    g=repmat(h,c+1,1);

       i=zeros(c+1,1);
       i(:,1)=0:d:d*c;
       j=repmat(i,a+1,1);
       k=sort(j);

coord=[g,k];



% -------Degrees Of Freedom Matrix-------%
DOF=ones((e/3),3);
       DOF(:,1)=(1:3:(e-2));
       DOF(:,2)=(2:3:(e-1));
       DOF(:,3)=(3:3:(e));



% -------Elements Degrees Of Freedom Matrix (EDOF)-------%

%----------------%
%  Columns EDOF  %
%----------------%

t=zeros(c,a+1);

for i=1:a+1;
    t(:,i)=i:a+1:((a+1)*(c));
end;

h1=zeros((a+1)*(c),1);
for i=(a+1)*(c);
    for j=(a+1)*(c);
    h1(1:i)=t(1:j);
    end;
end;


l1=h1(:,1)-1;

z1=l1*2;
x1=z1+h1;
v1=[x1,x1+1,x1+2];

g1=h1+a+1;

l2=g1(:,1)-1;
z2=l2*2;
x2=z2+g1;
v2=[x2,x2+1,x2+2];
k1=[v1,v2];



%----------------%
%   Beams EDOF   %
%----------------%
 
t1=zeros(c+1,a+1);

for i=1:a+1;
    t1(:,i)=i:a+1:((a+1)*(c+1));
end;

t1(1,:)=[];

t1(:,a+1)=[];


h2=zeros((a)*(c),1);
for i=(a)*(c);
    for j=(a)*(c);
    h2(1:i)=t1(1:j);
    end;
end;


g2=h2+1;

k2=[h2,g2];

 
l3=h2(:,1)-1;
z3=l3*2;
x3=z3+h2;
v3=[x3,x3+1,x3+2];
g3=h2(:,1)+1;
l4=g3(:,1)-1;
z4=l4*2;
x4=z4+g3;
v4=[x4,x4+1,x4+2];
k3=[v3,v4];


%-------Combine Columns EDOF & BEAMS EDOF-------%
n=zeros((c*(a+1)+(c*a)),1);
for i=1:(c*(a+1)+(c*a));n(i)=i;
end;

m=[k1;k3];
EDOF=[n,m];


% --------- Create and assemble element matrices ---------%
[Ex,Ey]=coordxtr(EDOF,coord,DOF,2);

% --------- ELEMENT PROPERTIES [E A I]---------%
e1=input('Give me E (Modulus Of Elasticity):');
e2=input('Give me A (Cross-Section Area) For Beams :');
e3=input('Give me I (Moment Of Inertia) For Beams :');

ep1=[e1 e2 e3];

e5=input('Give me A (Cross-Section Area) For Columns :');
e6=input('Give me I (Moment Of Inertia) For Columns :');

ep2=[e1 e5 e6];

axis([-1 (a*b+1) -1 (c*d+1)])
eldraw2(Ex,Ey,[1,1,0]);

% --------- Load matrix----------%
eq=zeros(1,2);
eq(:,2)=input(' q (distributed load):');
eq(:,1)=0;

o=((c+1)*(a+1))*3;
K=zeros(o);

disp('Do you like to give me the load matrix (f)  manually ?')
disp('If you do not like it is going to be zero !!!')
x1=input('Give me 1 for Yes - 2 for No :');

if x1==1;
f=zeros(o,1);    
f=input('f :');
else
f=zeros(o,1);
end

for i=1:((a+1)*c);
   
Ke1=beam2e(Ex(i,:),Ey(i,:),ep1);
 K=assem(EDOF(i,:),K,Ke1);
end;

            
for j=(((a+1)*c)+1):((a+1)*c)+(a*c);
               
[Ke2,fe]=beam2e(Ex(j,:),Ey(j,:),ep2,eq);
[K,f]=assem(EDOF(j,:),K,Ke2,f,fe);
        
end;


% ---------Defining Boundary Conditions----------%
x=input('Give me "1" for Hinge & "2" for Fixed support :');
n=ones(((a+1)*3),1);
n(:,1)=1:(a+1)*3;


if x==1;

    bc1=(1:3:((a+1)*3));
    
    bc3=(2:3:((a+1)*3));
    

bc=[bc1,bc3];
bc=sort(bc);
    n=zeros(((a+1)*2),1);
   
    bc=bc';
else 
    bc=ones(((a+1)*3),1);
    bc(:,1)=1:(a+1)*3;
    n=zeros(((a+1)*3),1);
    
end;



bc=[bc,n];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
[a,r]=solveq(K,f,bc);


% --------- Display Results----------%  


Ed=extract(EDOF,a);


sfac=scalfact2(Ex,Ey,Ed,.1);
eldisp2(Ex,Ey,Ed,[2 3 0],sfac);
clc;
s=['      -n-','          ','       -End 1-','     ','     ','           -End 2-','     '];
disp('--------------------------------------------------------------------------');
disp('---------------------------Elements Displacement--------------------------');
disp('--------------------------------------------------------------------------');
disp(s);
disp('--------------------------------------------------------------------------');

s1=zeros(O,1);
s1(:,1)=1:O;

s2=[s1,Ed];
disp(s2);

%-----%%%%%----%     
%-----%end%----%
%-----%%%%%----%

  
  