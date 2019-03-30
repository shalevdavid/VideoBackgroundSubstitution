%now finding the path
function [xx,yy,path]=making_path1_fun(spx,spy,m_spx,m_spy,d1,d2,weight)


path=zeros(size(weight,1) ,size(weight,2));
j=1;
while (m_spx~=spx | m_spy~=spy) 
%for j=1:20
   path(m_spx,m_spy)=j;
   xx(j,1)=m_spx;
   yy(j,1)=m_spy;
   from_where_x=d1(m_spx,m_spy);
    from_where_y=d2(m_spx,m_spy);
    m_spx=from_where_x;
    m_spy=from_where_y;
    j=j+1;

end;
path(m_spx,m_spy)=j;
xx(j,1)=m_spx;
yy(j,1)=m_spy;
