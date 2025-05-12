DECLARE 

CURSOR process_list IS 
SELECT sde_id, owner, nodename FROM G_R03_GIL.process_information; 

lock_name VARCHAR2(30); 
lock_handle VARCHAR2(128); 
lock_status INTEGER; 
cnt INTEGER DEFAULT 0; 

BEGIN 

FOR check_locks IN process_list LOOP 

lock_name := 'SDE_Connection_ID#' || TO_CHAR (check_locks.sde_id); 
DBMS_LOCK.ALLOCATE_UNIQUE (lock_name,lock_handle); 
lock_status := DBMS_LOCK.REQUEST (lock_handle,DBMS_LOCK.X_MODE,0,TRUE); 

IF lock_status = 0 THEN 
DELETE FROM G_R03_GIL.process_information WHERE sde_id = check_locks.sde_id; 
DELETE FROM G_R03_GIL.state_locks WHERE sde_id = check_locks.sde_id; 
DELETE FROM G_R03_GIL.table_locks WHERE sde_id = check_locks.sde_id; 
DELETE FROM G_R03_GIL.object_locks WHERE sde_id = check_locks.sde_id; 
DELETE FROM G_R03_GIL.layer_locks WHERE sde_id = check_locks.sde_id; 
cnt := cnt + 1; 
dbms_output.put_line('Removed entry ('||check_locks.sde_id||'): '||check_locks.owner||'/'||check_locks.nodename||''); 
END IF; 

END LOOP; 

/* Remove any orphaned lock entries... */ 

DELETE FROM G_R03_GIL.state_locks WHERE sde_id NOT IN (SELECT sde_id FROM G_R03_GIL.process_information); 
DELETE FROM G_R03_GIL.table_locks WHERE sde_id NOT IN (SELECT sde_id FROM G_R03_GIL.process_information); 
DELETE FROM G_R03_GIL.object_locks WHERE sde_id NOT IN (SELECT sde_id FROM G_R03_GIL.process_information); 
DELETE FROM G_R03_GIL.layer_locks WHERE sde_id NOT IN (SELECT sde_id FROM G_R03_GIL.process_information); 

COMMIT; 

dbms_output.put_line('Removed '||cnt||' entries.'); 

END;  
