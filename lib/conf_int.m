function ci = conf_int(inputmat, alpha, dim)

SEM = squeeze(std(inputmat))/sqrt(size(inputmat,dim));                % Standard Error
ts = tinv([alpha/2  1-alpha/2],size(inputmat,dim)-1);           % T-Score
ci  = ts(2)*SEM;