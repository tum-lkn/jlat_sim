% This function generates bursty traffic with respect to the publication
% Li, Yantao, et al. "Discrete-time Markov Model for Wireless Link Burstiness Simulations." Wireless personal communications 72.2 (2013): 987-1004.
function Bx=generate_traffic_log(beta,timeline)
    [Xp,Xn]=transitionprob(beta,timeline);
    Bx=bursty_traffic_sim(Xp,Xn,timeline);
end