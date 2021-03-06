%m by k

clear
clc
% close all
delete('g1.txt')
diary('g1.txt')
diary on
format long
rng('default');
load('g1.mat');
%rng(1);
%rng('shuffle');
% D = 0.4;% deadline (sec)
% tau = 0.35; % allocated cpu time (sec)
% x= 50; % Mcycles per task
% v=10;

Deadline = 0.5;% deadline (sec)
tau = 0.48; % allocated cpu time (sec)
x= 35; % Mcycles per task
%v=10; 
E=70;
A=2.37;
p=3;
upper_N_ar = [12 14 16 18 20 22 24 26];
v_ar=[0 1 10 100 1000 10000000];
% upper_N_ar = [10 12];
% v_ar=[0 1 10];
m=6;
k=m;
m

upper_C = 25;


new_t = 20;

arr_opt_no_miss_cnt = zeros(length(upper_N_ar),length(v_ar));
arr_opt_miss_cnt =  zeros(length(upper_N_ar),length(v_ar));
arr_static_no_miss_cnt =  zeros(length(upper_N_ar),length(v_ar));
arr_static_miss_cnt_t_limit =  zeros(length(upper_N_ar),length(v_ar));
arr_static_miss_cnt_c_limit =  zeros(length(upper_N_ar),length(v_ar));
arr_time_passed_tot =  zeros(length(upper_N_ar),length(v_ar));
%arr_opt_enegery_used = zeros(1, length(task_iter));
%arr_static_enegery_used = zeros(1, length(task_iter));
arr_task_iter_cnt = 1;



    
   
suc_solved = 0;
total_iter = 100;
not_fea = 1;

% while not_fea 
  first = 0;
%   B = randi([16 64],m,m);%link rate (task per second)
%   for i=1:m
%       B(i,end) = 4;
%       B(end,i) = 4;
%   end
%   for i=1:m
%       for j=i:m
%         B(i,j)=B(j,i);
%       end
%   end
%   B(eye(size(B))~=0)=10e5;
%   f =  randi([27 36],1,m)*100;%(MHz)
%   %f = [2700 3000 3200 3500 0];
%   f(end)=30*150;
% %   N=  randi([new_t new_t+upper_N],1,m); % number of tasks(cars)
% %   N(end)=0;
%   
%   C =  randi([20 45],1,m); % server link capacity (# of tasks)
%   C(end)=inf;
%   num_tasks_allowed = sum(floor(tau*f/x));
%   num_tasks = sum(N);
%   if num_tasks < num_tasks_allowed & num_tasks < sum(C)
%     not_fea = 0;
%   else
%     not_fea = 1;
%   end

% end
new_t 



cnt_N=0;

for uu=1:length(upper_N_ar)
    upper_N = upper_N_ar(uu);
    uu_cnt=0;
    cnt_N=cnt_N+1;
for vv=1:length(v_ar)
    v=v_ar(vv);

    tic
    
    opt_no_miss_cnt = 0;
    opt_miss_cnt = 0;

    static_no_miss_cnt = 0;
    static_miss_cnt_t_limit = 0;
    static_miss_cnt_c_limit = 0;

    opt_enegery_used = 0;
    static_enegery_used = 0; 
    time_passed_tot = 0;   
    
for iter = 1:total_iter
     iter;
     not_fea = 1;
     
     
     if uu_cnt == 0
       sum_of_ts = 130+(uu-1)*5;
      while not_fea 
       N=  randi([new_t new_t+upper_N],1,m); % number of tasks(cars)
       N(end)=0;
       if 1 %sum(N)==sum_of_ts 
           not_fea = 0;
                  N_mat(iter,:)=N;
       
                    N_tot(cnt_N,iter,:)=N;
       end
       
       
      end
       
     else
         N= N_mat(iter,:);
     end

    obj = [];
    for i=1:m
        for j=1:m
            obj=[obj 1/B(i,j)+x/f(j)-Deadline/k]; 
        end
    end
%     for i=1:m
%         for j=1:m
%             obj=[obj x/f(j)*(A*(f(j)/1000)^p+E)]; 
%         end
%     end
    for i=1:m
       obj=[obj v]; 
    end
    c1 = zeros(m,m*k+m);
    for j=1:m
        for i=1:k
            c1(j,(i-1)*k+j)=x;
        end
    end
    c2 = zeros(m,m*k+m);
    for j=1:m
        for i=1:k
            c2(j,(i-1)*k+j)=1;
        end
    end
    c3 = zeros(m,m*k+m);
    for i=1:k
        for j=1:m
            c3(i,(i-1)*m+j)=1;
        end
    end
    y1 = zeros(m,m*k+m);
    for j=1:m
       y1(j,m*k+j) = 1;
    end
    y2 = zeros(m,m*k+m);
    for j=1:m
        for i=1:m
            y2(j,(i-1)*m+j)=-(1/B(i,j)+x/f(j));  
        end
    end
    for j=1:m
       y2(j,m*k+j) = 1;
    end
    a= [c1;c2;c3;y1;y2];
    b = zeros(size(a,1),1);
    cnt = 1;

    for j=1:m
       b(cnt) = f(j)*tau;
       cnt = cnt +1;
    end

    for j=1:m
       b(cnt) = C(j);
       cnt = cnt +1;
    end

    for i=1:k
       b(cnt) = N(i);
       cnt = cnt +1;
    end

    for i=1:k
       b(cnt) = 0;
       cnt = cnt +1;
    end

    for i=1:k
       b(cnt) = -Deadline;
       cnt = cnt +1;
    end

    e = -1*ones(size(a,1),1);
    e(2*m+1:3*m)=0;
    e(3*m+1:end)=1;
    vlb=[];
    vub=[];
    xint=1:m*m;

    lp = lp_maker(-obj, a, b, e,vlb, vub, xint);
    %tic
    solvestat = mxlpsolve('solve', lp);
    %toc
    
    if(solvestat==0)
        suc_solved = suc_solved +1;
        final_obj = mxlpsolve('get_objective', lp);
        res = mxlpsolve('get_variables', lp);
        cons = mxlpsolve('get_constraints', lp);
        %final_y1_cons=cons(end-2m+1:end-m)'
        final_y2_cons=cons(end-m+1:end)';
        dist=reshape(res,m,m+1)';
        final_dist=sparse(dist(1:m,:));%(x,y)=z -> x give y z tasks
        final_dist2=sparse(dist(1:m,:)');
        lateness =zeros(m,m);
        opt_lateness = zeros(1,m);


        %for i=1:m
        %    for j=1:k
        %       lateness(i,j) = final_dist(i,j)*(1/B(i,j)+x/f(j));
        %    end 
        %    opt_lateness=sum(lateness,2)-D;
        %end
        for i=1:m
            for j=1:k
               lateness(i,j) = final_dist2(i,j)*(1/B(j,i)+x/f(i));
            end 
            opt_lateness=sum(lateness,2)-Deadline;
        end


        %opt_lateness

        no_opt_lateness = zeros(m,1);

        for i=1:m    
            no_opt_lateness(i)=N(i)* ( 1/B(i,i) + x/f(i) )-Deadline;
        end


        %no_opt_lateness


        %opt_stat=datastats(opt_lateness)
        %no_opt_stat=datastats(no_opt_lateness)


        no_opt_avail_cpu_minus_required_cpu=tau*f-N*x;

        num_tasks_allowed = sum(floor(tau*f/x));
        num_tasks = sum(N);
        num_tasks_c = sum(C);
        mxlpsolve('delete_lp', lp);


        % check overall earliness
        
        for i=1:m
            

            for j=1:k
                if final_dist2(i,j)>0
                    for jj=1:final_dist2(i,j)
                        time_passed_tot=time_passed_tot+(1/B(j,i)+x/f(i));
                    end
                end
            end
            
        end
        %check deadline misses

        % my opt
        for i=1:m
            time_passed = 0;

            for j=1:k
                if final_dist2(i,j)>0
                    for jj=1:final_dist2(i,j)
                        time_passed=time_passed+(1/B(j,i)+x/f(i));
                        if  time_passed <= Deadline
                            opt_no_miss_cnt = opt_no_miss_cnt + 1;
                        else
                            opt_miss_cnt = opt_miss_cnt + 1;
                        end   
                    end
                end
               lateness(i,j) = final_dist2(i,j)*(1/B(j,i)+x/f(i));
            end 
            opt_lateness=sum(lateness,2)-Deadline;
        end






        % static
        for i=1:m    
            time_passed = 0;
            for kk= 1:N(i)
                if C(i)>=kk
                    time_passed = time_passed +  1/B(i,i) + x/f(i);
                    if  time_passed <= Deadline
                        static_no_miss_cnt = static_no_miss_cnt + 1;
                    else
                        static_miss_cnt_t_limit  = static_miss_cnt_t_limit  + 1;
                    end
                else
                   static_miss_cnt_c_limit=static_miss_cnt_c_limit+1; 
                end

            end
            final_lateness2(i)=N(i)* ( 1/B(i,i) + x/f(i) )-Deadline;
        end
        
        % random
%         time_passed=zeros(1,m);
%         for i=1:m    
%             time_passed = 0;
%             for kk= 1:N(i)
%                 if C(i)>=kk
%                     time_passed = time_passed +  1/B(i,i) + x/f(i);
%                     if  time_passed <= D
%                         no_miss_cnt = no_miss_cnt + 1;
%                     else
%                         miss_cnt_t_limit  = miss_cnt_t_limit  + 1;
%                     end
%                 else
%                    miss_cnt_c_limit=miss_cnt_c_limit+1; 
%                 end

%             end
%             final_lateness2(i)=N(i)* ( 1/B(i,i) + x/f(i) )-D;
%         end        
        
        
       %check enegery usage
 
        % my opt

        for i=1:m         
            for j=1:k
                opt_enegery_used=opt_enegery_used+  (A*(f(i)/1000)^p+E)*final_dist2(i,j)*x/f(i);  
            end 
        end           
         
        % static
        for i=1:m         
                static_enegery_used=static_enegery_used+  (A*(f(i)/1000)^p+E)*N(i)*x/f(i);  
        end           
        
        
     
        
        
    else
        iter
        mxlpsolve('delete_lp', lp);
    end



end


    arr_opt_miss_cnt(uu,vv)=opt_miss_cnt
    arr_opt_no_miss_cnt(uu,vv)=opt_no_miss_cnt;
    arr_time_passed_tot(uu,vv)=time_passed_tot;
    arr_static_miss_cnt_c_limit(uu,vv)=static_miss_cnt_c_limit;
    arr_static_miss_cnt_t_limit(uu,vv)=static_miss_cnt_t_limit;
    arr_static_no_miss_cnt(uu,vv)=static_no_miss_cnt;





toc
uu_cnt=1;

end


end







% final_dist
% v
% upper_N
% opt_miss_vs_no_miss=[arr_opt_miss_cnt ;arr_opt_no_miss_cnt];
% opt_en_vs_static_en=[arr_opt_enegery_used ;arr_static_enegery_used]

arr_opt_miss_cnt
total_ts=arr_opt_no_miss_cnt+arr_opt_miss_cnt
arr_time_passed_tot
arr_static_miss=arr_static_miss_cnt_c_limit+ arr_static_miss_cnt_t_limit
total_ts=arr_static_no_miss_cnt+arr_static_miss_cnt_c_limit+ arr_static_miss_cnt_t_limit



% display('en')

diary off
save('g1.mat','f','C','B','N_tot','arr_opt_miss_cnt','arr_time_passed_tot');

