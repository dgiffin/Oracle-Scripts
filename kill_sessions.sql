select 'alter system disconnect session ' || '''' || sid || ',' || serial# || '''' || ' immediate;'
from gv$session
where username='&USER';

