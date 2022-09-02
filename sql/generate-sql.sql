
-- generate-sql.sql
-- generate some default column headings and a sql statement
-- from a table or view
-- @generaate-sql sys all_objects

col column_name format a30
col data_type format a15
col data_precision format 999,999
col data_scale format 999,999
col data_length format 9,999,999

col col_desc format a60

set linesize 200 trimspool on

@clear_for_spool

prompt
prompt -- generated by generate-sql.sql
prompt 
prompt set linesize 200 trimspool on
prompt set pagesize 100
prompt set verify off echo off pause off
prompt set feedback on heading on tab off
prompt 
prompt 

select
	--column_name
	--, data_type
	--, data_length
	--, data_precision
	--, data_scale
		case when regexp_like(data_type,'.*CHAR.*') then
			case when data_length <= 30 then
				'col ' || column_name || ' format a' || data_length
			else
				'col ' || column_name || ' format a50'
			end
		else
			case when regexp_like(data_type,'NUMBER.*') then
				case when data_precision is not null then
					'col ' || column_name || ' format ' || rpad('9',data_precision,'9') || '.' || rpad('9',data_scale,'9')
				else
					'col ' || column_name || ' format 999999'
				end
			else
				case when data_type = 'DATE' then
					'col ' || column_name || ' format a22'
				else
					case when regexp_like(data_type,'TIMESTAMP.*') then
						'col ' || column_name || ' format a30'
					else
						case when data_type = 'CLOB' then
							'col ' || column_name || ' format a64'
						else
							'col ' || column_name || '_UNHANDLED '
						end
					end
				end
			end
		end col_desc
from all_tab_columns
where 
	owner = upper('&1') 
	and
	table_name = upper('&2')
order by column_id
/

col column_id noprint head 'skipthis'

prompt
prompt

--/*

select 0 column_id, 'select ' from dual
union all
select column_id, 
	'	' || decode(column_id,1,'',', ') || column_name
from (
	select column_id, column_name
	from all_tab_columns
	where 
		owner = upper('&1') 
		and
		table_name = upper('&2')
	order by column_id
)
union all
select 0 column_id, 'from &2;' from dual
/

prompt
--*/

@clears


