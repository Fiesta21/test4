-----------------------------------------------
-- ООО «ИЦ ФосАгро», xx.xx.xxxx
-- Создал 
--  Фио  xx.xx.xxxx
-- Имя
--   XX_EAM333_REG.sql
-- Версия
--   1.0
-- Описание
--   Добавить описание
-- Изменения
-----------------------------------------------
SET SERVEROUTPUT ON

DECLARE
    g_appl_short_name       CONSTANT VARCHAR2( 8 )   := 'XXPHA';

    g_cust_name             CONSTANT VARCHAR2( 128 ) := 'Добавить имя';
    g_cust_file_name        CONSTANT VARCHAR2( 32 )  := 'XXPHA_EAM333_PKG.main';
    g_cust_short_name       CONSTANT VARCHAR2( 16 )  := 'XXPHA_EAM333';

    g_cust_desc             CONSTANT VARCHAR2( 128 ) := 'Добавить описание';

    g_cust_execution_method CONSTANT VARCHAR2( 32 )  := 'PL/SQL Stored Procedure';

    g_resp_list             VARCHAR2( 128 )          := 'Системный администратор';

    TYPE XXPHA_EAM333_PROCESS_TYPE IS TABLE OF VARCHAR2( 256 ) INDEX BY BINARY_INTEGER;

    t_perms_values XXPHA_EAM333_PROCESS_TYPE;                                                                  -- Список полномочий по умолчанию

    vr_no                   INTEGER;                                                                          -- Счётчик параметров cancurrenta
BEGIN
    -- Коллекция полномочий по умолчанию
    t_perms_values( 1 ) := 'Системный администратор';

    dbms_output.enable( 1000000 );

    fnd_flex_val_api.set_session_mode( session_mode => 'customer_data' );                                     -- ???

    --1) Создание заголовка параллельной программы
    XXPHA_CREATE_CONC.bild_header( p_appl_short_name         => g_appl_short_name
                                   , p_cust_short_name       => g_cust_short_name
                                   , p_cust_name             => g_cust_name
                                   , p_cust_desc             => g_cust_desc
                                   , p_cust_file_name        => g_cust_file_name
                                   , p_cust_execution_method => g_cust_execution_method
                                   , p_output_type           => 'XML'                                        -- Отчёт не нужен
                                   , p_resp_list             => g_resp_list
                                   , p_delete_conc           => 'Y'                                          --При 'Y' идёт пересоздание параллельной программы
                                 );

    --Создание XML 'XSL-XML'
    XXPHA_CREATE_CONC.bild_xml( 'XSL-XML' );

    -- Если разработка не стояла нигде, то процедура, устанавливающая разработку на фиксированные полномочия
    BEGIN
        dbms_output.put_line( 'Add program to responsibilities.' );
        if t_perms_values.count > 0 then
            vr_no := t_perms_values.first;
            loop
                XXPHA_CREATE_CONC.add_resp_to_conc( p_conc_name => g_cust_short_name, p_pesp_name => t_perms_values( vr_no ) );
                vr_no := t_perms_values.next( vr_no );
                exit when vr_no is NULL;
            end loop;
        end if;
    EXCEPTION when others then
        -- Ну, не удалось в полномочия поставить, ничего страшного, может уже и нет полномочий, чтоб администраторы лишний раз не волновались из-за ошибок.
        NULL;
    END;

    COMMIT;
EXCEPTION when others then
    dbms_output.put_line( substr( 'Error: ' || fnd_program.message, 1, 255 ) );
    dbms_output.put_line( SQLERRM );
    dbms_output.put_line( dbms_utility.format_error_backtrace );
    dbms_output.put_line( APPS.FND_PROGRAM.message );
    dbms_output.put_line( APPS.FND_FLEX_VAL_API.message );
    RAISE;
END;
/
SHOW ERRORS