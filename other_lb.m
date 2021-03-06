%m by k

% all to cloud


clear
clc
close all
format long
load('g2_hpc.mat');
rng('default');
%rng(1);
%rng('shuffle');
% D = 0.4;% deadline (sec)
% tau = 0.35; % allocated cpu time (sec)
% x= 50; % Mcycles per task
% v=10;

Deadline = 0.5;% deadline (sec)
x=35; % Mcycles per task
E=70;
A=2.37;
p=3;
m=8;

len_N_tot = size(N_tot,1);
lb_arr_miss_cnt = zeros(length(len_N_tot),4);
arr_no_miss_cnt= zeros(length(len_N_tot),4);
arr_static_enegery_used= zeros(length(len_N_tot),4);
lb_arr_time_tot= zeros(length(len_N_tot),4);

met=1;


for nn = 1:len_N_tot 
    
    N_mat = squeeze(N_tot(nn,:,:));



no_miss_cnt=0;
miss_cnt=0;
static_enegery_used = 0;
time_tot = 0;
for j = 1:length(N_mat)

    N = N_mat(j,:);
    N_leftover=zeros(1,size(N_mat,2));

    for i=1:m
        time_passed = 0;
        for n=1:N(i)
            time_passed = time_passed +  1/B(i,i) + x/f(i); 
            time_tot=time_tot+  1/B(i,i) + x/f(i);
            if  time_passed <= Deadline && n <= C(i)
                N_leftover(i)=N_leftover(i)+1;
                static_enegery_used=static_enegery_used+(A*(f(i)/1000)^p+E)*x/f(i);  
                
            end 
        end
        N_leftover(i)=N(i)-N_leftover(i);

    end
    time_passed = 0;

    for n=1:sum(N_leftover)
            time_passed = time_passed +  1/B(1,end) + x/f(end);   
            time_tot=time_tot+  1/B(1,end) + x/f(end);   
            
            if  time_passed >= Deadline
                miss_cnt = miss_cnt + 1;
            else
                no_miss_cnt=no_miss_cnt+1;
            end   
    end
    
    
      
     static_enegery_used=static_enegery_used+  (A*(f(end)/1000)^p+E)*sum(N_leftover)*x/f(end);  
         
        
end
lb_arr_miss_cnt(nn,met)=miss_cnt;
arr_no_miss_cnt(nn,met)=no_miss_cnt;
arr_static_enegery_used(nn,met)=static_enegery_used;
lb_arr_time_tot(nn,met)=time_tot ;


end



%m by k

% round robin
met=met+1;


for nn = 1:len_N_tot 
    
    N_mat = squeeze(N_tot(nn,:,:));


no_miss_cnt=0;
miss_cnt=0;
static_enegery_used = 0;
time_tot=0;
for j = 1:length(N_mat)

    N = N_mat(j,:);
    N_leftover=zeros(1,size(N_mat,2));
    C_left = C;

    time_passed_ar = zeros(1,size(N_mat,2));
    for i=1:m
        time_passed = time_passed_ar(i);
        for n=1:N(i)
            time_passed = time_passed +  1/B(i,i) + x/f(i);      
            if  time_passed <= Deadline && n <= C(i)
                N_leftover(i)=N_leftover(i)+1;
                static_enegery_used=static_enegery_used+(A*(f(i)/1000)^p+E)*x/f(i);  
                C_left(i)=C_left(i)-1;
            
                
            end
            
        end
        time_passed_ar(i)=(1/B(i,i) + x/f(i))*N_leftover(i);
        N_leftover(i)=N(i)-N_leftover(i);

    end
    inn=0;
    N_leftover;
    time_passed_ar;

    j;
    for i=1:m
        
        while(N_leftover(i)>0)
            
            for ii=1:m
%                 time_passed = Deadline-time_passed_ar(ii);
%                
                if C_left(ii)>0 && N_leftover(i)>0
                    time_passed_ar(ii) = time_passed_ar(ii) +1/B(i,ii)+ x/f(ii);
                    if time_passed_ar(ii)>Deadline
                        miss_cnt = miss_cnt + 1;
                    end
                    static_enegery_used=static_enegery_used+(A*(f(ii)/1000)^p+E)*x/f(ii);  
                    N_leftover(i)=N_leftover(i)-1;
                    C_left(ii)=C_left(ii)-1;
       
                         inn=inn+ii;
                    
                end
            end
            
 
        end
        
        
        
    end
    
    
    time_tot = time_tot +sum(time_passed_ar);
end
lb_arr_miss_cnt(nn,met)=miss_cnt;
arr_no_miss_cnt(nn,met)=no_miss_cnt;
arr_static_enegery_used(nn,met)=static_enegery_used;
lb_arr_time_tot(nn,met)=time_tot ;

end

%m by k

% Active Monitoring Load Balancer --> most available server - cloud last
met=met+1;


for nn = 1:len_N_tot 
    
    N_mat = squeeze(N_tot(nn,:,:));

no_miss_cnt=0;
miss_cnt=0;
static_enegery_used = 0;
time_tot=0;
for j = 1:length(N_mat)

    N = N_mat(j,:);
    N_leftover=zeros(1,size(N_mat,2));
    C_left = C;

    time_passed_ar = zeros(1,size(N_mat,2));
    for i=1:m
        time_passed = time_passed_ar(i);
        for n=1:N(i)
            time_passed = time_passed +  1/B(i,i) + x/f(i);      
            if  time_passed <= Deadline && n <= C(i)
                N_leftover(i)=N_leftover(i)+1;
                static_enegery_used=static_enegery_used+(A*(f(i)/1000)^p+E)*x/f(i);  
                C_left(i)=C_left(i)-1;
            
                
            end
            
        end
        time_passed_ar(i)=(1/B(i,i) + x/f(i))*N_leftover(i);
        N_leftover(i)=N(i)-N_leftover(i);

    end
    inn=0;
    N_leftover;
    time_passed_ar;
    for i=1:m
        
        while(N_leftover(i)>0)
            [val ,index]=max(C_left(1:end-1));
            if(val>0)
                ii=index;
            else
                ii=m;
            end
            time_passed_ar(ii) = time_passed_ar(ii) +1/B(i,ii)+ x/f(ii);
            if time_passed_ar(ii)>Deadline
                miss_cnt = miss_cnt + 1;
            end
            static_enegery_used=static_enegery_used+(A*(f(ii)/1000)^p+E)*x/f(ii);  
            N_leftover(i)=N_leftover(i)-1;
            C_left(ii)=C_left(ii)-1;
           
                
                
            
            
           
        end
        
        
        
    end
    
 time_tot = time_tot +sum(time_passed_ar);
end
lb_arr_miss_cnt(nn,met)=miss_cnt;
arr_no_miss_cnt(nn,met)=no_miss_cnt;
arr_static_enegery_used(nn,met)=static_enegery_used;
lb_arr_time_tot(nn,met)=time_tot ;

end


%m by k

% throttled Load Balancer --> most recommded 

met=met+1;


for nn = 1:len_N_tot 
    
    N_mat = squeeze(N_tot(nn,:,:));


no_miss_cnt=0;
miss_cnt=0;
static_enegery_used = 0;
time_tot=0;
for j = 1:length(N_mat)

    N = N_mat(j,:);
    N_leftover=zeros(1,size(N_mat,2));
    C_left = C;

    time_passed_ar = zeros(1,size(N_mat,2));
    for i=1:m
        time_passed = time_passed_ar(i);
        for n=1:N(i)
            time_passed = time_passed +  1/B(i,i) + x/f(i);      
            if  time_passed <= Deadline && n <= C(i)
                N_leftover(i)=N_leftover(i)+1;
                static_enegery_used=static_enegery_used+(A*(f(i)/1000)^p+E)*x/f(i);  
                C_left(i)=C_left(i)-1;
            
                
            end
            
        end
        time_passed_ar(i)=(1/B(i,i) + x/f(i))*N_leftover(i);
        N_leftover(i)=N(i)-N_leftover(i);

    end
    inn=0;
    N_leftover;
    time_passed_ar;
    for i=1:m
        
        while(N_leftover(i)>0)
           best = inf*ones(1,m);
           for ii=1:m            
                if C_left(ii)>0 
                    best(ii) = time_passed_ar(ii) +1/B(i,ii)+ x/f(ii);                
                end
           end
%            ii=m;
%            for index=1:m-1
%               if best(index)<=Deadline
%                   ii=index;
%               end
%            end
            [val ii]=min(best);
           
            time_passed_ar(ii) = time_passed_ar(ii) +1/B(i,ii)+ x/f(ii);
            if time_passed_ar(ii)>Deadline
                miss_cnt = miss_cnt + 1;
            end
            static_enegery_used=static_enegery_used+(A*(f(ii)/1000)^p+E)*x/f(ii);  
            N_leftover(i)=N_leftover(i)-1;
            C_left(ii)=C_left(ii)-1;
                
                
            
            
           
        end
        
        
        
    end
    
    
    
    time_tot = time_tot +sum(time_passed_ar);   
%         
end
lb_arr_miss_cnt(nn,met)=miss_cnt;
arr_no_miss_cnt(nn,met)=no_miss_cnt;
arr_static_enegery_used(nn,met)=static_enegery_used;
lb_arr_time_tot(nn,met)=time_tot ;


end

lb_arr_miss_cnt;

total_ts=arr_no_miss_cnt+lb_arr_miss_cnt;
arr_static_enegery_used
lb_arr_time_tot



xxis = [12419 12986 13466 14053 14691 15247 15508 16014 16093]
xxis = [11132 11920 12687 13472 14143 14739 15051 15883];
gtot_arr_miss_cnt=horzcat(lb_arr_miss_cnt(1:end,2:end),arr_opt_miss_cnt(1:end,1:6))
gtot_arr_time_tot = horzcat(lb_arr_time_tot(1:end,2:end),arr_time_passed_tot(1:end,1:6))

gtot_arr_miss_cnt_ratio = gtot_arr_miss_cnt;

for i=1:size(gtot_arr_miss_cnt,2)
    
    gtot_arr_miss_cnt_ratio(:,i) = 100*gtot_arr_miss_cnt(:,i)./xxis';
end

figure

    plot(xxis,gtot_arr_miss_cnt,'-*')

figure
plot(xxis,gtot_arr_time_tot,'-o')
figure

    plot(xxis,gtot_arr_miss_cnt_ratio,'-x')
gtot_arr_miss_cnt_ratio
